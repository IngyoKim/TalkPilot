import Router from '@/Router';
import { BrowserRouter } from 'react-router-dom';
import { AuthProvider } from '@/contexts/AuthContext';
import { UserProvider } from '@/contexts/UserContext';
import { ProjectProvider } from '@/contexts/ProjectContext';

function App() {
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