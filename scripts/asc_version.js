/**
 * App Store Connect 버전 레코드 보조 모듈 (update_release_notes.js / submit_for_review.js 공용)
 *
 * 새 마케팅 버전(예: 1.11)의 빌드를 처음 업로드하면 App Store Connect 에는 아직 그 버전의
 * "앱 버전 레코드" 가 없다 (이전 버전은 READY_FOR_SALE 상태). 릴리즈 노트 갱신과 심사 제출은
 * PREPARE_FOR_SUBMISSION 상태의 버전이 있어야 하므로, 없으면 여기서 생성한다.
 */
const fs = require("fs");
const path = require("path");

/** 마케팅 버전: 1) 환경변수 MARKETING_VERSION  2) project.pbxproj 의 앱 타겟 값(1.0 이 아닌 첫 값) */
function getMarketingVersion() {
    if (process.env.MARKETING_VERSION) return process.env.MARKETING_VERSION.trim();
    const pbx = path.resolve(__dirname, "..", "nba.xcodeproj", "project.pbxproj");
    const text = fs.readFileSync(pbx, "utf8");
    const versions = [...text.matchAll(/MARKETING_VERSION = ([0-9.]+);/g)].map(m => m[1]);
    const appVersion = versions.find(v => v !== "1.0") || versions[0];
    if (!appVersion) throw new Error("project.pbxproj 에서 MARKETING_VERSION 을 찾지 못했습니다.");
    return appVersion;
}

/**
 * PREPARE_FOR_SUBMISSION 상태의 버전을 반환. 없으면 현재 마케팅 버전으로 새 버전을 생성해 반환.
 * 같은 버전 문자열이 다른 상태(심사 중 등)로 이미 있으면 생성하지 않고 null 반환.
 */
async function ensurePrepareForSubmissionVersion(apiRequest, appId) {
    const versionsData = await apiRequest(`/v1/apps/${appId}/appStoreVersions?filter[platform]=IOS`);
    const existing = versionsData.data.find(v => v.attributes.appStoreState === "PREPARE_FOR_SUBMISSION");
    if (existing) return existing;

    const marketingVersion = getMarketingVersion();
    const sameVersion = versionsData.data.find(v => v.attributes.versionString === marketingVersion);
    if (sameVersion) {
        console.log(`⚠️ 버전 ${marketingVersion} 이(가) 이미 '${sameVersion.attributes.appStoreState}' 상태로 존재합니다. 새로 만들지 않습니다.`);
        return null;
    }

    console.log(`🆕 App Store Connect 에 버전 ${marketingVersion} 레코드가 없어 새로 생성합니다...`);
    const created = await apiRequest("/v1/appStoreVersions", "POST", {
        data: {
            type: "appStoreVersions",
            attributes: { platform: "IOS", versionString: marketingVersion },
            relationships: { app: { data: { type: "apps", id: appId } } },
        },
    });
    console.log(`✅ 버전 ${marketingVersion} 생성 완료 (ID: ${created.data.id}, 상태: ${created.data.attributes.appStoreState})`);
    return created.data;
}

module.exports = { getMarketingVersion, ensurePrepareForSubmissionVersion };
