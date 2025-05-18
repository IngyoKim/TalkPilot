import { serverLogin } from "./auth";
import { getAuth, signInWithCustomToken } from "firebase/auth";

const TOKEN_URL = import.meta.env.VITE_FIREBASE_CUSTOM_TOKEN_URL;

export const signInWithKakao = () => {
    return new Promise((resolve, reject) => {
        if (!window.Kakao) {
            const script = document.createElement("script");
            script.src = "https://developers.kakao.com/sdk/js/kakao.js";
            script.onload = () => initializeAndLogin(resolve, reject);
            script.onerror = () => reject("Kakao SDK 로드 실패");
            document.head.appendChild(script);
        } else {
            initializeAndLogin(resolve, reject);
        }
    });
};

async function initializeAndLogin(resolve, reject) {
    if (!window.Kakao.isInitialized()) {
        window.Kakao.init(import.meta.env.VITE_KAKAO_JS_KEY);
        console.log("[Kakao] SDK 초기화 완료");
    }

    window.Kakao.Auth.login({
        success: async () => {
            let userInfo;

            try {
                console.log("[Kakao] 로그인 시도");
                userInfo = await window.Kakao.API.request({ url: "/v2/user/me" });
                console.log("[Kakao] 사용자 정보:", userInfo);
            } catch (error) {
                console.error("[Kakao] 로그인 실패:", error);
                return reject(error);
            }

            let token;
            try {
                const payload = {
                    uid: userInfo.id.toString(),
                    displayName: userInfo.kakao_account?.profile?.nickname || "",
                    email: userInfo.kakao_account?.email || "",
                    photoURL: userInfo.kakao_account?.profile?.profile_image_url || "",
                };
                console.log("[Firebase] 전달할 payload:", payload);

                const tokenRes = await fetch(TOKEN_URL, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(payload),
                });

                if (!tokenRes.ok) {
                    const text = await tokenRes.text();
                    throw new Error(`Token fetch 실패: ${text}`);
                }

                const json = await tokenRes.json();
                token = json.token;
                if (!token) throw new Error("커스텀 토큰이 비어 있음");

                console.log("[Firebase] 커스텀 토큰 수신 완료");
            } catch (error) {
                console.error("[Firebase] 커스텀 토큰 생성 실패:", error);
                return reject(error);
            }

            let firebaseUser;
            try {
                const auth = getAuth();
                const userCredential = await signInWithCustomToken(auth, token);
                firebaseUser = userCredential.user;
                console.log("[Firebase] 로그인 성공:", firebaseUser);
            } catch (error) {
                console.error("[Firebase] 로그인 실패:", error);
                return reject(error);
            }

            try {
                const idToken = await firebaseUser.getIdToken();
                console.log("[Firebase] ID 토큰 발급 완료:", idToken);

                await serverLogin(idToken);
                console.log("[Nest] 서버 로그인 성공");
                resolve(firebaseUser);
            } catch (error) {
                console.error("[Nest] 서버 인증 실패:", error);
                reject(error);
            }
        },
        fail: (error) => {
            console.error("[Kakao] 로그인 실패", error);
            reject(error);
        },
    });
}