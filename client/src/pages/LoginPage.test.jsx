import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import LoginPage from '@/pages/LoginPage';
import * as kakaoLogin from '@/utils/auth/kakaoLogin';
import * as googleLogin from '@/utils/auth/googleLogin';

vi.mock('@/utils/auth/kakaoLogin');
vi.mock('@/utils/auth/googleLogin');


describe('LoginPage', () => {
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
        expect(kakaoLogin.signInWithKakao).toHaveBeenCalled();
    });

    it('구글 버튼 클릭 시 로그인 함수 호출', async () => {
        googleLogin.signInWithGoogle.mockResolvedValue();
        render(<LoginPage />, { wrapper: MemoryRouter });
        const googleButton = screen.getByRole('button', { name: /google/i });
        fireEvent.click(googleButton);
        expect(googleLogin.signInWithGoogle).toHaveBeenCalled();
    });
});
