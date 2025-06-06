import {
    fetchUserByUid,
    fetchNicknameByUid,
    updateUser,
    initUser,
    deleteUser,
} from './user';
import { getIdToken } from '@/utils/auth/auth';

global.fetch = vi.fn();

vi.mock('@/models/userModel', () => ({
    UserModel: vi.fn((uid, data) => ({ uid, ...data })),
}));

vi.mock('@/utils/auth/auth', () => ({
    getIdToken: vi.fn(() => Promise.resolve('mock-token')),
}));

beforeEach(() => {
    vi.clearAllMocks();
    fetch.mockResolvedValue({
        ok: true,
        json: async () => ({ uid: 'uid123', nickname: 'Tester' }),
        text: async () => '',
        status: 200,
        headers: {
            get: () => '0',
        },
    });
});

describe('user API', () => {
    it('fetchUserByUid: 정상 조회', async () => {
        const result = await fetchUserByUid('uid123');
        expect(fetch).toHaveBeenCalledWith(expect.stringContaining('/user/uid123'), expect.any(Object));
        expect(result.uid).toBe('uid123');
    });

    it('fetchNicknameByUid: 캐시가 없을 때 fetch 호출', async () => {
        const result = await fetchNicknameByUid('uidX');
        expect(fetch).toHaveBeenCalledWith(expect.stringContaining('/nickname/uidX'), expect.any(Object));
        expect(result).toBe('Tester');
    });

    it('updateUser: 정보 수정', async () => {
        await updateUser({ nickname: 'NewName' });
        expect(fetch).toHaveBeenCalledWith(expect.stringContaining('/user'), expect.objectContaining({
            method: 'PATCH',
        }));
    });

    it('initUser: 초기화 호출', async () => {
        await initUser();
        expect(fetch).toHaveBeenCalledWith(expect.stringContaining('/user/init'), expect.objectContaining({
            method: 'POST',
        }));
    });

    it('deleteUser: 삭제 호출', async () => {
        await deleteUser();
        expect(fetch).toHaveBeenCalledWith(expect.stringContaining('/user'), expect.objectContaining({
            method: 'DELETE',
        }));
    });
});
