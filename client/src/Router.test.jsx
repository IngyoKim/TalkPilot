// Router.test.jsx
import { render, screen } from '@testing-library/react';
import Router from './Router';
import { MemoryRouter } from 'react-router-dom';

// 필요한 컴포넌트 mocking (PrivateRoute, LoginPage 등)
vi.mock('./components/PrivateRoute', () => ({
    default: ({ children }) => children,
}));
vi.mock('./pages/LoginPage', () => ({
    default: () => <div>Login Page</div>,
}));
vi.mock('./pages/MainPage', () => ({
    default: () => <div>Main Page</div>,
}));
vi.mock('./pages/Profile/ProfilePage', () => ({
    default: () => <div>Profile Page</div>,
}));

describe('Router', () => {
    it('"/login" 경로에 LoginPage가 렌더링됨', () => {
        render(
            <MemoryRouter initialEntries={['/login']}>
                <Router />
            </MemoryRouter>
        );
        expect(screen.getByText(/login page/i)).toBeInTheDocument();
    });

    it('"/" 경로에 MainPage가 렌더링됨 (PrivateRoute 통과)', () => {
        render(
            <MemoryRouter initialEntries={['/']}>
                <Router />
            </MemoryRouter>
        );
        expect(screen.getByText(/main page/i)).toBeInTheDocument();
    });

    it('"/profile" 경로에 ProfilePage가 렌더링됨 (PrivateRoute 통과)', () => {
        render(
            <MemoryRouter initialEntries={['/profile']}>
                <Router />
            </MemoryRouter>
        );
        expect(screen.getByText(/profile page/i)).toBeInTheDocument();
    });
});
