import { Routes, Route } from "react-router-dom";
import LoginPage from "./pages/LoginPage";
import MainPage from "./pages/MainPage";
import ProfilePage from "./pages/ProfilePage";
import PrivateRoute from "./components/PrivateRoute";

import AccountDetailPage from './components/Navigations/AccountDetail';

export default function Router() {
    return (
        <Routes>
            <Route path="/login" element={<LoginPage />} />
            <Route path="/AccountDetail" element={<AccountDetailPage />} />
            <Route
                path="/"
                element={
                    <PrivateRoute>
                        <MainPage />
                    </PrivateRoute>
                }
            />
            <Route
                path="/profile"
                element={
                    <PrivateRoute>
                        <ProfilePage />
                    </PrivateRoute>
                }
            />
        </Routes>
    );
}
