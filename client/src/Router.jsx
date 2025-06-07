import { Routes, Route } from "react-router-dom";
import PrivateRoute from "./components/PrivateRoute";

import MainPage from "./pages/MainPage";
import LoginPage from "./pages/LoginPage";

import ProfilePage from './pages/Profile/ProfilePage';
import Help from './pages/Sidebar/Help';
import Contact from './pages/Sidebar/Contact';

import CPMtestPage from './pages/Profile/CPMtestPage';
import STTtest from './pages/Profile/STTtest';
import ProjectRecord from './pages/Profile/ProjectRecord';

import Schedule from './pages/Sidebar/Schedule';
import ProjectPage from './pages/Sidebar/ProjectPage';
import PracticePage from "./pages/PracticePage";
import ResultPage from "./pages/ResultPage";

import ExtractTXT from './pages/Sidebar/ExtractTXT';
import ExtractDOCX from './pages/Sidebar/ExtractDOCX';
import Credit from "./pages/Profile/Credit";
import AppDownload from "./pages/Sidebar/AppDownload";

export default function Router() {
    return (
        <Routes>
            <Route path="/login" element={<LoginPage />} />

            <Route path="/help" element={<Help />} />
            <Route path="/contact" element={<Contact />} />
            <Route path="/credits" element={<Credit />} />
            <Route path="/download" element={<AppDownload />} />

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
