import { BrowserRouter } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import { UserProvider } from './contexts/UserContext';
import { ProjectProvider } from './contexts/ProjectContext';
import Router from './Router';

function App() {
  return (
    <AuthProvider>
      <UserProvider>
        <ProjectProvider>
          <BrowserRouter>
            <Router />
          </BrowserRouter>
        </ProjectProvider>
      </UserProvider>
    </AuthProvider>
  );
}

export default App;
