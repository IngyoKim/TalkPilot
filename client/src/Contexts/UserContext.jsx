import { createContext, useContext, useEffect, useState } from 'react';
import { getCurrentUid } from '../utils/auth/auth';
import { fetchUserByUid } from '../utils/api/user';

const UserContext = createContext(null);

export function UserProvider({ children }) {
    const [user, setUser] = useState(null);

    useEffect(() => {
        async function load() {
            try {
                const uid = await getCurrentUid();
                const data = await fetchUserByUid(uid);
                setUser(data);
            } catch (error) {
                console.error('[UserProvider] 사용자 정보 로딩 실패:', error);
            }
        }
        load();
    }, []);

    return (
        <UserContext.Provider value={{ user, setUser }}>
            {children}
        </UserContext.Provider>
    );
}

export function useUser() {
    return useContext(UserContext);
}
