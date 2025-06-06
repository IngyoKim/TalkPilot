import { render, screen } from '@testing-library/react';
import Contact from './Contact';
import { vi } from 'vitest';

vi.mock('@/components/SideBar', () => ({
    __esModule: true,
    default: () => <div data-testid="mock-sidebar" />,
}));
vi.mock('@/pages/Profile/ProfileDropdown', () => ({
    __esModule: true,
    default: () => <div data-testid="mock-profile-dropdown" />,
}));

test('Contact 페이지 렌더링 및 버튼 존재 확인', () => {
    render(<Contact />);
    expect(screen.getByText('전달하기')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('이름')).toBeInTheDocument();
});
