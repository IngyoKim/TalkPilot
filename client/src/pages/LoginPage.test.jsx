import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import LoginPage from './LoginPage';
import * as kakaoLogin from '@/utils/auth/kakaoLogin';
import * as googleLogin from '@/utils/auth/googleLogin';
import { vi } from 'vitest';

const navigateMock = vi.fn();

vi.mock('react-router-dom', async () => {
    const actual = await vi.importActual('react-router-dom');
    return {
        ...actual,
        useNavigate: () => navigateMock,
    };
});

vi.mock('@/utils/auth/kakaoLogin');
vi.mock('@/utils/auth/googleLogin');

vi.mock('firebase/auth', async () => {
    const actual = await vi.importActual('firebase/auth');
    return {
        ...actual,
        getAuth: vi.fn(),
        onAuthStateChanged: vi.fn((auth, callback) => {
            if (globalThis.__shouldAutoLogin) {
                callback({ uid: 'user123' });
            } else {
                callback(null);
            }
            return () => { };
        }),
    };
});

describe('LoginPage', () => {
    beforeEach(() => {
        navigateMock.mockClear();
        globalThis.__shouldAutoLogin = false;
    });

    it('렌더링 확인: 타이틀과 부제목', () => {
        render(<LoginPage />, { wrapper: MemoryRouter });
        expect(screen.getByText('TalkPilot')).toBeInTheDocument();
        expect(screen.getByText(/발표를 더 똑똑하게/)).toBeInTheDocument();
    });

    it('카카오 버튼 클릭 시 로그인 함수 호출', async () => {
        kakaoLogin.signInWithKakao.mockResolvedValue();
        render(<LoginPage />, { wrapper: MemoryRouter });
        const kakaoButton = screen.getByRole('button', { name: /kakao/i });
        fireEvent.click(kakaoButton);
        await waitFor(() => expect(kakaoLogin.signInWithKakao).toHaveBeenCalled());
        expect(navigateMock).toHaveBeenCalledWith('/');
    });

    it('구글 버튼 클릭 시 로그인 함수 호출', async () => {
        googleLogin.signInWithGoogle.mockResolvedValue();
        render(<LoginPage />, { wrapper: MemoryRouter });
        const googleButton = screen.getByRole('button', { name: /google/i });
        fireEvent.click(googleButton);
        await waitFor(() => expect(googleLogin.signInWithGoogle).toHaveBeenCalled());
        expect(navigateMock).toHaveBeenCalledWith('/');
    });

    it('카카오 로그인 실패 시 alert 및 console.error 호출', async () => {
        const alertMock = vi.spyOn(window, 'alert').mockImplementation(() => { });
        const errorMock = vi.spyOn(console, 'error').mockImplementation(() => { });
        kakaoLogin.signInWithKakao.mockRejectedValue(new Error('kakao error'));

        render(<LoginPage />, { wrapper: MemoryRouter });
        fireEvent.click(screen.getByRole('button', { name: /kakao/i }));

        await waitFor(() => {
            expect(alertMock).toHaveBeenCalledWith('Kakao 로그인 실패');
            expect(errorMock).toHaveBeenCalled();
        });

        alertMock.mockRestore();
        errorMock.mockRestore();
    });

    it('구글 로그인 실패 시 alert 및 console.error 호출', async () => {
        const alertMock = vi.spyOn(window, 'alert').mockImplementation(() => { });
        const errorMock = vi.spyOn(console, 'error').mockImplementation(() => { });
        googleLogin.signInWithGoogle.mockRejectedValue(new Error('google error'));

        render(<LoginPage />, { wrapper: MemoryRouter });
        fireEvent.click(screen.getByRole('button', { name: /google/i }));

        await waitFor(() => {
            expect(alertMock).toHaveBeenCalledWith('Google 로그인 실패');
            expect(errorMock).toHaveBeenCalled();
        });

        alertMock.mockRestore();
        errorMock.mockRestore();
    });

    it('로그인된 사용자가 있을 경우 자동으로 "/"로 리다이렉트', () => {
        globalThis.__shouldAutoLogin = true;

        render(<LoginPage />, { wrapper: MemoryRouter });

        expect(navigateMock).toHaveBeenCalledWith('/');
    });
});
