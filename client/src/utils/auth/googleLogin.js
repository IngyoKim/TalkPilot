import { serverLogin } from '@/utils/auth/auth';
import { auth } from '@/utils/auth/firebaseConfig';
import { GoogleAuthProvider, signInWithPopup } from 'firebase/auth';


export const signInWithGoogle = () => {
    return new Promise(async (resolve, reject) => {
        let user;

        try {
            const provider = new GoogleAuthProvider();
            const result = await signInWithPopup(auth, provider);
            user = result.user;
            console.log("[Google] 로그인 성공");
            console.log("[Google] 사용자 정보:", user);
        } catch (e) {
            console.error("[Google] 로그인 실패:", e);
            return reject(e);
        }

        let idToken;
        try {
            idToken = await user.getIdToken();
            console.log("[Google] Firebase ID 토큰:", idToken);
        } catch (e) {
            console.error("[Google] ID 토큰 발급 실패:", e);
            return reject(e);
        }

        try {
            await serverLogin(idToken);
            console.log("[Nest] 서버 로그인 성공");
            resolve(user);
        } catch (e) {
            console.error("[Nest] 서버 인증 실패:", e);
            return reject(e);
        }
    });
};
