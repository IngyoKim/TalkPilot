import { describe, it, expect, vi, beforeEach } from 'vitest';
import { getCurrentUid, getIdToken, logout, serverLogin } from '../auth/auth';

vi.mock('firebase/auth', async (importOriginal) => {
  const actual = await importOriginal();
  return {
    ...actual,
    getAuth: vi.fn(() => ({
      currentUser: {
        uid: 'mock-uid',
        getIdToken: vi.fn(() => Promise.resolve('mock-id-token')),
      },
    })),
    signOut: vi.fn(() => Promise.resolve()),
  };
});

describe('auth.js', () => {
  it('serverLogin: 서버 로그인 성공 시 사용자 데이터 반환', async () => {
    global.fetch = vi.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve({ user: { uid: '123' } }),
      })
    );
    const data = await serverLogin('token');
    expect(data.user.uid).toBe('123');
  });

  it('logout: Firebase 로그아웃 성공', async () => {
    const { signOut } = await import('firebase/auth');
    await logout();
    expect(signOut).toHaveBeenCalled();
  });

  it('getCurrentUid: 현재 유저 UID 반환', () => {
    expect(getCurrentUid()).toBe('mock-uid');
  });

  it('getIdToken: 현재 유저 ID 토큰 반환', async () => {
    const token = await getIdToken();
    expect(token).toBe('mock-id-token');
  });
});
