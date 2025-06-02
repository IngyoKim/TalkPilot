import { auth } from '@/utils/auth/firebaseConfig';
import { signOut, getAuth } from "firebase/auth";

const API_BASE_URL = import.meta.env.VITE_SERVER_URL;

/// Nest Server 인증 로직
export const serverLogin = async (idToken) => {
    const res = await fetch(`${API_BASE_URL}/me`, {
        headers: {
            Authorization: `Bearer ${idToken}`,
        },
    });

    if (!res.ok) throw new e("서버에서 사용자 정보 조회 실패");

    const userData = await res.json();
    console.log("[Nest] 사용자 정보 수신 완료:");
    return userData;
};

/// Firebase 로그아웃 로직(공통 로그아웃)
export const logout = async () => {
    try {
        await signOut(auth);
        console.log("[Firebase] 로그아웃 완료");
    } catch (e) {
        console.error("로그아웃 실패", e);
    }
};

/// Firebase에서 uid를 가져옴
export const getCurrentUid = () => {
    const user = getAuth().currentUser;
    if (!user) throw new error("로그인된 사용자가 없습니다.");
    return user.uid;
};

/// Firebase에서 Id token을 가져옴
export const getIdToken = async () => {
    const user = getAuth().currentUser;
    if (!user) throw new error('로그인된 사용자가 없습니다.');
    return await user.getIdToken();
};