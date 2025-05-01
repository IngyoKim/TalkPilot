import { getAuth, signInWithCustomToken } from "firebase/auth";

/// Kakao SDK가 로드되어 있지 않은 경우
/// 동적으로 스크립트를 추가한 후 로그인 시도
export const signInWithKakao = () => {
    return new Promise((resolve, reject) => {
        if (!window.Kakao) {
            const script = document.createElement("script");
            script.src = "https://developers.kakao.com/sdk/js/kakao.js";
            script.onload = () => {
                initializeAndLogin(resolve, reject);
            };
            script.onerror = () => {
                reject("Failed to load Kakao SDK");
            };
            document.head.appendChild(script);
        } else {
            /// Kakao 객체가 이미 존재할 경우 바로 로그인 시도
            initializeAndLogin(resolve, reject);
        }
    });
};

/// Kakao SDK 초기화 후 로그인 수행
async function initializeAndLogin(resolve, reject) {
    if (!window.Kakao.isInitialized()) {
        window.Kakao.init(import.meta.env.VITE_KAKAO_JS_KEY);
        console.log("Kakao SDK initialized");
    }

    // Kakao 로그인 요청
    window.Kakao.Auth.login({
        success: async (authObj) => {
            console.log("Kakao login succeeded\n", authObj);

            try {
                // 사용자 정보 요청
                const userInfo = await window.Kakao.API.request({
                    url: "/v2/user/me",
                });

                // Firebase Function에 전달할 사용자 정보 구성
                const payload = {
                    uid: userInfo.id.toString(),
                    displayName: userInfo.kakao_account?.profile?.nickname || "",
                    email: userInfo.kakao_account?.email || "",
                    photoURL: userInfo.kakao_account?.profile?.profile_image_url || "",
                };

                // 커스텀 토큰 요청
                const response = await fetch(
                    import.meta.env.VITE_FIREBASE_CUSTOM_TOKEN_URL,
                    {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify(payload),
                    }
                );

                const data = await response.json();
                const customToken = data.token;

                if (!customToken) throw new Error("Custom token is empty");

                /// 커스텀 토큰으로 Firebase 로그인 수행
                const auth = getAuth();
                const userCredential = await signInWithCustomToken(auth, customToken);
                resolve(userCredential.user);
            } catch (error) {
                /// Firebase 로그인 실패
                console.error("Failed to sign in with Firebase custom token\n", error);
                reject(error);
            }
        },
        fail(error) {
            /// Kakao 로그인 실패
            console.error("Kakao login failed\n", error);
            reject(error);
        },
    });
}
