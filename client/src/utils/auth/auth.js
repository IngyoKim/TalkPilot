import { signOut } from "firebase/auth";
import { auth } from "./firebaseConfig";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;

/// Nest Server 인증 로직
export const serverLogin = async (idToken) => {
    const res = await fetch(`${API_BASE_URL}/me`, {
        headers: {
            Authorization: `Bearer ${idToken}`,
        },
    });

    if (!res.ok) throw new Error("서버에서 사용자 정보 조회 실패");

    const userData = await res.json();
    console.log("[Nest] 사용자 정보 수신 완료:");
    console.table({
        UID: userData.uid,
        이름: userData.name,
        프로필: userData.picture,
    });
    return userData;
};

/// Firebase 로그아웃 로직(공통 로그아웃)
export const logout = async () => {
    try {
        await signOut(auth);
        console.log("[Firebase] 로그아웃 완료");
    } catch (error) {
        console.error("로그아웃 실패", error);
    }
};