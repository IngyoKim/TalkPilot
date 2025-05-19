import { Routes, Route } from "react-router-dom";
import LoginPage from "./pages/LoginPage";
import MainPage from "./pages/MainPage";
import PrivateRoute from "./components/PrivateRoute";

import ProfilePage from './pages//Profile/ProfilePage';
import HelpCenter from './pages/Profile/HelpCenter';
import ContactUs from "./pages/Profile/ContactUs";

export default function Router() {
    return (
        <Routes>
            <Route path="/login" element={<LoginPage />} />

            <Route path="/ProfilePage" element={<ProfilePage />} />
            <Route path="/HelpCenter" element={<HelpCenter />} />
            <Route path="/ContactUs" element={<ContactUs />} />

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
