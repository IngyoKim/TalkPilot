import { Routes, Route } from "react-router-dom";
import PrivateRoute from "./components/PrivateRoute";

import MainPage from "./pages/MainPage";
import LoginPage from "./pages/LoginPage";

import ProfilePage from './pages/Profile/ProfilePage';
import Help from './pages/Profile/Help';
import Contact from './pages/Profile/Contact';

import CPMtestPage from './pages/Profile/CPMtestPage';
import STTtest from './pages/Profile/STTtest';
import ProjectRecord from './pages/Profile/ProjectRecord';

import Schedule from './pages/SidebarOP/Schedule';
import ProjectPage from './pages/SidebarOP/ProjectPage';
import PracticePage from "./pages/PracticePage";
import ResultPage from "./pages/ResultPage";

import ExtractTXT from './pages/SidebarOP/ExtractTXT';
import ExtractDOCX from './pages/SidebarOP/ExtractDOCX';
import Credit from "./pages/Profile/Credit";

export default function Router() {
    return (
        <Routes>
            <Route path="/login" element={<LoginPage />} />

            <Route path="/help" element={<Help />} />
            <Route path="/contact" element={<Contact />} />
            <Route path="/credits" element={<Credit />} />

            <Route path="/cpmtest" element={<CPMtestPage />} />
            <Route path="/stttest" element={<STTtest />} />
            <Route path="/projectrecord" element={<ProjectRecord />} />

            <Route path="/schedule" element={<Schedule />} />
            <Route path="/project/:id" element={<ProjectPage />} />

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
                        <ProjectPage />
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
            <Route
                path="/result/:id"
                element={
                    <PrivateRoute>
                        <ResultPage />
                    </PrivateRoute>
                }
            />
        </Routes>
    );
}
