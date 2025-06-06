import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { vi } from 'vitest';

vi.mock('@/components/SideBar', () => ({ default: () => <div /> }));
vi.mock('@/pages/Profile/ProfileDropdown', () => ({ default: () => <div /> }));
vi.mock('@/components/ToastMessage', () => ({ default: () => null }));
vi.mock('@/utils/api/user', () => ({
    updateUser: vi.fn(() => Promise.resolve()),
}));

// 전역 user mock 객체를 외부에서 참조 가능하게 선언
const setUserMock = vi.fn();
const mockUser = {
    name: '김민규',
    email: 'tester@test.com',
    nickname: '김민규',
    createdAt: new Date().toISOString(),
};

vi.mock('@/contexts/UserContext', () => ({
    useUser: () => ({
        user: mockUser,
        setUser: setUserMock,
    }),
}));

import ProfilePage from './ProfilePage'; // 이제 mock이 정상 주입됨

describe('닉네임 수정 흐름', () => {
    beforeEach(() => {
        setUserMock.mockClear();
    });

    test('수정 버튼 클릭 시 현재 닉네임이 입력창에 표시됨', async () => {
        render(
            <MemoryRouter>
                <ProfilePage />
            </MemoryRouter>
        );

        fireEvent.click(screen.getByTestId('edit-nickname'));
        const input = await screen.findByRole('textbox');
        expect(input.value).toBe('김민규');
    });

    test('닉네임을 변경하고 저장하면 setUser가 호출되고, input은 사라짐', async () => {
        render(
            <MemoryRouter>
                <ProfilePage />
            </MemoryRouter>
        );

        fireEvent.click(screen.getByTestId('edit-nickname'));

        const input = await screen.findByRole('textbox');
        fireEvent.change(input, { target: { value: '테테테스트' } });

        fireEvent.click(screen.getByText('저장'));

        await waitFor(() => {
            expect(setUserMock).toHaveBeenCalled();
        });

        const updateFn = setUserMock.mock.calls[0][0];
        const updated = updateFn(mockUser);

        expect(updated.nickname).toBe('테테테스트');
        expect(screen.queryByRole('textbox')).not.toBeInTheDocument();
    });
});
