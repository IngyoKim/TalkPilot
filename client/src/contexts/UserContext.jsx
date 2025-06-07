import { createContext, useContext, useEffect, useState } from 'react';

import { useAuth } from '@/contexts/AuthContext';
import { fetchUserByUid } from '@/utils/api/user';

const UserContext = createContext(null);

export function UserProvider({ children }) {
    const { authUser } = useAuth();
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        if (!authUser) {
            setUser(null);
            setLoading(false);
            return;
        }

        async function load() {
            setLoading(true);
            try {
                const data = await fetchUserByUid(authUser.uid);
                setUser(data);
            } catch (e) {
                console.error('[UserProvider] 사용자 정보 로딩 실패:', e);
                setUser(null);
            } finally {
                setLoading(false);
            }
        }

        load();
    }, [authUser]);

    return (
        <UserContext.Provider value={{ user, setUser, loading }}>
            {children}
        </UserContext.Provider>
    );
}

export function useUser() {
    return useContext(UserContext);
}
