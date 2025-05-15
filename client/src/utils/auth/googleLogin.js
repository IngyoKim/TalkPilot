import { serverLogin } from "./auth";
import { auth } from "./firebaseConfig";
import { GoogleAuthProvider, signInWithPopup } from "firebase/auth";

export const signInWithGoogle = async () => {
    try {
        const provider = new GoogleAuthProvider();
        const result = await signInWithPopup(auth, provider);
        const user = result.user;
        console.log("[Google] 로그인 성공");
        console.log("[Google] 사용자 정보:", user);

        const idToken = await user.getIdToken();
        console.log("[Google] Firebase ID 토큰:", idToken);

        await serverLogin(idToken);

        return user;
    } catch (error) {
        console.error("[Google] 로그인 전체 실패", error);
        throw error;
    }
};