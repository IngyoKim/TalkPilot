import Router from './Router';
import { useEffect } from 'react';
import { BrowserRouter } from 'react-router-dom';
import { AuthProvider } from './Contexts/AuthContext';
import { UserProvider } from './Contexts/UserContext';
import { ProjectProvider } from './Contexts/ProjectContext';

import { serverLogin } from "./utils/auth/auth";
import { getAuth, onAuthStateChanged } from "firebase/auth";

function App() {
  useEffect(() => {
    const unsub = onAuthStateChanged(getAuth(), async (user) => {
      if (user) {
        console.log("[Firebase] 로그인 세션 복원됨 (자동 로그인)");
        try {
          const idToken = await user.getIdToken();
          await serverLogin(idToken);
        } catch (error) {
          console.error("[Nest] 자동 로그인 후 서버 인증 실패", error);
        }
      }
    });

    return () => unsub();
  }, []);

  return (
    <BrowserRouter>
      <AuthProvider>
        <UserProvider>
          <ProjectProvider>
            <Router />
          </ProjectProvider>
        </UserProvider>
      </AuthProvider>
    </BrowserRouter>
  );
}

export default App;
