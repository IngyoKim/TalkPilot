import { Routes, Route } from "react-router-dom";
import LoginPage from "./pages/LoginPage";
import MainPage from "./pages/MainPage";
import ProfilePage from "./pages/ProfilePage";
import PrivateRoute from "./components/PrivateRoute";

import AccountDetailPage from './pages/NavBarControls/AccountDetail';
import Setting from './pages/NavBarControls/Setting';
import HelpCenter from './pages/NavBarControls/HelpCenter';
import ContactUs from "./pages/NavBarControls/ContactUs";

export default function Router() {
    return (
        <Routes>
            <Route path="/login" element={<LoginPage />} />

            <Route path="/AccountDetail" element={<AccountDetailPage />} />
            <Route path="/Setting" element={<Setting />} />
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
