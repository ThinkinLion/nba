#!/usr/bin/env node

/**
 * ==============================================================================
 * App Store Connect 릴리즈 노트(이 버전에서 변경된 사항) 자동 업데이트 스크립트
 * ==============================================================================
 * Apple REST API를 직접 호출하여 제출 준비 중(Prepare for Submission)인
 * 최신 버전의 "이 버전에서 변경된 사항 (What's New)"을 즉시 갱신합니다.
 */

const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

const API_KEY = "N8H3XA3PY5";
const API_ISSUER = "69a6de82-3793-47e3-e053-5b8c7c11a4d1";
const KEY_PATH = path.join(process.env.HOME, ".appstoreconnect", "private_keys", `AuthKey_${API_KEY}.p8`);
const APP_BUNDLE_ID = "com.spearhead.nbaPowerRanking";

// 릴리즈 노트 파일 경로 (프로젝트 루트의 RELEASE_NOTES.txt)
const PROJECT_ROOT = path.resolve(__dirname, "..");
const RELEASE_NOTES_FILE = path.join(PROJECT_ROOT, "RELEASE_NOTES.txt");

// Apple 거부 문자(이모지 등) 안전 정제 함수
function sanitizeWhatsNew(text) {
    if (!text) return "";
    return text
        .replace(/[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F1E6}-\u{1F1FF}]/gu, "") // 이모지 제거
        .replace(/[•●]/g, "-") // 특수 글머리 기호 표준 대시로 변환
        .trim();
}

// 릴리즈 노트 텍스트 가져오기 (1. CLI 인자 -> 2. RELEASE_NOTES.txt -> 3. 기본 텍스트)
function getWhatsNewText(locale) {
    // 1. CLI 인자로 전달된 텍스트 확인
    const cliArgText = process.argv.slice(2).find(arg => !arg.startsWith("--"));
    if (cliArgText) {
        return sanitizeWhatsNew(cliArgText);
    }

    // 2. RELEASE_NOTES.txt 파일 확인
    if (fs.existsSync(RELEASE_NOTES_FILE)) {
        const fileContent = fs.readFileSync(RELEASE_NOTES_FILE, "utf8").trim();
        if (fileContent.length > 0) {
            console.log(`📄 Using release notes from: ${RELEASE_NOTES_FILE}`);
            return sanitizeWhatsNew(fileContent);
        }
    }

    // 3. 기본 폴백 텍스트
    if (locale === "ko") {
        return sanitizeWhatsNew(`2026-27 NBA 새 시즌 개막 업데이트!

- 2026-27 시즌 개막 지원: 새 시즌 최신 주차별 파워랭킹, 팀 로스터 및 경기 순위를 실시간으로 확인하세요.
- 시즌 선택 캡슐 토글 추가: 파워랭킹 상단에서 한 번의 탭으로 2026-27 시즌과 2025-26 지난 시즌 랭킹을 자유롭게 넘나들 수 있습니다.
- 직관적인 2-Tab 네비게이션: 정규시즌에 집중할 수 있도록 'Power Ranking'과 'Standings' 중심으로 화면을 산뜻하게 개편했습니다.
- 팀 상세 로스터 및 스탯 안정화: 최신 선수 로스터와 시즌 기록이 더욱 빠르고 안정적으로 표시됩니다.
- UI 및 성능 개선: 개막 주차 데이터 처리를 최적화하고 전반적인 앱 사용성을 향상시켰습니다.`);
    }

    return sanitizeWhatsNew(`2026-27 NBA Season Opening Update!

- 2026-27 Season Ready: Track the latest weekly power rankings, team rosters, and standings for the brand new 2026-27 NBA season.
- Season Switcher: Seamlessly toggle between 2026-27 and 2025-26 power rankings with a single tap.
- Streamlined Navigation: Clean 2-Tab experience focused on 'Power Ranking' and 'Standings'.
- Roster & Stats Improvements: Fast and reliable team roster and seasonal statistics.
- UI & Performance: Optimized early-season ranking handling and enhanced app stability.`);
}

