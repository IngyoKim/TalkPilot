import {
    createProject,
    getProjects,
    updateProject,
    deleteProject,
    fetchProjectById,
} from '../api/project';
import { getIdToken } from '@/utils/auth/auth';

// ✅ fetch를 전역으로 vi.fn으로 모킹 선언
global.fetch = vi.fn();

vi.mock('@/models/projectModel', () => ({
    ProjectModel: vi.fn((id, data) => ({ id, ...data })),
}));

vi.mock('@/utils/auth/auth', () => ({
    getIdToken: vi.fn(() => Promise.resolve('mock-token')),
}));

beforeEach(() => {
    vi.clearAllMocks();
    fetch.mockResolvedValue({
        ok: true,
        json: async () => ({ id: 'test-project', title: 'Mock Project' }),
        text: async () => '',
        status: 200,
        headers: {
            get: () => '0',
        },
    });
});

describe('project API', () => {
    it('createProject: 정상적으로 프로젝트 생성', async () => {
        const data = { title: 'New Project' };
        const result = await createProject(data);

        expect(getIdToken).toHaveBeenCalled();
        expect(fetch).toHaveBeenCalledWith(expect.stringContaining('/project'), expect.objectContaining({
            method: 'POST',
        }));
        expect(result.title).toBe('Mock Project');
    });

    it('getProjects: 프로젝트 목록 조회', async () => {
        fetch.mockResolvedValueOnce({
            ok: true,
            json: async () => [{ id: '1', title: 'A' }, { id: '2', title: 'B' }],
        });

        const result = await getProjects('uid123');
        expect(fetch).toHaveBeenCalledWith(expect.stringContaining('?uid=uid123'), expect.any(Object));
        expect(result).toHaveLength(2);
        expect(result[0].id).toBe('1');
    });

    it('updateProject: 프로젝트 정보 수정', async () => {
        await updateProject('123', { title: 'Updated' });
        expect(fetch).toHaveBeenCalledWith(expect.stringContaining('/project/123'), expect.objectContaining({
            method: 'PATCH',
        }));
    });

    it('deleteProject: 삭제 후 응답 없음 처리', async () => {
        fetch.mockResolvedValueOnce({
            ok: true,
            status: 204,
            headers: { get: () => '0' },
            text: async () => '',
        });

        const result = await deleteProject('abc');
        expect(result).toBeNull();
    });

    it('fetchProjectById: 존재하지 않으면 null 반환', async () => {
        fetch.mockResolvedValueOnce({ status: 404 });
        const result = await fetchProjectById('non-existent');
        expect(result).toBeNull();
    });
});
