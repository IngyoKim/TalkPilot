import React from "react";
import SocialLoginButton from "../components/SocialLoginButton";

export default function LoginPage() {
    const handleGoogleLogin = () => {
        /// 구글 로그인 로직 구현 예정
        console.log("구글 로그인 클릭");
    };

    const handleKakaoLogin = () => {
        /// 카카오 로그인 로직 구현 예정
        console.log("카카오 로그인 클릭");
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
