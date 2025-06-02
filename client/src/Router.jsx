import { Routes, Route } from "react-router-dom";
import PrivateRoute from "./components/PrivateRoute";

import MainPage from "./pages/MainPage";
import LoginPage from "./pages/LoginPage";

import ProfilePage from './pages/Profile/ProfilePage';
import Help from './pages/Profile/Help';
import Contact from './pages/Profile/Contact';

import Schedule from './pages/SidebarOP/Schedule';
import ProjectDetail from './pages/SidebarOP/ProjectDetail';
import PracticePage from "./pages/PracticePage";

import ExtractTXT from './pages/SidebarOP/ExtractTXT';
import ExtractDOCX from './pages/SidebarOP/ExtractDOCX';

export default function Router() {
    return (
        <Routes>
            <Route path="/login" element={<LoginPage />} />

            <Route path="/help" element={<Help />} />
            <Route path="/contact" element={<Contact />} />

            <Route path="/docx" element={<ExtractDOCX />} />
            <Route path="/txt" element={<ExtractTXT />} />

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
            <Route
                path="/schedule"
                element={
                    <PrivateRoute>
                        <Schedule />
                    </PrivateRoute>
                }
            />
            <Route
                path="/project/:id"
                element={
                    <PrivateRoute>
                        <ProjectDetail />
                    </PrivateRoute>
                }
            />
            <Route
                path="/practice/:id"
                element={
                    <PrivateRoute>
                        <PracticePage />
                    </PrivateRoute>
                }
            />
        </Routes>
    );
}
