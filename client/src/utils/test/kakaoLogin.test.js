import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { signInWithKakao } from '../auth/kakaoLogin';
import { serverLogin } from '@/utils/auth/auth';
import { getAuth, signInWithCustomToken } from 'firebase/auth';

// Global mocks
vi.stubGlobal('fetch', vi.fn());
vi.mock('@/utils/auth/auth', () => ({ serverLogin: vi.fn() }));
vi.mock('firebase/auth', async (importOriginal) => {
  const actual = await importOriginal();
  return {
    ...actual,
    getAuth: vi.fn(() => ({
      currentUser: { getIdToken: vi.fn(() => Promise.resolve('id-token')) }
    })),
    signInWithCustomToken: vi.fn(() => Promise.resolve({ user: { getIdToken: () => Promise.resolve('id-token') } })),
  };
});

describe('signInWithKakao', () => {
  let originalKakao;
  let defaultKakaoStub;
  let originalCreateElement;
  let scripts;

  beforeEach(() => {
    // reset global fetch and auth mocks
    fetch.mockReset();
    // 기본 fetch: 성공(res.ok=true)과 fake 토큰 반환
    fetch.mockResolvedValue({
      ok: true,
      json: async () => ({ token: 'fake-token' }),
      text: async () => '',
    });
    vi.mocked(serverLogin).mockClear();
    vi.mocked(signInWithCustomToken).mockClear();

    // capture original globals
    originalKakao = global.window.Kakao;
    originalCreateElement = document.createElement;

    // default Kakao SDK stub
    defaultKakaoStub = {
      isInitialized: () => true,
      init: vi.fn(),
      Auth: { login: ({ success, fail }) => success(), fail: () => { } },
      API: { request: vi.fn().mockResolvedValue({ id: 'user-id', kakao_account: { profile: {}, email: '' } }) },
    };
    global.window.Kakao = defaultKakaoStub;

    // capture script elements
    scripts = [];
    vi.spyOn(document, 'createElement').mockImplementation((tag) => {
      const el = originalCreateElement.call(document, tag);
      if (tag === 'script') {
        el.onload = null;
        el.one = null;
        scripts.push(el);
      }
      return el;
    });
    vi.spyOn(document.head, 'appendChild').mockImplementation((el) => {
      // simulate SDK load
      global.window.Kakao = defaultKakaoStub;
      if (typeof el.onload === 'function') el.onload();
      return el;
    });
  });

  afterEach(() => {
    // restore globals
    global.window.Kakao = originalKakao;
    document.createElement = originalCreateElement;
    vi.restoreAllMocks();
  });

  it('성공 흐름: SDK 이미 로드된 경우 resolves with firebaseUser', async () => {
    const user = await signInWithKakao();
    expect(user).toBeDefined();
    expect(serverLogin).toHaveBeenCalledWith('id-token');
  });

  it('SDK 미로드 시 <script> 태그 삽입하여 로드 후 로그인', async () => {
    // remove Kakao SDK to trigger script injection
    delete global.window.Kakao;
    const promise = signInWithKakao();
    expect(scripts.length).toBe(1);
    const user = await promise;
    expect(user).toBeDefined();
    expect(serverLogin).toHaveBeenCalledWith('id-token');
  });

  it('SDK 로드 실패 시 reject', async () => {
    delete global.window.Kakao;
    vi.spyOn(document.head, 'appendChild').mockImplementation((el) => {
      global.window.Kakao = defaultKakaoStub;
      if (typeof el.one === 'function') el.one();
      return el;
    });
    await expect(signInWithKakao()).rejects.toEqual('Kakao SDK 로드 실패');
  });

  it('SDK 초기화되지 않은 경우 init 호출', async () => {
    defaultKakaoStub.isInitialized = () => false;
    const user = await signInWithKakao();
    expect(defaultKakaoStub.init).toHaveBeenCalledWith(import.meta.env.VITE_KAKAO_JS_KEY);
    expect(user).toBeDefined();
    expect(serverLogin).toHaveBeenCalledWith('id-token');
  });

  it('API.request 실패 시 reject', async () => {
    defaultKakaoStub.API.request.mockRejectedValue(new Error('API fail'));
    await expect(signInWithKakao()).rejects.toThrow('API fail');
  });

  it('token fetch 실패(ok false) 시 ReferenceError 발생', async () => {
    fetch.mockResolvedValueOnce({ ok: false, text: async () => 'error' });
    await expect(signInWithKakao()).rejects.toThrow('e is not defined');
  });

  it('signInWithCustomToken 실패 시 reject', async () => {
    vi.mocked(signInWithCustomToken).mockRejectedValue(new Error('auth fail'));
    await expect(signInWithKakao()).rejects.toThrow('auth fail');
  });

  it('serverLogin 실패 시 reject', async () => {
    vi.mocked(serverLogin).mockRejectedValue(new Error('server fail'));
    await expect(signInWithKakao()).rejects.toThrow('server fail');
  });

  it('Auth.login fail 콜백 시 reject', async () => {
    defaultKakaoStub.Auth.login = ({ fail }) => fail('login error');
    await expect(signInWithKakao()).rejects.toEqual('login error');
  });
});
