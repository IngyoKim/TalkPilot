import { render, screen, waitFor } from '@testing-library/react';
import { UserProvider, useUser } from './UserContext';
import { AuthProvider } from './AuthContext';
import { vi } from 'vitest';

vi.mock('@/utils/api/user', () => ({
    fetchUserByUid: vi.fn(() => Promise.resolve({ uid: 'u1', nickname: '사용자1' })),
}));

vi.mock('@/utils/auth/firebaseConfig', () => ({ auth: {} }));
vi.mock('firebase/auth', () => ({
    onAuthStateChanged: (auth, callback) => {
        const user = {
            uid: 'u1',
            email: 'user@ex.com',
            getIdToken: () => Promise.resolve('token'),
        };
        setTimeout(() => callback(user), 0);
        return () => { };
    },
}));

vi.mock('@/utils/auth/auth', () => ({
    serverLogin: () => Promise.resolve({ nickname: '사용자1', role: 'user' }),
}));

function TestComponent() {
    const { user } = useUser();
    return <div>{user?.nickname || '로딩 중'}</div>;
}

test('UserProvider: 유저 정보 불러와서 표시', async () => {
    render(
        <AuthProvider>
            <UserProvider>
                <TestComponent />
            </UserProvider>
        </AuthProvider>
    );

    await waitFor(() => {
        expect(screen.getByText('사용자1')).toBeInTheDocument();
    });
});
