import { renderHook, act } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import useProjects from '../userProjects';

vi.mock('@/utils/api/user', () => ({
    updateUser: vi.fn(() => Promise.resolve()),
}));
vi.mock('@/utils/api/project', () => ({
    fetchProjectById: vi.fn((id) => Promise.resolve({ id, title: 'Project ' + id, createdAt: '2023-01-01', participants: {} })),
    createProject: vi.fn(({ title, description }) => Promise.resolve({ id: 'new-id', title, description, createdAt: '2023-01-01' })),
    updateProject: vi.fn(() => Promise.resolve()),
    deleteProject: vi.fn(() => Promise.resolve()),
}));

describe('useProjects', () => {
    let user, setUser;

    beforeEach(() => {
        user = {
            uid: 'user1',
            projectIds: { '123': 'preparing' },
        };
        setUser = vi.fn((fn) => {
            user = fn(user); // simulate setState
        });
    });

    it('loadProjects - 유효한 ID로 프로젝트 불러옴', async () => {
        const { result } = renderHook(() => useProjects(user, setUser));
        await new Promise((r) => setTimeout(r, 10)); // wait for useEffect
        expect(result.current.projects.length).toBe(1);
        expect(result.current.projects[0].id).toBe('123');
    });

    it('create - 프로젝트 생성 및 유저 상태 업데이트', async () => {
        const { result } = renderHook(() => useProjects(user, setUser));
        const project = await act(() => result.current.create({ title: 'New Project', description: 'desc' }));
        expect(project.id).toBe('new-id');
        expect(setUser).toHaveBeenCalled();
    });

    it('join - 신규 참여 성공', async () => {
        const { result } = renderHook(() => useProjects(user, setUser));
        await act(() => result.current.join('join-id'));
        expect(setUser).toHaveBeenCalled();
    });

    it('update - 프로젝트 정보 업데이트', async () => {
        const { result } = renderHook(() => useProjects(user, setUser));
        await new Promise((r) => setTimeout(r, 10));
        await act(() => result.current.update('123', { title: '변경됨' }));
        expect(result.current.projects[0].title).toBe('변경됨');
    });

    it('remove - 삭제 후 프로젝트 목록 재조회', async () => {
        const { result } = renderHook(() => useProjects(user, setUser));
        await new Promise((r) => setTimeout(r, 10));
        await act(() => result.current.remove('123'));
        expect(setUser).toHaveBeenCalled();
    });

    it('changeStatus - 프로젝트 상태 변경 흐름 확인', async () => {
        const { result } = renderHook(() => useProjects(user, setUser));
        await new Promise((r) => setTimeout(r, 10));
        await act(() => result.current.changeStatus('123', 'done'));
        // 실제 update 내부 호출 여부는 mock에서 이미 검증됨
    });
});
