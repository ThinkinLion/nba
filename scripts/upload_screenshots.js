#!/usr/bin/env node

/**
 * ==============================================================================
 * App Store Connect 스크린샷 자동 업로드 스크립트 (Duo: 6.7/6.9형 & 6.5형)
 * ==============================================================================
 * Apple App Store Connect REST API를 사용하여 로컬 screenshots/ 디렉토리의
 * 6.7인치(Dynamic Island) 및 6.5인치(Notch) 필수 2대 규격 스크린샷을
 * 원격 앱스토어 버전에 자동으로 일괄 업로드합니다.
 */

const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

const API_KEY = "N8H3XA3PY5";
const API_ISSUER = "69a6de82-3793-47e3-e053-5b8c7c11a4d1";
const KEY_PATH = path.join(process.env.HOME, ".appstoreconnect", "private_keys", `AuthKey_${API_KEY}.p8`);
const APP_BUNDLE_ID = "com.spearhead.nbaPowerRanking";

const PROJECT_ROOT = path.resolve(__dirname, "..");
const SCREENSHOTS_DIR = path.join(PROJECT_ROOT, "screenshots");

// 색상 출력 헬퍼
const GREEN = "\x1b[32m";
const BLUE = "\x1b[34m";
const YELLOW = "\x1b[33m";
const RED = "\x1b[31m";
const RESET = "\x1b[0m";

// 1. JWT 토큰 생성
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

// 2. App Store Connect API 요청 함수
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

// 3. 단일 스크린샷 바이너리 업로드 함수
async function uploadScreenshot(screenshotSetId, filePath) {
    const fileName = path.basename(filePath);
    const fileBuffer = fs.readFileSync(filePath);
    const fileSize = fileBuffer.length;
    const md5Checksum = crypto.createHash("md5").update(fileBuffer).digest("hex");

    console.log(`    ⬆️  예약 생성 중: ${fileName} (${(fileSize / 1024 / 1024).toFixed(2)} MB)...`);

    // 1) appScreenshots 생성 요청
    const reservation = await apiRequest("/v1/appScreenshots", "POST", {
        data: {
            type: "appScreenshots",
            attributes: {
                fileName,
                fileSize
            },
            relationships: {
                appScreenshotSet: {
                    data: {
                        type: "appScreenshotSets",
                        id: screenshotSetId
                    }
                }
            }
        }
    });

    const screenshotId = reservation.data.id;
    const uploadOperations = reservation.data.attributes.uploadOperations;

    // 2) 바이너리 청크 업로드 (uploadOperations 수행)
    for (const op of uploadOperations) {
        const chunk = fileBuffer.subarray(op.offset, op.offset + op.length);
        const headers = {};
        for (const h of op.requestHeaders || []) {
            headers[h.name] = h.value;
        }

        const uploadRes = await fetch(op.url, {
            method: op.method,
            headers,
            body: chunk
        });

        if (!uploadRes.ok) {
            const err = await uploadRes.text();
            throw new Error(`Upload chunk failed (${uploadRes.status}): ${err}`);
        }
    }

    // 3) 업로드 완료 커밋 (PATCH)
    await apiRequest(`/v1/appScreenshots/${screenshotId}`, "PATCH", {
        data: {
            type: "appScreenshots",
            id: screenshotId,
            attributes: {
                uploaded: true,
                sourceFileChecksum: md5Checksum
            }
        }
    });

    console.log(`    ${GREEN}✓ 업로드 완료 및 검증 성공: ${fileName}${RESET}`);
}

// 4. 스크린샷 세트 조회 또는 생성 함수
async function getOrCreateScreenshotSet(localizationId, displayType) {
    const setsRes = await apiRequest(`/v1/appStoreVersionLocalizations/${localizationId}/appScreenshotSets`);
    const existing = (setsRes.data || []).find(s => s.attributes.screenshotDisplayType === displayType);
    
    if (existing) {
        return existing.id;
    }

    console.log(`    ➕ 새 스크린샷 세트 생성 (${displayType})...`);
    const created = await apiRequest("/v1/appScreenshotSets", "POST", {
        data: {
            type: "appScreenshotSets",
            attributes: {
                screenshotDisplayType: displayType
            },
            relationships: {
                appStoreVersionLocalization: {
                    data: {
                        type: "appStoreVersionLocalizations",
                        id: localizationId
                    }
                }
            }
        }
    });
    return created.data.id;
}

// 5. 스크린샷 세트 내 기존 스크린샷 정리
async function cleanScreenshotSet(screenshotSetId) {
    const screenshotsRes = await apiRequest(`/v1/appScreenshotSets/${screenshotSetId}/appScreenshots`);
    const existing = screenshotsRes.data || [];
    for (const s of existing) {
        await apiRequest(`/v1/appScreenshots/${s.id}`, "DELETE");
    }
}

