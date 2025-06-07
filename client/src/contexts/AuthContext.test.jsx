import { render, screen, waitFor } from '@testing-library/react';
import { AuthProvider, useAuth } from './AuthContext';
import { vi } from 'vitest';

vi.mock('@/utils/auth/firebaseConfig', () => ({
    auth: {},
}));

vi.mock('firebase/auth', async () => {
    return {
        onAuthStateChanged: (auth, callback) => {
            // mock user 객체
            const user = {
                uid: 'test-uid',
                email: 'test@example.com',
                displayName: '테스트유저',
                photoURL: 'http://photo.url',
                getIdToken: vi.fn().mockResolvedValue('mock-token'),
            };
            setTimeout(() => callback(user), 0);
            return () => { };
        },
    };
});

vi.mock('@/utils/auth/auth', () => ({
    serverLogin: vi.fn(() => Promise.resolve({ role: 'user', nickname: 'tester' })),
}));

function TestComponent() {
    const { authUser, loading, serverError } = useAuth();
    if (loading) return <div>로딩 중</div>;
    if (serverError) return <div>오류 발생</div>;
    return <div>{authUser?.nickname}</div>;
}

test('AuthProvider: 서버 로그인 성공 시 사용자 정보 표시', async () => {
    render(
        <AuthProvider>
            <TestComponent />
        </AuthProvider>
    );

    await waitFor(() => {
        expect(screen.getByText('tester')).toBeInTheDocument();
    });
});
