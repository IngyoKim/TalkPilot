import { BrowserRouter } from 'react-router-dom';
import { AuthProvider } from './Contexts/AuthContext';
import { UserProvider } from './contexts/UserContext';
import { ProjectProvider } from './Contexts/ProjectContext';
import Router from './Router';

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
