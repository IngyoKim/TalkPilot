import { render, screen, fireEvent } from '@testing-library/react';
import CPMtestPage from './CPMtestPage';
import { vi } from 'vitest';

vi.mock('@/components/SideBar', () => ({
    __esModule: true,
    default: () => <div data-testid="mock-sidebar" />,
}));
vi.mock('@/pages/Profile/ProfileDropdown', () => ({
    __esModule: true,
    default: () => <div data-testid="mock-profile-dropdown" />,
}));

test('시작 버튼 누르면 "종료" 또는 "처음으로"로 변경됨', () => {
    render(<CPMtestPage />);
    const startButton = screen.getByText('시작');
    fireEvent.click(startButton);

    expect(screen.getByText('종료')).toBeInTheDocument();
});
