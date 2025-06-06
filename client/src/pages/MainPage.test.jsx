import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import MainPage from './MainPage';

vi.mock('@/contexts/UserContext', () => ({
    useUser: () => ({
        user: { uid: 'mockUid', nickname: 'TestUser' },
        setUser: vi.fn(),
    }),
}));

vi.mock('@/utils/userProjects', () => {
    return {
        default: () => ({
            projects: [],
            create: vi.fn(),
            join: vi.fn(),
            remove: vi.fn(),
            update: vi.fn(),
            changeStatus: vi.fn(),
        }),
    };
});

describe('MainPage', () => {
    it('프로젝트 추가 버튼이 렌더링되어야 함', () => {
        render(
            <MemoryRouter>
                <MainPage />
            </MemoryRouter>
        );

        expect(screen.getByText('프로젝트 추가')).toBeInTheDocument();
    });
});
