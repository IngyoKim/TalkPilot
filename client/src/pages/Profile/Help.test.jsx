import { render, screen, fireEvent } from '@testing-library/react';
import Help from './Help';
import { vi } from 'vitest';

vi.mock('@/components/SideBar', () => ({ __esModule: true, default: () => <div /> }));
vi.mock('@/pages/Profile/ProfileDropdown', () => ({ __esModule: true, default: () => <div /> }));

test('검색어 입력 시 필터링 작동', () => {
    render(<Help />);
    const input = screen.getByPlaceholderText('검색어를 입력하세요, 만약 없으면 Contact Us에 들어가서 문의하세요');

    fireEvent.change(input, { target: { value: '초대' } });
    expect(screen.getByText(/초대/)).toBeInTheDocument();

    fireEvent.change(input, { target: { value: '없는 키워드' } });
    expect(screen.getByText('검색 결과가 없습니다.')).toBeInTheDocument();
});
