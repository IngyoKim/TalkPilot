import { Routes, Route } from "react-router-dom";
import LoginPage from "./pages/LoginPage";
import MainPage from "./pages/MainPage";

export default function Router() {
    return (
        <Routes>
            <Route path="/" element={<LoginPage />} />
            <Route path="/main" element={<MainPage />} />
        </Routes>
    );
}
