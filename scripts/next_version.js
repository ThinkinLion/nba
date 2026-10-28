#!/usr/bin/env node
/**
 * 다음 마케팅 버전 결정 스크립트 (deploy.sh 가 --version 없이 실행될 때 호출)
 *
 * App Store Connect 에서 현재 마케팅 버전의 상태를 조회해
 *  - 아직 열려 있는 버전(제출 준비 중 / 심사 대기·진행 중 / 반려 등) → 그대로 사용 (빌드 번호만 올리면 됨)
 *  - 이미 닫힌 버전(판매 중 / 배포 승인 / 교체됨 등) 또는 레코드 없음 → 마지막 자리를 +1 한 버전 출력 (1.11 → 1.12)
 * stdout 에 버전 문자열 한 줄만 출력한다. (로그는 stderr)
 */
const crypto = require("crypto");
const fs = require("fs");
const path = require("path");
const { getMarketingVersion } = require("./asc_version");

const API_KEY = "N8H3XA3PY5";
const API_ISSUER = "69a6de82-3793-47e3-e053-5b8c7c11a4d1";
const KEY_PATH = path.join(process.env.HOME, ".appstoreconnect", "private_keys", `AuthKey_${API_KEY}.p8`);
const APP_BUNDLE_ID = "com.spearhead.nbaPowerRanking";

// 이 상태들은 아직 빌드를 더 올릴 수 있는(열린) 버전
const OPEN_STATES = new Set([
    "PREPARE_FOR_SUBMISSION", "WAITING_FOR_REVIEW", "IN_REVIEW", "REJECTED", "DEVELOPER_REJECTED",
    "METADATA_REJECTED", "INVALID_BINARY", "WAITING_FOR_EXPORT_COMPLIANCE", "PENDING_DEVELOPER_RELEASE",
]);

const log = (...a) => console.error(...a);

function generateToken() {
    const privateKey = fs.readFileSync(KEY_PATH, "utf8");
    const base64url = (str) => Buffer.from(str).toString("base64url");
    const now = Math.floor(Date.now() / 1000);
    const header = { alg: "ES256", kid: API_KEY, typ: "JWT" };
    const payload = { iss: API_ISSUER, iat: now, exp: now + 1200, aud: "appstoreconnect-v1" };
    const input = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(payload))}`;
    const sign = crypto.createSign("SHA256");
    sign.update(input); sign.end();
    return `${input}.${sign.sign({ key: privateKey, dsaEncoding: "ieee-p1363" }, "base64url")}`;
}

async function apiGet(endpoint) {
    const res = await fetch(`https://api.appstoreconnect.apple.com${endpoint}`, {
        headers: { Authorization: `Bearer ${generateToken()}` },
    });
    if (!res.ok) throw new Error(`API GET ${endpoint} failed (${res.status}): ${await res.text()}`);
    return res.json();
}

/** "1.11" → "1.12", "1.9" → "1.10", "2.0.3" → "2.0.4" */
function bumpLast(version) {
    const parts = version.split(".");
    parts[parts.length - 1] = String(parseInt(parts[parts.length - 1], 10) + 1);
    return parts.join(".");
}

async function main() {
    const current = getMarketingVersion();
    const apps = await apiGet(`/v1/apps?filter[bundleId]=${APP_BUNDLE_ID}`);
    const appId = apps.data[0]?.id;
    if (!appId) throw new Error("앱을 찾지 못했습니다.");
    const versions = await apiGet(`/v1/apps/${appId}/appStoreVersions?filter[platform]=IOS`);
    const record = versions.data.find(v => v.attributes.versionString === current);

    if (!record) {
        log(`ℹ️ App Store Connect 에 ${current} 레코드가 없음 → ${current} 그대로 사용 (업로드 후 자동 생성)`);
        console.log(current);
        return;
    }
    const state = record.attributes.appStoreState;
    if (OPEN_STATES.has(state)) {
        log(`ℹ️ ${current} 은(는) 아직 열린 상태(${state}) → 버전 유지, 빌드 번호만 상향`);
        console.log(current);
        return;
    }
    const next = bumpLast(current);
    log(`ℹ️ ${current} 은(는) 닫힌 상태(${state}) → 다음 버전 ${next} 사용`);
    console.log(next);
}

main().catch(err => {
    log(`⚠️ 다음 버전 결정 실패: ${err.message} → 현재 버전 유지`);
    console.log(getMarketingVersion());
});
