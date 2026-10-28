#!/usr/bin/env node

/**
 * ==============================================================================
 * App Store Connect "심사에 최종 제출(Submit for Review)" 자동화 스크립트
 * ==============================================================================
 * 1. 최신 PREPARE_FOR_SUBMISSION 상태의 버전 탐색
 * 2. 업로드된 최신 빌드가 처리 완료(VALID)될 때까지 대기(Polling)
 * 3. 버전에 최신 빌드 연결 (아직 연결되지 않은 경우)
 * 4. Review Submission 생성 및 아이템 추가
 * 5. 심사에 최종 제출 (submitted: true)
 */

const crypto = require("crypto");
const fs = require("fs");
const path = require("path");
const { ensurePrepareForSubmissionVersion } = require("./asc_version");

const API_KEY = "N8H3XA3PY5";
const API_ISSUER = "69a6de82-3793-47e3-e053-5b8c7c11a4d1";
const KEY_PATH = path.join(process.env.HOME, ".appstoreconnect", "private_keys", `AuthKey_${API_KEY}.p8`);
const APP_BUNDLE_ID = "com.spearhead.nbaPowerRanking";

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
    // 네트워크 오류("fetch failed": DNS/TLS/연결 끊김)와 429/5xx 는 일시적일 수 있어 지수 백오프로 재시도
    const maxAttempts = 5;
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
        let res;
        try {
            res = await fetch(`https://api.appstoreconnect.apple.com${endpoint}`, options);
        } catch (err) {
            if (attempt === maxAttempts) throw new Error(`API ${method} ${endpoint} 네트워크 오류 (${maxAttempts}회 재시도 실패): ${err.message}`);
            const wait = 2000 * attempt;
            console.log(`⚠️ 네트워크 오류 (${err.message}) — ${wait / 1000}초 후 재시도 (${attempt}/${maxAttempts})`);
            await new Promise(r => setTimeout(r, wait));
            continue;
        }
        if (res.status === 429 || res.status >= 500) {
            const errText = await res.text();
            if (attempt === maxAttempts) throw new Error(`API ${method} ${endpoint} failed (${res.status}): ${errText}`);
            const wait = 5000 * attempt;
            console.log(`⚠️ 서버 응답 ${res.status} — ${wait / 1000}초 후 재시도 (${attempt}/${maxAttempts})`);
            await new Promise(r => setTimeout(r, wait));
            continue;
        }
        if (!res.ok) {
            const errText = await res.text();
            throw new Error(`API ${method} ${endpoint} failed (${res.status}): ${errText}`);
        }
        if (res.status === 204) return null;
        return await res.json();
    }
}

const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

