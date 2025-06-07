import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { vi } from 'vitest';
import * as React from 'react';


// mock updateUser API
import { updateUser } from '@/utils/api/user';
vi.mock('@/utils/api/user', () => ({ updateUser: vi.fn(() => Promise.resolve()) }));

// mock UserContext
import { useUser } from '@/contexts/UserContext';
vi.mock('@/contexts/UserContext', () => ({ useUser: vi.fn() }));

// mock navigation
const navigateMock = vi.fn();
vi.mock('react-router-dom', async () => {
    const actual = await vi.importActual('react-router-dom');
    return { ...actual, useNavigate: () => navigateMock };
});

import ProfilePage from './ProfilePage';

const mockUser = {
    name: '김민규',
    email: 'tester@test.com',
    nickname: '김민규',
    createdAt: new Date().toISOString(),
};
const setUserMock = vi.fn();

describe('닉네임 수정 흐름', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    test('수정 버튼 클릭 시 현재 닉네임이 입력창에 표시됨', async () => {
        useUser.mockReturnValue({ user: mockUser, setUser: setUserMock });
        render(<MemoryRouter><ProfilePage /></MemoryRouter>);

        fireEvent.click(screen.getByTestId('edit-nickname'));
        const input = await screen.findByRole('textbox');
        expect(input.value).toBe('김민규');
    });

    test('닉네임을 변경하고 저장하면 setUser가 호출되고, input은 사라짐', async () => {
        useUser.mockReturnValue({ user: mockUser, setUser: setUserMock });
        render(<MemoryRouter><ProfilePage /></MemoryRouter>);

        fireEvent.click(screen.getByTestId('edit-nickname'));
        const input = await screen.findByRole('textbox');
        fireEvent.change(input, { target: { value: '테테테스트' } });
        fireEvent.click(screen.getByText('저장'));

        await waitFor(() => expect(setUserMock).toHaveBeenCalled());
        const updateFn = setUserMock.mock.calls[0][0];
        const updated = updateFn(mockUser);
        expect(updated.nickname).toBe('테테테스트');
        expect(screen.queryByRole('textbox')).not.toBeInTheDocument();
    });

    test('편집 취소 버튼 클릭 시 입력창이 사라지고 원래 닉네임이 표시됨', async () => {
        useUser.mockReturnValue({ user: mockUser, setUser: setUserMock });
        render(<MemoryRouter><ProfilePage /></MemoryRouter>);

        fireEvent.click(screen.getByTestId('edit-nickname'));
        const input = await screen.findByRole('textbox');
        fireEvent.change(input, { target: { value: '새닉네임' } });
        fireEvent.click(screen.getByText('취소'));

        await waitFor(() => expect(screen.queryByRole('textbox')).not.toBeInTheDocument());
        const label = screen.getByText('닉네임:');
        expect(label.parentElement).toHaveTextContent('김민규');
    });

    test('하단 버튼 클릭 시 navigate가 올바른 경로로 호출됨', () => {
        useUser.mockReturnValue({ user: mockUser, setUser: setUserMock });
        render(<MemoryRouter><ProfilePage /></MemoryRouter>);

        fireEvent.click(screen.getByText('확인하기'));
        expect(navigateMock).toHaveBeenCalledWith('/projectrecord');

        const testButtons = screen.getAllByText('테스트');
        fireEvent.click(testButtons[0]);
        expect(navigateMock).toHaveBeenCalledWith('/stttest');

        fireEvent.click(testButtons[1]);
        expect(navigateMock).toHaveBeenCalledWith('/cpmtest');
    });
});

describe('추가 분기 커버', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    test('user 로딩 분기', () => {
        useUser.mockReturnValue({ user: null, setUser: setUserMock });
        render(<MemoryRouter><ProfilePage /></MemoryRouter>);
        expect(screen.getByText('사용자 정보를 불러오는 중입니다...')).toBeInTheDocument();
    });

    test('닉네임 저장 실패 시 편집 유지 및 console.error 호출', async () => {
        useUser.mockReturnValue({ user: mockUser, setUser: setUserMock });
        updateUser.mockImplementationOnce(() => Promise.reject(new Error('fail')));
        const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => { });
        render(<MemoryRouter><ProfilePage /></MemoryRouter>);

        fireEvent.click(screen.getByTestId('edit-nickname'));
        const input = await screen.findByRole('textbox');
        fireEvent.change(input, { target: { value: '실패닉' } });
        fireEvent.click(screen.getByText('저장'));

        await waitFor(() => {
            expect(consoleSpy).toHaveBeenCalled();
            expect(screen.getByRole('textbox')).toBeInTheDocument();
        });
        consoleSpy.mockRestore();
    });
});
