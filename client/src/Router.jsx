import { Routes, Route } from 'react-router-dom';
import LoginPage from './pages/LoginPage';
import AuthGate from './pages/AuthGate';

function Router() {
    return (
        <Routes>
            <Route path="/login" element={<LoginPage />} />
            <Route path="/*" element={<AuthGate />} />
        </Routes>
    );
}

export default Router;
