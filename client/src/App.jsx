import { BrowserRouter } from 'react-router-dom';
import { AuthProvider } from './Contexts/AuthContext';
import { UserProvider } from './Contexts/UserContext';
import { ProjectProvider } from './Contexts/ProjectContext';
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
