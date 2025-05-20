import { createContext, useContext, useEffect, useState } from 'react';
import { useAuth } from './AuthContext';
import { fetchUserByUid } from '../utils/api/user';

const UserContext = createContext(null);

export function UserProvider({ children }) {
    const { authUser } = useAuth();
    const [user, setUser] = useState(null);

    useEffect(() => {
        if (!authUser) return;

        async function load() {
            try {
                const data = await fetchUserByUid(authUser.uid);
                setUser(data);
            } catch (error) {
                console.error('[UserProvider] 사용자 정보 로딩 실패:', error);
            }
        }

        load();
    }, [authUser]);

    return (
        <UserContext.Provider value={{ user, setUser }}>
            {children}
        </UserContext.Provider>
    );
}

export function useUser() {
    return useContext(UserContext);
}
