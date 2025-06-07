import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { vi } from 'vitest';
import { logout } from '@/utils/auth/auth';

// useRef 목킹으로 menuRef 분기 커버
const fakeRef = { current: null };
vi.mock('react', async () => {
    const actual = await vi.importActual('react');
    return {
        ...actual,
        useRef: () => fakeRef,
    };
});

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
vi.mock('@/utils/auth/auth', () => ({ logout: vi.fn(() => Promise.resolve()) }));

import ProfileDropdown from './ProfileDropdown';

test('ProfileDropdown 메뉴 클릭 시 사용자 정보 표시', () => {
    render(
        <MemoryRouter>
            <ProfileDropdown isSidebarOpen={true} onToggleSidebar={() => { }} />
        </MemoryRouter>
    );
    fireEvent.click(screen.getByTestId('profile-icon'));
    expect(screen.getByText('테스터')).toBeInTheDocument();
    expect(screen.getByText('tester@example.com')).toBeInTheDocument();
});

test('Account Detail 클릭 시 /profile로 이동', () => {
    render(
        <MemoryRouter>
            <ProfileDropdown isSidebarOpen={true} onToggleSidebar={() => { }} />
        </MemoryRouter>
    );
    fireEvent.click(screen.getByTestId('profile-icon'));
    fireEvent.click(screen.getByText('Account Detail'));
    expect(navigateMock).toHaveBeenCalledWith('/profile');
});

test('Help 클릭 시 /help로 이동', () => {
    render(
        <MemoryRouter>
            <ProfileDropdown isSidebarOpen={true} onToggleSidebar={() => { }} />
        </MemoryRouter>
    );
    fireEvent.click(screen.getByTestId('profile-icon'));
    fireEvent.click(screen.getByText('Help'));
    expect(navigateMock).toHaveBeenCalledWith('/help');
});

test('Contact us 클릭 시 /contact로 이동', () => {
    render(
        <MemoryRouter>
            <ProfileDropdown isSidebarOpen={true} onToggleSidebar={() => { }} />
        </MemoryRouter>
    );
    fireEvent.click(screen.getByTestId('profile-icon'));
    fireEvent.click(screen.getByText('Contact us'));
    expect(navigateMock).toHaveBeenCalledWith('/contact');
});

test('Log Out 클릭 시 confirm 후 logout 호출 및 /login으로 이동', async () => {
    const confirmSpy = vi.spyOn(window, 'confirm').mockReturnValue(true);
    render(
        <MemoryRouter>
            <ProfileDropdown isSidebarOpen={true} onToggleSidebar={() => { }} />
        </MemoryRouter>
    );
    fireEvent.click(screen.getByTestId('profile-icon'));
    fireEvent.click(screen.getByText('Log Out'));
    expect(confirmSpy).toHaveBeenCalled();
    await waitFor(() => {
        expect(logout).toHaveBeenCalled();
        expect(navigateMock).toHaveBeenCalledWith('/login');
    });
    confirmSpy.mockRestore();
});

test('Log Out 취소 시 logout 호출되지 않음', () => {
    const confirmSpy = vi.spyOn(window, 'confirm').mockReturnValue(false);
    logout.mockClear();
    render(
        <MemoryRouter>
            <ProfileDropdown isSidebarOpen={true} onToggleSidebar={() => { }} />
        </MemoryRouter>
    );
    fireEvent.click(screen.getByTestId('profile-icon'));
    fireEvent.click(screen.getByText('Log Out'));
    expect(confirmSpy).toHaveBeenCalled();
    expect(logout).not.toHaveBeenCalled();
    confirmSpy.mockRestore();
});

test('Log Out 에러 시 alert 호출', async () => {
    const confirmSpy = vi.spyOn(window, 'confirm').mockReturnValue(true);
    logout.mockImplementationOnce(() => Promise.reject(new Error('fail logout')));
    const alertSpy = vi.spyOn(window, 'alert').mockImplementation(() => { });

    render(
        <MemoryRouter>
            <ProfileDropdown isSidebarOpen={true} onToggleSidebar={() => { }} />
        </MemoryRouter>
    );
    fireEvent.click(screen.getByTestId('profile-icon'));
    fireEvent.click(screen.getByText('Log Out'));
    await waitFor(() => {
        expect(alertSpy).toHaveBeenCalledWith('로그아웃 중 오류가 발생했습니다.');
    });
    confirmSpy.mockRestore();
    alertSpy.mockRestore();
});

test('외부 클릭 시 드롭다운 닫힘 (menuRef 캐싱 테스트)', async () => {
    render(
        <MemoryRouter>
            <div>
                <ProfileDropdown isSidebarOpen={true} onToggleSidebar={() => { }} />
                <button data-testid="outside-btn">outside</button>
            </div>
        </MemoryRouter>
    );
    fireEvent.click(screen.getByTestId('profile-icon'));
    const dropdownNode = screen.getByText('테스터').closest('div');
    fakeRef.current = dropdownNode;
    fireEvent.mouseDown(screen.getByTestId('outside-btn'));
    await waitFor(() => {
        expect(screen.queryByText('테스터')).not.toBeInTheDocument();
    });
});

test('사이드바 토글 클릭 시 onToggleSidebar 호출', () => {
    const toggleSpy = vi.fn();
    const { container } = render(
        <MemoryRouter>
            <ProfileDropdown isSidebarOpen={true} onToggleSidebar={toggleSpy} />
        </MemoryRouter>
    );
    const toggleBtn = container.querySelector('div[style*="position: fixed"]');
    if (!toggleBtn) throw new Error('toggle button not found');
    fireEvent.click(toggleBtn);
    expect(toggleSpy).toHaveBeenCalled();
});

test('ArrowIcon 분기 커버리지 (sidebar open/closed + hover/no-hover)', () => {
    const scenarios = [
        { open: true, hover: false },
        { open: true, hover: true },
        { open: false, hover: false },
        { open: false, hover: true },
    ];
    scenarios.forEach(({ open, hover }) => {
        const { container } = render(
            <MemoryRouter>
                <ProfileDropdown isSidebarOpen={open} onToggleSidebar={() => { }} />
            </MemoryRouter>
        );
        const btn = container.querySelector('div[style*="position: fixed"]');
        if (!btn) throw new Error('toggle button not found');
        if (hover) fireEvent.mouseEnter(btn);
        else fireEvent.mouseLeave(btn);
        expect(btn.querySelector('svg')).toBeInTheDocument();
    });
});
