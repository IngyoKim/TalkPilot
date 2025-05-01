import { GoogleAuthProvider, signInWithPopup } from "firebase/auth";
import { auth } from "./firebaseConfig";

const provider = new GoogleAuthProvider();

export const signInWithGoogle = async () => {
    try {
        const result = await signInWithPopup(auth, provider);
        const user = result.user;
        console.log("Google 로그인 성공:", user);
        return user;
    } catch (error) {
        console.error("Google 로그인 에러:", error);
        throw error;
    }
};
