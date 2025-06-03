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
            setLoading(true);
            setServerError(null);

            if (!user) {
                setAuthUser(null);
                setLoading(false);
                return;
            }

            try {
                const idToken = await user.getIdToken();
                const userData = await serverLogin(idToken);

                setAuthUser({
                    uid: user.uid,
                    email: user.email,
                    displayName: user.displayName,
                    photoURL: user.photoURL,
                    token: idToken,
                    ...userData,
                });
            } catch (e) {
                setAuthUser(null);
                setServerError('서버 인증 실패');
            } finally {
                setLoading(false);
            }
        });

        return () => unsubscribe();
    }, []);

    return (
        <AuthContext.Provider value={{ authUser, loading, serverError }}>
            {children}
        </AuthContext.Provider>
    );
}

export function useAuth() {
    return useContext(AuthContext);
}