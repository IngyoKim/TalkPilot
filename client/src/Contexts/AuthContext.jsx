import { createContext } from 'react';

const AuthContext = createContext();

export function AuthProvider({ children }) {
    return (
        <AuthContext.Provider value={{}}>
            {children}
        </AuthContext.Provider>
    );
}

export default AuthContext;
