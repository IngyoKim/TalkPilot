import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

export default function PrivateRoute({ children }) {
    const { authUser } = useAuth();

    if (authUser === null) return <Navigate to="/login" />;
    return children;
}
