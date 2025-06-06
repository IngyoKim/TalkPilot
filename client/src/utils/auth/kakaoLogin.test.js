// src/utils/auth/kakaoLogin.test.js
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { signInWithKakao } from './kakaoLogin';

vi.stubGlobal('fetch', vi.fn());

// serverLogin mock
vi.mock('./auth', () => ({
  serverLogin: vi.fn(() => Promise.resolve({ uid: 'kakao-mock-uid' })),
}));

// Firebase 관련 mock
vi.mock('firebase/auth', async (importOriginal) => {
  const actual = await importOriginal();
  return {
    ...actual,
    getAuth: vi.fn(() => ({
      currentUser: {
        getIdToken: vi.fn(() => Promise.resolve('mock-id-token')),
      },
    })),
    signInWithCustomToken: vi.fn(() =>
      Promise.resolve({
        user: {
          getIdToken: () => Promise.resolve('mock-id-token'),
        },
      })
    ),
  };
});

beforeEach(() => {
  fetch.mockReset();
});

describe('signInWithKakao', () => {
  it('성공 흐름 실행 시 resolve 됨', async () => {
    global.window = global;
    global.Kakao = {
      isInitialized: () => true,
      init: vi.fn(),
      Auth: {
        login: ({ success }) => {
          success(); // 직접 성공 콜백 실행
        },
        getAccessToken: () => 'kakao-access-token',
      },
      API: {
        request: vi.fn().mockResolvedValue({
          id: 'kakao-user-id',
          kakao_account: {
            profile: {
              nickname: '테스트유저',
              profile_image_url: 'https://example.com/profile.jpg',
            },
            email: 'test@example.com',
          },
        }),
      },
    };

    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ({ token: 'mock-custom-token' }),
    });

    const user = await signInWithKakao();
    expect(user).toBeDefined();
  });
});
