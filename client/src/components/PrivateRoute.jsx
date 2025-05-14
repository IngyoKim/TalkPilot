import { getAuth, onAuthStateChanged } from "firebase/auth";
import { Navigate } from "react-router-dom";
import { useEffect, useState } from "react";

export default function PrivateRoute({ children }) {
    const [user, setUser] = useState(undefined);
    const auth = getAuth();

    useEffect(() => {
        const unsub = onAuthStateChanged(auth, (u) => setUser(u ?? null));
        return () => unsub();
    }, [auth]);

    if (user === undefined) return null; // 로딩 중
    return user ? children : <Navigate to="/login" />;
}
