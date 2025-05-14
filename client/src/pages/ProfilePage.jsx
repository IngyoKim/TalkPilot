import React from "react";
import { getAuth, signOut } from "firebase/auth";
import { useNavigate } from "react-router-dom";

export default function ProfilePage() {
    const navigate = useNavigate();

    const handleLogout = async () => {
        try {
            await signOut(getAuth());
            console.log("로그아웃 성공");
            navigate("/login");
        } catch (err) {
            console.error("로그아웃 실패", err);
            alert("로그아웃 중 오류가 발생했습니다.");
        }
    };

    return (
        <div style={styles.container}>
            <h2 style={styles.title}>내 프로필</h2>
            <button style={styles.logoutButton} onClick={handleLogout}>
                로그아웃
            </button>
        </div>
    );
}

const styles = {
    container: {
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        height: "100vh",
        backgroundColor: "#f7f7f7",
    },
    title: {
        fontSize: "24px",
        marginBottom: "16px",
        color: "#333",
    },
    logoutButton: {
        padding: "12px 24px",
        backgroundColor: "#e53935",
        color: "#fff",
        border: "none",
        borderRadius: "8px",
        fontSize: "16px",
        cursor: "pointer",
    },
};
