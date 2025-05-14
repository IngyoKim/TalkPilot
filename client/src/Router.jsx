import { Routes, Route } from "react-router-dom";
import LoginPage from "./pages/LoginPage";
import MainPage from "./pages/MainPage/MainPage";
import PrivateRoute from "./components/PrivateRoute";

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
        </Routes>
    );
}
