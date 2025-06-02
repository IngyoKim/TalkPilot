import { onAuthStateChanged } from 'firebase/auth';
import { createContext, useContext, useEffect, useState } from 'react';

import { serverLogin } from '@/utils/auth/auth';
import { auth } from '@/utils/auth/firebaseConfig';


const AuthContext = createContext(null);

export function AuthProvider({ children }) {
    const [authUser, setAuthUser] = useState(null);
    const [loading, setLoading] = useState(true);
    const [serverError, setServerError] = useState(null);

    useEffect(() => {
        const unsubscribe = onAuthStateChanged(auth, async (user) => {
            console.log('[Firebase] onAuthStateChanged triggered');
            setLoading(true);
            setServerError(null);

            if (!user) {
                console.log('[Firebase] 로그인 세션 없음');
                setAuthUser(null);
                setLoading(false);
                return;
            }

            console.log(`[Firebase] 로그인 세션 감지됨: ${user.uid}`);

            try {
                const idToken = await user.getIdToken();
                console.log('[Firebase] ID 토큰 발급 성공:', idToken.slice(0, 30) + '...');

                const userData = await serverLogin(idToken);
                console.log('[Nest] 서버 인증 성공');
                console.table({
                    UID: userData.uid,
                    이름: userData.name,
                    프로필: userData.picture,
                });

                setAuthUser(user);
            } catch (e) {
                console.error('[Nest] 서버 인증 실패:', e);
                setAuthUser(null);
                setServerError('서버 인증 실패. 잠시 후 다시 시도해주세요.');
            } finally {
                setLoading(false);
                console.log('[AuthProvider] 인증 흐름 종료 → loading=false');
            }
        });

        return () => {
            unsubscribe();
        };
    }, []);

    return (
        <AuthContext.Provider value={{ authUser, serverError }}>
            {children}
        </AuthContext.Provider>
    );
}

export function useAuth() {
    return useContext(AuthContext);
}