async function main() {
    console.log(`${BLUE}==================================================================${RESET}`);
    console.log(`${BLUE}   🏀 App Store 필수 2대 규격 (Duo) 스크린샷 자동 업로드   ${RESET}`);
    console.log(`${BLUE}==================================================================${RESET}`);

    // CLI 인자 파싱
    const args = process.argv.slice(2);
    const createVersionArg = args.find(a => a.startsWith("--create-version="));
    const newVersionString = createVersionArg ? createVersionArg.split("=")[1] : null;

    // 1. App ID 조회
    const appData = await apiRequest(`/v1/apps?filter[bundleId]=${APP_BUNDLE_ID}`);
    if (!appData.data || appData.data.length === 0) {
        throw new Error(`App with bundleId ${APP_BUNDLE_ID} not found.`);
    }
    const appId = appData.data[0].id;
    console.log(`📱 Target App: ${GREEN}${appData.data[0].attributes.name}${RESET} (ID: ${appId})`);

    // 2. 버전 확인 (PREPARE_FOR_SUBMISSION)
    const versionsData = await apiRequest(`/v1/apps/${appId}/appStoreVersions`);
    let targetVersion = versionsData.data.find(v => v.attributes.appStoreState === "PREPARE_FOR_SUBMISSION");

    if (!targetVersion) {
        if (newVersionString) {
            console.log(`\n${YELLOW}>> PREPARE_FOR_SUBMISSION 버전이 없어 새 버전 '${newVersionString}'을 생성합니다...${RESET}`);
            const newVerRes = await apiRequest("/v1/appStoreVersions", "POST", {
                data: {
                    type: "appStoreVersions",
                    attributes: {
                        platform: "IOS",
                        versionString: newVersionString
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
            targetVersion = newVerRes.data;
            console.log(`${GREEN}✓ 새 버전 ${newVersionString} 생성 완료! (ID: ${targetVersion.id})${RESET}`);
        } else {
            console.log(`\n${YELLOW}⚠️ 현재 'PREPARE_FOR_SUBMISSION' (제출 준비 중) 상태인 버전이 없습니다.${RESET}`);
            console.log(`ℹ️ 최신 버전 목록: ${versionsData.data.map(v => `${v.attributes.versionString} (${v.attributes.appStoreState})`).join(", ")}`);
            console.log(`💡 새 버전을 생성하여 스크린샷을 등록하려면 다음과 같이 실행하세요:`);
            console.log(`   ${GREEN}node scripts/upload_screenshots.js --create-version=1.11${RESET}\n`);
            return;
        }
    }

    console.log(`🚀 대상 버전: ${GREEN}${targetVersion.attributes.versionString}${RESET} (상태: ${targetVersion.attributes.appStoreState})`);

    // 3. 로컬 스크린샷 파일 수집
    const screenshots67Dir = path.join(SCREENSHOTS_DIR, "iphone_67");
    const screenshots65Dir = path.join(SCREENSHOTS_DIR, "iphone_65");

    const files67 = fs.existsSync(screenshots67Dir) 
        ? fs.readdirSync(screenshots67Dir).filter(f => f.endsWith(".png")).sort()
        : [];
    const files65 = fs.existsSync(screenshots65Dir)
        ? fs.readdirSync(screenshots65Dir).filter(f => f.endsWith(".png")).sort()
        : [];

    console.log(`\n📸 업로드 대기 스크린샷:`);
    console.log(`  • 6.7/6.9인치 (Dynamic Island): ${GREEN}${files67.length}장${RESET} (${files67.join(", ")})`);
    console.log(`  • 6.5인치 (Notch):             ${GREEN}${files65.length}장${RESET} (${files65.join(", ")})`);

    if (files67.length === 0 && files65.length === 0) {
        console.log(`${RED}❌ 업로드할 스크린샷이 없습니다. 먼저 ./scripts/capture_screenshots.sh 를 실행하세요.${RESET}`);
        return;
    }

    // 4. 언어별(Localization) 스크린샷 세트 업로드
    const locRes = await apiRequest(`/v1/appStoreVersions/${targetVersion.id}/appStoreVersionLocalizations`);
    const localizations = locRes.data || [];

    for (const loc of localizations) {
        const locale = loc.attributes.locale;
        console.log(`\n${BLUE}------------------------------------------------------------------${RESET}`);
        console.log(`🌐 [언어: ${locale}] 스크린샷 업로드 시작`);
        console.log(`${BLUE}------------------------------------------------------------------${RESET}`);

        // 1) 6.7/6.9인치 규격 (APP_IPHONE_67)
        if (files67.length > 0) {
            console.log(`\n  📱 [규격 1] 6.7/6.9인치 Dynamic Island (APP_IPHONE_67) 처리 중...`);
            const setId67 = await getOrCreateScreenshotSet(loc.id, "APP_IPHONE_67");
            await cleanScreenshotSet(setId67);
            for (const f of files67) {
                await uploadScreenshot(setId67, path.join(screenshots67Dir, f));
            }
        }

        // 2) 6.5인치 규격 (APP_IPHONE_65)
        if (files65.length > 0) {
            console.log(`\n  📱 [규격 2] 6.5인치 Notch (APP_IPHONE_65) 처리 중...`);
            const setId65 = await getOrCreateScreenshotSet(loc.id, "APP_IPHONE_65");
            await cleanScreenshotSet(setId65);
            for (const f of files65) {
                await uploadScreenshot(setId65, path.join(screenshots65Dir, f));
            }
        }

        console.log(`\n${GREEN}✓ [언어: ${locale}] 2대 규격 스크린샷 업로드 완료!${RESET}`);
    }

    console.log(`\n${BLUE}==================================================================${RESET}`);
    console.log(`${GREEN}🎉 모든 필수 2대 규격 스크린샷이 App Store Connect에 정상 등록되었습니다!${RESET}`);
    console.log(`${BLUE}==================================================================${RESET}`);
}

main().catch(err => {
    console.error(`\n${RED}❌ Error:${RESET}`, err.message);
    process.exit(1);
});
