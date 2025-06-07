import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { vi } from 'vitest';

// useNavigate 목킹
const navigateMock = vi.fn();
vi.mock('react-router-dom', async () => {
    const actual = await vi.importActual('react-router-dom');
    return {
        ...actual,
        useNavigate: () => navigateMock,
    };
});

// UserContext 및 logout 목킹
vi.mock('@/contexts/UserContext', () => ({
    useUser: () => ({ user: { name: '테스터', email: 'tester@example.com' } }),
}));
vi.mock('@/utils/auth/auth', () => ({
    logout: vi.fn(() => Promise.resolve()),
}));

// Sidebar만 목킹하여 레이아웃에 영향 없도록
vi.mock('@/components/SideBar', () => ({
    __esModule: true,
    default: () => <div data-testid="mock-sidebar" />,
}));

import Contact from './Contact';

describe('Contact 페이지', () => {
    beforeEach(() => {
        // window.open 스파이
        vi.spyOn(window, 'open').mockImplementation(() => { });
    });
    afterEach(() => {
        vi.restoreAllMocks();
        navigateMock.mockClear();
    });

    test('기본 입력폼 및 버튼 렌더링', () => {
        render(
            <MemoryRouter>
                <Contact />
            </MemoryRouter>
        );
        expect(screen.getByPlaceholderText('이름')).toBeInTheDocument();
        expect(screen.getByPlaceholderText('이메일 주소')).toBeInTheDocument();
        expect(screen.getByPlaceholderText('내용')).toBeInTheDocument();
        expect(screen.getByText('전달하기')).toBeInTheDocument();
    });

    test('OfficeCard 정보 표시 및 위치 확인 버튼 작동', () => {
        render(
            <MemoryRouter>
                <Contact />
            </MemoryRouter>
        );
        expect(screen.getByText(/CheongJu/)).toBeInTheDocument();
        expect(screen.getByText(/충청북도 청주시 서원구 충대로 1 E8-1 어딘가/)).toBeInTheDocument();
        expect(screen.getByText(/010-8120-2338/)).toBeInTheDocument();
        expect(screen.getByText(/\(10AM~5PM 평일\)/)).toBeInTheDocument();
        fireEvent.click(screen.getByText('위치 확인'));
        expect(window.open).toHaveBeenCalledWith(
            expect.stringContaining('google.co.kr/maps'),
            '_blank'
        );
    });

    test('로고 이미지 렌더링 확인', () => {
        render(
            <MemoryRouter>
                <Contact />
            </MemoryRouter>
        );
        const logo = screen.getByAltText('CBNU Logo');
        expect(logo).toBeInTheDocument();
        expect(logo).toHaveAttribute('src', '/assets/CBNU_white.png');
    });

    test('사이드바 토글 시 메인 영역 marginLeft 분기 확인', () => {
        const { container } = render(
            <MemoryRouter>
                <Contact />
            </MemoryRouter>
        );
        // 메인 영역 div 찾기
        const outer = container.firstChild; // <div style={{display:'flex'}}> 
        const mainDiv = outer.querySelector('div');
        // 초기 isSidebarOpen=true -> margin-left:240px
        expect(mainDiv).toHaveStyle({ marginLeft: '240px' });

        const toggleBtn = container.querySelector('div[style*="position: fixed"]');
        expect(toggleBtn).not.toBeNull();
        fireEvent.click(toggleBtn);
        expect(mainDiv).toHaveStyle({ marginLeft: '0px' });
    });
});
