import { Routes, Route } from "react-router-dom";
import LoginPage from "./pages/LoginPage";
import MainPage from "./pages/MainPage";
import PrivateRoute from "./components/PrivateRoute";

import ProfilePage from './pages/Profile/ProfilePage';
import Help from './pages/Profile/Help';
import Contact from "./pages/Profile/Contact";

export default function Router() {
    return (
        <Routes>
            <Route path="/login" element={<LoginPage />} />

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
            <Route path="/help" element={<Help />} />
            <Route path="/contact" element={<Contact />} />
        </Routes>
    );
}
