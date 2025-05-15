import React, { useEffect } from "react";
import { getAuth, onAuthStateChanged } from "firebase/auth";
import { signInWithGoogle } from "../utils/auth/googleLogin";
import { signInWithKakao } from "../utils/auth/kakaoLogin";
import SocialLoginButton from "../components/SocialLoginButton";
import { useNavigate } from "react-router-dom";

export default function LoginPage() {
    const navigate = useNavigate();

    // 이미 로그인된 경우 /로 리다이렉트
    useEffect(() => {
        const unsub = onAuthStateChanged(getAuth(), (user) => {
            if (user) {
                navigate("/");
            }
        });
        return () => unsub();
    }, [navigate]);

    const handleKakaoLogin = async () => {
        try {
            await signInWithKakao();
            navigate("/");
        } catch (err) {
            alert("Kakao 로그인 실패");
            console.error(err);
        }
    };

    const handleGoogleLogin = async () => {
        try {
            await signInWithGoogle();
            navigate("/");
        } catch (err) {
            alert("Google 로그인 실패");
            console.error(err);
        }
    };

    return (
        <div style={styles.container}>
            <h1 style={styles.title}>TalkPilot</h1>
            <p style={styles.subtitle}>발표를 더 똑똑하게, 함께 준비해요.</p>

            <div style={styles.loginBox}>
                <SocialLoginButton provider="kakao" onClick={handleKakaoLogin} />
                <SocialLoginButton provider="google" onClick={handleGoogleLogin} />
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
