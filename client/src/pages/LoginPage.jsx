import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { getAuth, onAuthStateChanged } from 'firebase/auth';

import { signInWithKakao } from '@/utils/auth/kakaoLogin';
import { signInWithGoogle } from '@/utils/auth/googleLogin';

import SocialLoginButton from '@/components/SocialLoginButton';


export default function LoginPage() {
    const navigate = useNavigate();

    /// 이미 로그인된 경우 `/`(MainPage)로 리다이렉트
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
        } catch (e) {
            alert("Kakao 로그인 실패");
            console.error(e);
        }
    };

    const handleGoogleLogin = async () => {
        try {
            await signInWithGoogle();
            navigate("/");
        } catch (e) {
            alert("Google 로그인 실패");
            console.error(e);
        }
    };

    return (
        <div style={styles.container}>
            <img
                src="/assets/logo.png"
                alt="TalkPilot Logo"
                style={styles.logo}
            />
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
    logo: {
        width: '180px',
        height: 'auto',
        marginBottom: '20px',
        objectFit: 'contain',
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
