export const signInWithKakao = () => {
    return new Promise((resolve, reject) => {
        // Kakao SDK가 없는 경우, 동적으로 로드
        if (!window.Kakao) {
            const script = document.createElement("script");
            script.src = "https://developers.kakao.com/sdk/js/kakao.js";
            script.onload = () => {
                initializeAndLogin(resolve, reject);
            };
            script.onerror = () => {
                reject("Kakao SDK 로드 실패");
            };
            document.head.appendChild(script);
        } else {
            // 이미 로드된 경우
            initializeAndLogin(resolve, reject);
        }
    });
};

function initializeAndLogin(resolve, reject) {
    if (!window.Kakao.isInitialized()) {
        window.Kakao.init(import.meta.env.VITE_KAKAO_JS_KEY);
        console.log("Kakao SDK 초기화 완료");
    }

    window.Kakao.Auth.login({
        success(authObj) {
            console.log("카카오 로그인 성공:", authObj);
            resolve(authObj);
        },
        fail(error) {
            console.error("카카오 로그인 실패:", error);
            reject(error);
        },
    });
}
