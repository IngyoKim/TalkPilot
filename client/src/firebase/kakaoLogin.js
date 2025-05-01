// src/firebase/kakaoLogin.js

export const signInWithKakao = () => {
    return new Promise((resolve, reject) => {
        if (!window.Kakao) {
            reject("Kakao SDK load error");
            return;
        }

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
    });
};
