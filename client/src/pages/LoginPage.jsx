import React from "react";
import { useNavigate } from "react-router-dom";
import { getAuth } from "firebase/auth";
import { signInWithGoogle } from "../firebase/googleLogin";
import { signInWithKakao } from "../firebase/kakaoLogin";
import SocialLoginButton from "../components/SocialLoginButton";

export default function LoginPage() {
    const navigate = useNavigate();

    const handleGoogleLogin = async () => {
        try {
            const user = await signInWithGoogle();
            console.log("로그인된 사용자:", user.displayName);
            navigate("/main");
            console.log("[Google] 로그인 성공");
            console.log("[Google] 사용자 정보:", user);

            const idToken = await user.getIdToken();

            const res = await fetch("http://localhost:3000/me", {
                headers: {
                    Authorization: `Bearer ${idToken}`,
                },
            });

            const userData = await res.json();

            console.log("[Nest] 사용자 정보 수신 완료");
            console.table({
                UID: userData.uid,
                이름: userData.name,
                프로필: userData.picture,
            });
        } catch (error) {
            alert("Google 로그인 실패");
            console.error("[Google] 로그인 에러\n", error);
        }
    };

    const handleKakaoLogin = async () => {
        try {
            const authObj = await signInWithKakao();
            console.log("Kakao 로그인 성공:", authObj);
            navigate("/main");
            console.log("[Kakao] 로그인 성공");
            console.log("[Kakao] 액세스 정보:", authObj);

            const user = getAuth().currentUser;
            if (!user) throw new Error("Firebase 사용자 정보 없음");

            const idToken = await user.getIdToken();

            const res = await fetch("http://localhost:3000/me", {
                headers: {
                    Authorization: `Bearer ${idToken}`,
                },
            });

            const userData = await res.json();

            console.log("[Nest] 사용자 정보 수신 완료");
            console.table({
                UID: userData.uid,
                이름: userData.name,
                프로필: userData.picture,
            });
        } catch (error) {
            alert("카카오 로그인 실패");
            console.error("[Kakao] 로그인 에러\n", error);
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
