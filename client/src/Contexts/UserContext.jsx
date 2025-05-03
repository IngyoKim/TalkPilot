import { createContext } from 'react';

const UserContext = createContext();

export function UserProvider({ children }) {
    return (
        <UserContext.Provider value={{}}>
            {children}
        </UserContext.Provider>
    );
}

export default UserContext;
