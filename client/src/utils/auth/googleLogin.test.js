import { describe, it, expect, vi, beforeEach } from 'vitest';
import { signInWithGoogle } from './googleLogin';
import { serverLogin } from '@/utils/auth/auth';
import { GoogleAuthProvider, signInWithPopup } from 'firebase/auth';

// serverLogin 모킹
vi.mock('@/utils/auth/auth', () => ({
  serverLogin: vi.fn(),
}));

// Firebase Auth 모킹
vi.mock('firebase/auth', async () => {
  const actual = await vi.importActual('firebase/auth');
  return {
    ...actual,
    auth: {},  // 더미 auth 객체
    GoogleAuthProvider: vi.fn().mockImplementation(() => ({})),
    signInWithPopup: vi.fn(),
  };
});

describe('signInWithGoogle', () => {
  beforeEach(() => {
    // 모든 모의 함수 초기화
    vi.clearAllMocks();

    // 기본 동작: 로그인 성공 + 토큰 발급 + 서버 로그인
    signInWithPopup.mockResolvedValue({
      user: { getIdToken: () => Promise.resolve('mock-google-id-token') },
    });
    serverLogin.mockResolvedValue({ uid: 'mock-google-user' });
  });

  it('성공 흐름: 로그인 → 토큰 발급 → 서버 로그인 후 사용자 반환', async () => {
    const user = await signInWithGoogle();
    // 프로바이더 생성 및 팝업 호출 확인
    expect(GoogleAuthProvider).toHaveBeenCalled();
    expect(signInWithPopup).toHaveBeenCalledWith(expect.any(Object), expect.any(Object));
    // 서버 로그인에 올바른 토큰 전달
    expect(serverLogin).toHaveBeenCalledWith('mock-google-id-token');
    // 반환된 사용자 확인
    expect(user).toBeDefined();
  });

  it('signInWithPopup 실패 시 Reject', async () => {
    signInWithPopup.mockRejectedValue(new Error('popup fail'));
    await expect(signInWithGoogle()).rejects.toThrow('popup fail');
  });

  it('getIdToken 실패 시 Reject', async () => {
    signInWithPopup.mockResolvedValue({
      user: { getIdToken: () => Promise.reject(new Error('token fail')) },
    });
    await expect(signInWithGoogle()).rejects.toThrow('token fail');
  });

  it('serverLogin 실패 시 Reject', async () => {
    serverLogin.mockRejectedValue(new Error('server fail'));
    await expect(signInWithGoogle()).rejects.toThrow('server fail');
  });
});
