import { getAuth, signInWithCustomToken } from "firebase/auth";

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
            initializeAndLogin(resolve, reject);
        }
    });
};

async function initializeAndLogin(resolve, reject) {
    if (!window.Kakao.isInitialized()) {
        window.Kakao.init(import.meta.env.VITE_KAKAO_JS_KEY);
        console.log("Kakao SDK initialized");
    }

    window.Kakao.Auth.login({
        success: async (authObj) => {
            console.log("[Kakao] 로그인 성공:", authObj);

            try {
                const userInfo = await window.Kakao.API.request({
                    url: "/v2/user/me",
                });
                console.log("[Kakao] 사용자 정보:", userInfo);

                const payload = {
                    uid: userInfo.id.toString(),
                    displayName: userInfo.kakao_account?.profile?.nickname || "",
                    email: userInfo.kakao_account?.email || "",
                    photoURL: userInfo.kakao_account?.profile?.profile_image_url || "",
                };
                console.log("[Firebase] 전달할 payload:", payload);

                const response = await fetch(
                    import.meta.env.VITE_FIREBASE_CUSTOM_TOKEN_URL,
                    {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify(payload),
                    }
                );
                const data = await response.json();
                console.log("[Firebase] 함수 응답:", data);

                const customToken = data.token;
                if (!customToken) throw new Error("Custom token is empty");

                const auth = getAuth();
                const userCredential = await signInWithCustomToken(auth, customToken);
                console.log("[Firebase] 로그인 성공:", userCredential.user);

                resolve(userCredential.user);
            } catch (error) {
                console.error("[Firebase] 로그인 실패:", error);
                reject(error);
            }
        },
        fail(error) {
            console.error("[Kakao] 로그인 실패:", error);
            reject(error);
        },
    });
}