async function main() {
    console.log("==================================================================");
    console.log("🚀 App Store Connect 심사 최종 제출(Submit for Review) 시작");
    console.log("==================================================================");

    // 1. App ID 조회
    const appData = await apiRequest(`/v1/apps?filter[bundleId]=${APP_BUNDLE_ID}`);
    if (!appData.data || appData.data.length === 0) {
        throw new Error(`App with bundleId ${APP_BUNDLE_ID} not found.`);
    }
    const appId = appData.data[0].id;
    console.log(`✅ App ID 확인: ${appId} (${appData.data[0].attributes.name})`);

    // 2. 제출 준비 중인 버전 탐색 — 없으면 현재 마케팅 버전으로 생성
    const targetVersion = await ensurePrepareForSubmissionVersion(apiRequest, appId);
    if (!targetVersion) {
        console.log("⚠️ 제출할 수 있는 'PREPARE_FOR_SUBMISSION' 버전이 없습니다.");
        return;
    }
    console.log(`🎯 심사 대상 버전: v${targetVersion.attributes.versionString} (Version ID: ${targetVersion.id})`);

    // 3. 최신 빌드 상태 확인 및 처리 대기 (필요 시)
    console.log("🔍 최신 빌드 처리 상태 확인 중...");
    let latestBuild = null;
    const maxRetries = 30; // 최대 15분 대기 (30초 * 30회)
    for (let i = 0; i < maxRetries; i++) {
        let buildsData;
        try {
            buildsData = await apiRequest(`/v1/builds?filter[app]=${appId}&sort=-uploadedDate&limit=1`);
        } catch (err) {
            // 폴링 중 일시적 오류는 다음 주기에 다시 시도 (apiRequest 자체 재시도 이후에도 실패한 경우)
            console.log(`⚠️ 빌드 상태 조회 실패: ${err.message} — 다음 주기에 다시 시도합니다.`);
            await sleep(30000);
            continue;
        }
        if (buildsData.data && buildsData.data.length > 0) {
            latestBuild = buildsData.data[0];
            const state = latestBuild.attributes.processingState;
            console.log(`📱 빌드 #${latestBuild.attributes.version} 상태: [${state}]`);
            if (state === "VALID") {
                break;
            } else if (state === "FAILED" || state === "INVALID") {
                throw new Error(`빌드 처리가 실패했습니다 (${state}). App Store Connect를 확인해 주세요.`);
            }
        }
        console.log(`⏳ 애플 서버에서 빌드 처리 중입니다... 30초 후 다시 확인합니다 (${i + 1}/${maxRetries})`);
        await sleep(30000);
    }

    if (!latestBuild || latestBuild.attributes.processingState !== "VALID") {
        throw new Error("빌드가 유효한(VALID) 상태가 되지 않아 심사에 제출할 수 없습니다.");
    }

    // 4. 버전에 빌드 연결 (아직 안 되어 있는 경우)
    const attachedBuildRes = await apiRequest(`/v1/appStoreVersions/${targetVersion.id}/build`);
    if (!attachedBuildRes.data || attachedBuildRes.data.id !== latestBuild.id) {
        console.log(`🔗 버전에 최신 빌드(#${latestBuild.attributes.version}) 연결 중...`);
        await apiRequest(`/v1/appStoreVersions/${targetVersion.id}/relationships/build`, "PATCH", {
            data: {
                type: "builds",
                id: latestBuild.id
            }
        });
        console.log("✅ 빌드 연결 완료!");
    } else {
        console.log(`✅ 최신 빌드(#${latestBuild.attributes.version})가 이미 버전에 연결되어 있습니다.`);
    }

    // 5. 기존 진행 중인 Review Submission 확인 또는 생성
    console.log("📋 Review Submission 생성 및 심사 대기열 준비 중...");
    let submissionId = null;

    // 기존 활성 submission 조회
    const existingSubmissions = await apiRequest(`/v1/apps/${appId}/reviewSubmissions?filter[platform]=IOS&filter[state]=READY_FOR_REVIEW`);
    if (existingSubmissions.data && existingSubmissions.data.length > 0) {
        submissionId = existingSubmissions.data[0].id;
        console.log(`ℹ️ 기존 대기열 재사용: ${submissionId}`);
    } else {
        const newSubmission = await apiRequest("/v1/reviewSubmissions", "POST", {
            data: {
                type: "reviewSubmissions",
                attributes: {
                    platform: "IOS"
                },
                relationships: {
                    app: {
                        data: {
                            type: "apps",
                            id: appId
                        }
                    }
                }
            }
        });
        submissionId = newSubmission.data.id;
        console.log(`✅ 새 Review Submission 생성 완료: ${submissionId}`);
    }

    // 6. Review Submission에 AppStoreVersion 아이템 추가 (중복 방지)
    const itemsData = await apiRequest(`/v1/reviewSubmissions/${submissionId}/items`);
    const alreadyAdded = itemsData.data.some(item => 
        item.relationships && item.relationships.appStoreVersion && item.relationships.appStoreVersion.data.id === targetVersion.id
    );

    if (!alreadyAdded) {
        console.log(`➕ 버전을 심사 항목에 추가 중...`);
        await apiRequest("/v1/reviewSubmissionItems", "POST", {
            data: {
                type: "reviewSubmissionItems",
                relationships: {
                    reviewSubmission: {
                        data: {
                            type: "reviewSubmissions",
                            id: submissionId
                        }
                    },
                    appStoreVersion: {
                        data: {
                            type: "appStoreVersions",
                            id: targetVersion.id
                        }
                    }
                }
            }
        });
        console.log("✅ 심사 항목 추가 완료!");
    } else {
        console.log("✅ 버전이 이미 심사 항목에 포함되어 있습니다.");
    }

    // 7. 심사에 최종 제출 (Submit for Review)
    console.log("------------------------------------------------------------------");
    console.log("🚀 심사 최종 제출(Submit for Review) 요청 전송 중...");
    
    await apiRequest(`/v1/reviewSubmissions/${submissionId}`, "PATCH", {
        data: {
            type: "reviewSubmissions",
            id: submissionId,
            attributes: {
                submitted: true
            }
        }
    });

    console.log("==================================================================");
    console.log("🎉 SUCCESS: 앱이 App Store 심사 대기열에 성공적으로 최종 제출되었습니다!");
    console.log(`📱 제출 버전: v${targetVersion.attributes.versionString} (빌드 #${latestBuild.attributes.version})`);
    console.log("🌐 심사 상태 확인: https://appstoreconnect.apple.com/apps");
    console.log("⏱️  보통 24~48시간 이내에 Apple 검토 결과가 이메일로 전송됩니다.");
    console.log("==================================================================");
}

main().catch(err => {
    console.error("❌ 심사 제출 중 오류 발생:", err.message);
    process.exit(1);
});
