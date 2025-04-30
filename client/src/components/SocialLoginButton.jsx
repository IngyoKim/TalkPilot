// src/components/SocialLoginButton.jsx
import React from "react";

export default function SocialLoginButton({ provider, onClick }) {
    const styles = {
        google: {
            backgroundColor: "#ffffff",
            color: "#000000",
            border: "1px solid #dddddd",
            logo: "/assets/logo/google_logo.png",
            text: "구글 계정으로 로그인",
        },
        kakao: {
            backgroundColor: "#FEE500",
            color: "#000000",
            border: "none",
            logo: "/assets/logo/kakao_logo.png",
            text: "카카오 계정으로 로그인",
        },
    };

    const style = styles[provider];

    if (!style) {
        console.error(`SocialLoginButton: 잘못된 provider 값 "${provider}"`);
        return null;
    }

    return (
        <button
            onClick={onClick}
            style={{
                display: "flex",
                alignItems: "center",
                gap: "12px",
                width: "100%",
                padding: "12px",
                marginTop: "12px",
                borderRadius: "6px",
                fontWeight: "bold",
                fontSize: "16px",
                border: style.border,
                backgroundColor: style.backgroundColor,
                color: style.color,
            }}
        >
            <img
                src={style.logo}
                alt={`${provider} logo`}
                style={{ width: "24px", height: "24px" }}
            />
            <span>{style.text}</span>
        </button>
    );
}
