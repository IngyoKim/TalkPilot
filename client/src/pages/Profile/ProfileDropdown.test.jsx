import { render, screen, fireEvent } from '@testing-library/react';
import ProfileDropdown from './ProfileDropdown';
import { vi } from 'vitest';
import { MemoryRouter } from 'react-router-dom';

vi.mock('@/contexts/UserContext', () => ({
    useUser: () => ({
        user: { name: '테스터', email: 'tester@example.com' },
    }),
}));
vi.mock('@/utils/auth/auth', () => ({ logout: vi.fn(() => Promise.resolve()) }));

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
