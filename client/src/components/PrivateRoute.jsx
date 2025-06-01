import { useEffect, useState } from 'react';
import { Navigate } from 'react-router-dom';
import { onAuthStateChanged } from 'firebase/auth';

import { auth } from '@/utils/auth/firebaseConfig';

export default function PrivateRoute({ children }) {
    const [user, setUser] = useState(undefined);

    useEffect(() => {
        const unsub = onAuthStateChanged(auth, (u) => setUser(u ?? null));
        return () => unsub();
    }, []);

    if (user === undefined) return null;
    return user ? children : <Navigate to="/login" />;
}