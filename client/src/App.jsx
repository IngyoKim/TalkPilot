import Router from '@/Router';
import { BrowserRouter } from 'react-router-dom';
import { AuthProvider } from '@/contexts/AuthContext';
import { UserProvider } from '@/contexts/UserContext';

function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <UserProvider>
          <Router />
        </UserProvider>
      </AuthProvider>
    </BrowserRouter>
  );
}

export default App;