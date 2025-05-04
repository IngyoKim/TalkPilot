import React from "react";
import { signInWithGoogle } from "../firebase/googleLogin";
import { signInWithKakao } from "../firebase/kakaoLogin";
import SocialLoginButton from "../components/SocialLoginButton";

export default function LoginPage() {
    const handleGoogleLogin = async () => {
        try {
            const user = await signInWithGoogle();
            console.log("로그인된 사용자:", user.displayName);
            /// 로그인 상태 저장, 페이지 이동 등 추가해야함.
        } catch (error) {
            alert("Google 로그인 실패");
            console.error("Google 로그인 에러:", error);
        }
    };


    const handleKakaoLogin = async () => {
        try {
            const authObj = await signInWithKakao();
            console.log("Kakao 로그인 성공:", authObj);
            /// 로그인 상태 저장, 페이지 이동 등 추가해야함.
        } catch (error) {
            alert("카카오 로그인 실패");
            console.error("Kakao 로그인 에러:", error);
        }
    };

    return (
        <div style={styles.container}>
            <h1 style={styles.title}>TalkPilot</h1>
            <p style={styles.subtitle}>발표를 더 똑똑하게, 함께 준비해요.</p>

            <div style={styles.loginBox}>
                <SocialLoginButton provider="google" onClick={handleGoogleLogin} />
                <SocialLoginButton provider="kakao" onClick={handleKakaoLogin} />
            </div>
        </div>
    );
}

const styles = {
    container: {
        height: "100vh",
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
        alignItems: "center",
        backgroundColor: "#f7f7f7",
    },
    title: {
        fontSize: "32px",
        fontWeight: "bold",
        marginBottom: "8px",
    },
    subtitle: {
        fontSize: "16px",
        color: "#555",
        marginBottom: "24px",
    },
    loginBox: {
        width: "280px",
    },
};
