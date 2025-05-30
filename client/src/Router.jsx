import { Routes, Route } from "react-router-dom";
import LoginPage from "./pages/LoginPage";
import MainPage from "./pages/MainPage";
import PrivateRoute from "./components/PrivateRoute";

import ProfilePage from './pages/Profile/ProfilePage';
import Help from './pages/Profile/Help';
import Contact from './pages/Profile/Contact';
import CPMtestPage from './pages/Profile/CPMtestPage';

import Schedule from './pages/SidebarOP/Schedule';
import MyPresentation from './pages/SidebarOP/MyPresentation';
import ProjectDetail from './pages/SidebarOP/ProjectDetail';

import ExtractDOCX from './pages/SidebarOP/ExtractDOCX';
import ExtractTXT from './pages/SidebarOP/ExtractTXT';

export default function Router() {
    return (
        <Routes>
            <Route path="/login" element={<LoginPage />} />

            <Route path="/profile" element={<ProfilePage />} />
            <Route path="/help" element={<Help />} />
            <Route path="/contact" element={<Contact />} />
            <Route path="/cpmtest" element={<CPMtestPage />} />

            <Route path="/schedule" element={<Schedule />} />
            <Route path="/presentation" element={<MyPresentation />} />
            <Route path="/project/:id" element={<ProjectDetail />} />

            <Route path="/extdocx" element={<ExtractDOCX />} />
            <Route path="/exttxt" element={<ExtractTXT />} />
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