// 1. JWT 토큰 생성 (순수 Node.js 내장 crypto)
function generateToken() {
    if (!fs.existsSync(KEY_PATH)) {
        throw new Error(`API Key not found at ${KEY_PATH}`);
    }
    const privateKey = fs.readFileSync(KEY_PATH, "utf8");
    const base64url = (str) => Buffer.from(str).toString("base64url");
    
    const header = { alg: "ES256", kid: API_KEY, typ: "JWT" };
    const now = Math.floor(Date.now() / 1000);
    const payload = {
        iss: API_ISSUER,
        iat: now,
        exp: now + 1200,
        aud: "appstoreconnect-v1"
    };

    const tokenInput = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(payload))}`;
    const sign = crypto.createSign("SHA256");
    sign.update(tokenInput);
    sign.end();
    const signature = sign.sign({ key: privateKey, dsaEncoding: "ieee-p1363" }, "base64url");
    return `${tokenInput}.${signature}`;
}

async function apiRequest(endpoint, method = "GET", body = null) {
    const token = generateToken();
    const options = {
        method,
        headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json"
        }
    };
    if (body) {
        options.body = JSON.stringify(body);
    }
    const res = await fetch(`https://api.appstoreconnect.apple.com${endpoint}`, options);
    if (!res.ok) {
        const errText = await res.text();
        throw new Error(`API ${method} ${endpoint} failed (${res.status}): ${errText}`);
    }
    if (res.status === 204) return null;
    return await res.json();
}

async function main() {
    console.log("==================================================================");
    echo_divider = "------------------------------------------------------------------";
    console.log("📝 App Store Connect 릴리즈 노트 자동 업데이트");
    console.log("==================================================================");

    // 1. App ID 조회
    console.log("🔍 Fetching App information...");
    const appData = await apiRequest(`/v1/apps?filter[bundleId]=${APP_BUNDLE_ID}`);
    if (!appData.data || appData.data.length === 0) {
        throw new Error(`App with bundleId ${APP_BUNDLE_ID} not found.`);
    }
    const appId = appData.data[0].id;
    console.log(`✅ Found App: ${appData.data[0].attributes.name} (App ID: ${appId})`);

    // 2. 제출 준비 중(PREPARE_FOR_SUBMISSION)인 버전 탐색
    console.log("🔍 Fetching App Store versions...");
    const versionsData = await apiRequest(`/v1/apps/${appId}/appStoreVersions`);
    const targetVersion = versionsData.data.find(v => v.attributes.appStoreState === "PREPARE_FOR_SUBMISSION");

    if (!targetVersion) {
        console.log("⚠️ No version in 'PREPARE_FOR_SUBMISSION' state found.");
        console.log("ℹ️ Available versions:", versionsData.data.map(v => `${v.attributes.versionString} (${v.attributes.appStoreState})`).join(", "));
        return;
    }

    console.log(`🎯 Target Version for update: ${targetVersion.attributes.versionString} (ID: ${targetVersion.id})`);
    console.log("------------------------------------------------------------------");

    // 3. 언어별 로컬라이제이션 조회
    console.log("🔍 Fetching localizations...");
    const locData = await apiRequest(`/v1/appStoreVersions/${targetVersion.id}/appStoreVersionLocalizations`);

    for (const loc of locData.data) {
        const locale = loc.attributes.locale;
        const whatsNewText = getWhatsNewText(locale);
        
        console.log(`📝 Updating 'What\'s New' for locale: [${locale}] (ID: ${loc.id})...`);
        
        const patchBody = {
            data: {
                id: loc.id,
                type: "appStoreVersionLocalizations",
                attributes: {
                    whatsNew: whatsNewText
                }
            }
        };

        await apiRequest(`/v1/appStoreVersionLocalizations/${loc.id}`, "PATCH", patchBody);
        console.log(`✅ Successfully updated [${locale}] release notes!`);
    }

    console.log("==================================================================");
    console.log("🎉 All release notes have been successfully updated on App Store Connect!");
    console.log("🌐 Check it out at: https://appstoreconnect.apple.com/apps");
    console.log("==================================================================");
}

main().catch(err => {
    console.error("❌ Error updating release notes:", err.message);
    process.exit(1);
});
