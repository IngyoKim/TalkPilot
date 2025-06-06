// src/utils/auth/googleLogin.test.js
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { signInWithGoogle } from './googleLogin';

// serverLogin mock
vi.mock('./auth', () => ({
  serverLogin: vi.fn(() => Promise.resolve({ uid: 'mock-google-user' })),
}));

// Firebase 관련 mock
vi.mock('firebase/auth', async (importOriginal) => {
  const actual = await importOriginal();
  return {
    ...actual,
    auth: {}, // dummy
    GoogleAuthProvider: vi.fn().mockImplementation(() => ({})),
    signInWithPopup: vi.fn(() =>
      Promise.resolve({
        user: {
          getIdToken: () => Promise.resolve('mock-google-id-token'),
        },
      })
    ),
  };
});

describe('signInWithGoogle', () => {
  it('성공 흐름 실행 시 resolve 됨', async () => {
    const user = await signInWithGoogle();
    expect(user).toBeDefined();
  });
});
