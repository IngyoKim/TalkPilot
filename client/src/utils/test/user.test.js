import { describe, it, expect, vi, beforeEach } from 'vitest';
import {
    fetchUserByUid,
    fetchNicknameByUid,
    updateUser,
    initUser,
    deleteUser,
} from '../api/user';
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
        headers: { get: () => '0' },
    });
});

describe('user API', () => {
    it('fetchUserByUid: 정상 조회', async () => {
        const result = await fetchUserByUid('uid123');
        expect(fetch).toHaveBeenCalledWith(
            expect.stringContaining('/user/uid123'),
            expect.any(Object)
        );
        expect(result.uid).toBe('uid123');
    });

    it('fetchUserByUid: 실패 시 에러 throw', async () => {
        fetch.mockResolvedValueOnce({ ok: false });
        await expect(fetchUserByUid('uidX')).rejects.toThrow('사용자 정보 요청 실패');
    });

    it('fetchNicknameByUid: 캐시 없을 때 fetch 호출 및 반환', async () => {
        const result = await fetchNicknameByUid('uidX');
        expect(fetch).toHaveBeenCalledWith(
            expect.stringContaining('/nickname/uidX'),
            expect.any(Object)
        );
        expect(result).toBe('Tester');
    });

    it('fetchNicknameByUid: falsy uid일 때 uid 반환', async () => {
        const result = await fetchNicknameByUid('');
        expect(fetch).not.toHaveBeenCalled();
        expect(result).toBe('');
    });

    it('fetchNicknameByUid: fetch 실패(ok false) 시 uid 반환', async () => {
        fetch.mockResolvedValueOnce({ ok: false });
        const result = await fetchNicknameByUid('uidY');
        expect(result).toBe('uidY');
    });

    it('fetchNicknameByUid: 캐시된 uid일 때 fetch 호출 없이 캐시 반환', async () => {
        // 첫 호출로 캐시 생성
        await fetchNicknameByUid('uidZ');
        vi.clearAllMocks();
        const result = await fetchNicknameByUid('uidZ');
        expect(fetch).not.toHaveBeenCalled();
        expect(result).toBe('Tester');
    });

    it('updateUser: 정보 수정 성공', async () => {
        await updateUser({ nickname: 'NewName' });
        expect(fetch).toHaveBeenCalledWith(
            expect.stringContaining('/user'),
            expect.objectContaining({ method: 'PATCH' })
        );
    });

    it('updateUser: 실패 시 에러 throw', async () => {
        fetch.mockResolvedValueOnce({ ok: false });
        await expect(updateUser({})).rejects.toThrow('사용자 정보 업데이트 실패');
    });

    it('initUser: 초기화 성공', async () => {
        await initUser();
        expect(fetch).toHaveBeenCalledWith(
            expect.stringContaining('/user/init'),
            expect.objectContaining({ method: 'POST' })
        );
    });

    it('initUser: 실패 시 에러 throw', async () => {
        fetch.mockResolvedValueOnce({ ok: false });
        await expect(initUser()).rejects.toThrow('유저 초기화 실패');
    });

    it('deleteUser: 삭제 성공', async () => {
        await deleteUser();
        expect(fetch).toHaveBeenCalledWith(
            expect.stringContaining('/user'),
            expect.objectContaining({ method: 'DELETE' })
        );
    });

    it('deleteUser: 실패 시 에러 throw', async () => {
        fetch.mockResolvedValueOnce({ ok: false });
        await expect(deleteUser()).rejects.toThrow('유저 삭제 실패');
    });
});
