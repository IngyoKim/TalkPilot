import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import ProjectDetail from './ProjectDetail';
import { MemoryRouter, Routes, Route } from 'react-router-dom';
import * as projectAPI from '@/utils/api/project';
import * as userAPI from '@/utils/api/user';
import * as UserContext from '@/contexts/UserContext';

// Mock useUser context
vi.spyOn(UserContext, 'useUser').mockReturnValue({ user: { uid: 'mock-user' }, setUser: vi.fn() });

// Mock navigation
const mockNavigate = vi.fn();
vi.mock('react-router-dom', async () => {
    const actual = await vi.importActual('react-router-dom');
    return {
        ...actual,
        useNavigate: () => mockNavigate,
    };
});

// Mock APIs via spyOn
vi.spyOn(projectAPI, 'fetchProjectById');
vi.spyOn(projectAPI, 'updateProject');
vi.spyOn(userAPI, 'fetchUserByUid');

// Mock ToastMessage to render messages
vi.mock('@/components/ToastMessage', () => ({
    __esModule: true,
    default: ({ messages }) => (
        <div data-testid="toast">
            {messages.map(msg => <span key={msg.id}>{msg.text}</span>)}
        </div>
    ),
}));

describe('ProjectDetail component', () => {
    const sampleProject = {
        id: 'p1',
        title: 'Title',
        description: 'Desc',
        script: 'Script',
        scheduledDate: '2025-06-10',
        participants: { 'mock-user': 'owner', 'u2': 'member' },
        ownerUid: 'o1',
        createdAt: new Date('2025-01-01').toISOString(),
        updatedAt: new Date('2025-02-01').toISOString(),
    };

    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('shows user-loading when no user', () => {
        UserContext.useUser.mockReturnValueOnce({ user: null });
        render(
            <MemoryRouter>
                <ProjectDetail />
            </MemoryRouter>
        );
        expect(screen.getByText('사용자 정보를 불러오는 중입니다...')).toBeInTheDocument();
    });

    it('shows loading while fetching project', () => {
        projectAPI.fetchProjectById.mockReturnValue(new Promise(() => { }));
        render(
            <MemoryRouter initialEntries={["/project/p1"]}>
                <Routes>
                    <Route path="/project/:id" element={<ProjectDetail />} />
                </Routes>
            </MemoryRouter>
        );
        expect(screen.getByText('로딩 중...')).toBeInTheDocument();
    });

    it('navigates back when project not found', async () => {
        projectAPI.fetchProjectById.mockResolvedValue(null);
        render(
            <MemoryRouter initialEntries={["/project/p1"]}>
                <Routes>
                    <Route path="/project/:id" element={<ProjectDetail />} />
                </Routes>
            </MemoryRouter>
        );
        await waitFor(() => {
            expect(mockNavigate).toHaveBeenCalledWith(-1);
        });
    });

    it('renders project info with owner nickname', async () => {
        projectAPI.fetchProjectById.mockResolvedValue(sampleProject);
        userAPI.fetchUserByUid.mockResolvedValue({ nickname: 'OwnerNick' });
        render(
            <MemoryRouter initialEntries={["/project/p1"]}>
                <Routes>
                    <Route path="/project/:id" element={<ProjectDetail />} />
                </Routes>
            </MemoryRouter>
        );
        expect(await screen.findByDisplayValue('Title')).toBeInTheDocument();
        expect(screen.getByText('참여자 수: 2')).toBeInTheDocument();
        expect(screen.getByText('소유자: OwnerNick')).toBeInTheDocument();
        expect(screen.getByDisplayValue('2025-06-10')).toBeInTheDocument();
    });

    it('renders owner missing when no ownerUid', async () => {
        projectAPI.fetchProjectById.mockResolvedValue({ ...sampleProject, ownerUid: null });
        render(
            <MemoryRouter initialEntries={["/project/p1"]}>
                <Routes>
                    <Route path="/project/:id" element={<ProjectDetail />} />
                </Routes>
            </MemoryRouter>
        );
        expect(await screen.findByText('소유자: (소유자 없음)')).toBeInTheDocument();
    });

    it('toggles script editing', async () => {
        projectAPI.fetchProjectById.mockResolvedValue(sampleProject);
        userAPI.fetchUserByUid.mockResolvedValue({ nickname: 'OwnerNick' });
        render(
            <MemoryRouter initialEntries={["/project/p1"]}>
                <Routes>
                    <Route path="/project/:id" element={<ProjectDetail />} />
                </Routes>
            </MemoryRouter>
        );
        const toggle = await screen.findByRole('button', { name: '편집 시작' });
        fireEvent.click(toggle);
        expect(toggle).toHaveTextContent('편집 종료');
        expect(screen.getByDisplayValue('Script')).not.toBeDisabled();
    });

    it('handles save success and error', async () => {
        projectAPI.fetchProjectById.mockResolvedValue(sampleProject);
        userAPI.fetchUserByUid.mockResolvedValue({ nickname: 'OwnerNick' });
        // success
        projectAPI.updateProject.mockResolvedValue({});
        render(
            <MemoryRouter initialEntries={["/project/p1"]}>
                <Routes>
                    <Route path="/project/:id" element={<ProjectDetail />} />
                </Routes>
            </MemoryRouter>
        );
        const saveBtn = await screen.findByRole('button', { name: '저장' });
        fireEvent.click(saveBtn);
        expect(projectAPI.updateProject).toHaveBeenCalled();
        expect(await screen.findByText('프로젝트가 저장되었습니다.')).toBeInTheDocument();

        // error
        projectAPI.updateProject.mockRejectedValue(new Error('fail'));
        fireEvent.click(saveBtn);
        expect(await screen.findByText(/^저장 실패:/)).toBeInTheDocument();
    });

    it('navigates on secondary buttons', async () => {
        projectAPI.fetchProjectById.mockResolvedValue(sampleProject);
        userAPI.fetchUserByUid.mockResolvedValue({ nickname: 'OwnerNick' });
        render(
            <MemoryRouter initialEntries={["/project/p1"]}>
                <Routes>
                    <Route path="/project/:id" element={<ProjectDetail />} />
                </Routes>
            </MemoryRouter>
        );
        const assignBtn = await screen.findByRole('button', { name: '대본 파트 할당하기' });
        fireEvent.click(assignBtn);
        expect(mockNavigate).toHaveBeenCalledWith('/script-part/p1');
        const practiceBtn = screen.getByRole('button', { name: '연습 시작하기' });
        fireEvent.click(practiceBtn);
        expect(mockNavigate).toHaveBeenCalledWith('/practice/p1');
    });

    it('does not allow script editing for member roles', async () => {
        const proj = { ...sampleProject, participants: { 'mock-user': 'member' } };
        projectAPI.fetchProjectById.mockResolvedValue(proj);
        userAPI.fetchUserByUid.mockResolvedValue({ nickname: 'MemberNick' });
        render(
            <MemoryRouter initialEntries={["/project/p1"]}>
                <Routes>
                    <Route path="/project/:id" element={<ProjectDetail />} />
                </Routes>
            </MemoryRouter>
        );
        await screen.findByDisplayValue('Title');
        expect(screen.queryByText('편집 시작')).toBeNull();
    });

    it('updates fields via handleChange', async () => {
        projectAPI.fetchProjectById.mockResolvedValue(sampleProject);
        userAPI.fetchUserByUid.mockResolvedValue({ nickname: 'OwnerNick' });
        render(
            <MemoryRouter initialEntries={["/project/p1"]}>
                <Routes>
                    <Route path="/project/:id" element={<ProjectDetail />} />
                </Routes>
            </MemoryRouter>
        );
        const titleInput = await screen.findByDisplayValue('Title');
        fireEvent.change(titleInput, { target: { value: 'New Title' } });
        expect(screen.getByDisplayValue('New Title')).toBeInTheDocument();
        const dateInput = screen.getByDisplayValue('2025-06-10');
        fireEvent.change(dateInput, { target: { value: '2025-07-01' } });
        expect(screen.getByDisplayValue('2025-07-01')).toBeInTheDocument();
    });

    it('renders empty scheduledDate when not set', async () => {
        const proj = { ...sampleProject }; delete proj.scheduledDate;
        projectAPI.fetchProjectById.mockResolvedValue(proj);
        userAPI.fetchUserByUid.mockResolvedValue({ nickname: 'OwnerNick' });
        const { container } = render(
            <MemoryRouter initialEntries={["/project/p1"]}>
                <Routes>
                    <Route path="/project/:id" element={<ProjectDetail />} />
                </Routes>
            </MemoryRouter>
        );
        await screen.findByDisplayValue('Title');
        const dateInput = container.querySelector('input[type="date"]');
        expect(dateInput.value).toBe('');
    });

    it('does not render updatedAt when missing', async () => {
        const proj = { ...sampleProject, updatedAt: null };
        projectAPI.fetchProjectById.mockResolvedValue(proj);
        userAPI.fetchUserByUid.mockResolvedValue({ nickname: 'OwnerNick' });
        render(
            <MemoryRouter initialEntries={["/project/p1"]}>
                <Routes>
                    <Route path="/project/:id" element={<ProjectDetail />} />
                </Routes>
            </MemoryRouter>
        );
        await screen.findByDisplayValue('Title');
        expect(screen.queryByText(/마지막 수정일/)).toBeNull();
    });

    it('shows loading on loadProject error', async () => {
        projectAPI.fetchProjectById.mockRejectedValue(new Error('fail'));
        render(
            <MemoryRouter initialEntries={["/project/p1"]}>
                <Routes>
                    <Route path="/project/:id" element={<ProjectDetail />} />
                </Routes>
            </MemoryRouter>
        );
        expect(await screen.findByText('로딩 중...')).toBeInTheDocument();
    });

    it('navigates back when clicking back button', async () => {
        projectAPI.fetchProjectById.mockResolvedValue(sampleProject);
        userAPI.fetchUserByUid.mockResolvedValue({ nickname: 'OwnerNick' });
        render(
            <MemoryRouter initialEntries={["/project/p1"]}>
                <Routes>
                    <Route path="/project/:id" element={<ProjectDetail />} />
                </Routes>
            </MemoryRouter>
        );
        await screen.findByDisplayValue('Title');
        const backBtn = screen.getByText('← 뒤로가기');
        fireEvent.click(backBtn);
        expect(mockNavigate).toHaveBeenCalledWith(-1);
    });

    it('hides save and assign buttons for member role', async () => {
        const proj = { ...sampleProject, participants: { 'mock-user': 'member' } };
        projectAPI.fetchProjectById.mockResolvedValue(proj);
        userAPI.fetchUserByUid.mockResolvedValue({ nickname: 'MemberNick' });
        render(
            <MemoryRouter initialEntries={["/project/p1"]}>
                <Routes>
                    <Route path="/project/:id" element={<ProjectDetail />} />
                </Routes>
            </MemoryRouter>
        );
        await screen.findByDisplayValue('Title');
        expect(screen.queryByText('저장')).toBeNull();
        expect(screen.queryByText('대본 파트 할당하기')).toBeNull();
        // practice button always visible
        expect(screen.getByText('연습 시작하기')).toBeInTheDocument();
    });
});
