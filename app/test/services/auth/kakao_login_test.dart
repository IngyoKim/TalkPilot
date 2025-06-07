import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:talk_pilot/src/services/auth/kakao_login.dart';
import 'package:talk_pilot/src/services/auth/custom_token_service.dart';

@GenerateMocks(
  [],
  customMocks: [
    MockSpec<kakao.UserApi>(as: #MockUserApi),
    MockSpec<kakao.User>(as: #MockKakaoUser),
    MockSpec<kakao.Account>(as: #MockKakaoAccount),
    MockSpec<kakao.Profile>(as: #MockKakaoProfile),
    MockSpec<kakao.OAuthToken>(as: #MockOAuthToken),
    MockSpec<FirebaseAuth>(as: #MockFirebaseAuth),
    MockSpec<UserCredential>(as: #MockUserCredential),
    MockSpec<User>(as: #MockFirebaseUser),
    MockSpec<CustomTokenService>(as: #MockCustomTokenService),
  ],
)
import 'kakao_login_test.mocks.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    FirebasePlatform.instance = MockFirebasePlatform();

    await Firebase.initializeApp();

    await dotenv.load(fileName: '.env');

    KakaoSdk.init(nativeAppKey: 'dummy_app_key');
  });

  group('KakaoLogin', () {
    late KakaoLogin kakaoLogin;
    late MockUserApi mockUserApi;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockCustomTokenService mockCustomTokenService;
    late MockOAuthToken mockOAuthToken;
    late MockKakaoUser mockKakaoUser;
    late MockKakaoAccount mockKakaoAccount;
    late MockKakaoProfile mockKakaoProfile;
    late MockUserCredential mockUserCredential;
    late MockFirebaseUser mockFirebaseUser;

    setUp(() {
      mockUserApi = MockUserApi();
      mockFirebaseAuth = MockFirebaseAuth();
      mockCustomTokenService = MockCustomTokenService();
      mockOAuthToken = MockOAuthToken();
      mockKakaoUser = MockKakaoUser();
      mockKakaoAccount = MockKakaoAccount();
      mockKakaoProfile = MockKakaoProfile();
      mockUserCredential = MockUserCredential();
      mockFirebaseUser = MockFirebaseUser();

      when(mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);

      kakaoLogin = KakaoLogin(
        userApi: mockUserApi,
        auth: mockFirebaseAuth,
        customTokenService: mockCustomTokenService,
        isKakaoTalkInstalledFn: () async => false,
        serverLoginFn: () async => {},
      );
    });

    test('can create instance with default parameters', () {
      final login = KakaoLogin(
        auth: mockFirebaseAuth,
        isKakaoTalkInstalledFn: () async => false,
        serverLoginFn: () async => {},
        // userApi 와 customTokenService 전달하지 않음 → default branch 타게 됨
      );

      expect(login, isA<KakaoLogin>());
    });

    test('login returns user on success', () async {
      when(
        mockUserApi.loginWithKakaoAccount(),
      ).thenAnswer((_) async => mockOAuthToken);
      when(mockUserApi.me()).thenAnswer((_) async => mockKakaoUser);
      when(mockKakaoUser.id).thenReturn(123);
      when(mockKakaoUser.kakaoAccount).thenReturn(mockKakaoAccount);
      when(mockKakaoAccount.email).thenReturn('test@example.com');
      when(mockKakaoAccount.profile).thenReturn(mockKakaoProfile);
      when(mockKakaoProfile.nickname).thenReturn('testuser');
      when(mockKakaoProfile.profileImageUrl).thenReturn('http://image.url');

      when(
        mockCustomTokenService.createCustomToken(any),
      ).thenAnswer((_) async => '{"token": "custom_firebase_token"}');
      when(
        mockFirebaseAuth.signInWithCustomToken('custom_firebase_token'),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockFirebaseUser);

      final user = await kakaoLogin.login();

      expect(user, equals(mockFirebaseUser));
      verify(mockFirebaseAuth.currentUser?.reload()).called(1);
    });

    test('login returns null when loginWithKakaoAccount fails', () async {
      when(
        mockUserApi.loginWithKakaoAccount(),
      ).thenThrow(Exception('Login failed'));

      final user = await kakaoLogin.login();
      expect(user, isNull);
    });

    test('loginWithKakaoTalk used when KakaoTalk is installed', () async {
      kakaoLogin = KakaoLogin(
        userApi: mockUserApi,
        auth: mockFirebaseAuth,
        customTokenService: mockCustomTokenService,
        isKakaoTalkInstalledFn: () async => true,
        serverLoginFn: () async => {},
      );

      when(
        mockUserApi.loginWithKakaoTalk(),
      ).thenAnswer((_) async => mockOAuthToken);
      when(mockUserApi.me()).thenAnswer((_) async => mockKakaoUser);
      when(mockKakaoUser.id).thenReturn(123);
      when(mockKakaoUser.kakaoAccount).thenReturn(mockKakaoAccount);
      when(mockKakaoAccount.email).thenReturn('test@example.com');
      when(mockKakaoAccount.profile).thenReturn(mockKakaoProfile);
      when(mockKakaoProfile.nickname).thenReturn('testuser');
      when(mockKakaoProfile.profileImageUrl).thenReturn('http://image.url');

      when(
        mockCustomTokenService.createCustomToken(any),
      ).thenAnswer((_) async => '{"token": "custom_firebase_token"}');
      when(
        mockFirebaseAuth.signInWithCustomToken('custom_firebase_token'),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockFirebaseUser);

      final user = await kakaoLogin.login();

      expect(user, equals(mockFirebaseUser));
      verify(mockUserApi.loginWithKakaoTalk()).called(1);
    });

    test('login returns null when customToken is empty', () async {
      when(
        mockUserApi.loginWithKakaoAccount(),
      ).thenAnswer((_) async => mockOAuthToken);
      when(mockUserApi.me()).thenAnswer((_) async => mockKakaoUser);
      when(mockKakaoUser.id).thenReturn(123);
      when(mockKakaoUser.kakaoAccount).thenReturn(mockKakaoAccount);
      when(mockKakaoAccount.email).thenReturn('test@example.com');
      when(mockKakaoAccount.profile).thenReturn(mockKakaoProfile);
      when(mockKakaoProfile.nickname).thenReturn('testuser');
      when(mockKakaoProfile.profileImageUrl).thenReturn('http://image.url');

      when(
        mockCustomTokenService.createCustomToken(any),
      ).thenAnswer((_) async => '{"token": ""}');

      final user = await kakaoLogin.login();
      expect(user, isNull);
    });

    test('serverLogin throws error but login still succeeds', () async {
      kakaoLogin = KakaoLogin(
        userApi: mockUserApi,
        auth: mockFirebaseAuth,
        customTokenService: mockCustomTokenService,
        isKakaoTalkInstalledFn: () async => false,
        serverLoginFn: () async => throw Exception("server error"),
      );

      when(
        mockUserApi.loginWithKakaoAccount(),
      ).thenAnswer((_) async => mockOAuthToken);
      when(mockUserApi.me()).thenAnswer((_) async => mockKakaoUser);
      when(mockKakaoUser.id).thenReturn(123);
      when(mockKakaoUser.kakaoAccount).thenReturn(mockKakaoAccount);
      when(mockKakaoAccount.email).thenReturn('test@example.com');
      when(mockKakaoAccount.profile).thenReturn(mockKakaoProfile);
      when(mockKakaoProfile.nickname).thenReturn('testuser');
      when(mockKakaoProfile.profileImageUrl).thenReturn('http://image.url');

      when(
        mockCustomTokenService.createCustomToken(any),
      ).thenAnswer((_) async => '{"token": "custom_firebase_token"}');
      when(
        mockFirebaseAuth.signInWithCustomToken('custom_firebase_token'),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockFirebaseUser);

      final user = await kakaoLogin.login();
      expect(user, equals(mockFirebaseUser));
    });

    test('logout completes successfully', () async {
      when(
        mockUserApi.unlink(),
      ).thenAnswer((_) async => kakao.UserIdResponse(123));
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await kakaoLogin.logout();

      verify(mockUserApi.unlink()).called(1);
      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('logout completes even if unlink or sign out throws', () async {
      when(mockUserApi.unlink()).thenThrow(Exception('unlink failed'));
      when(mockFirebaseAuth.signOut()).thenThrow(Exception('sign out failed'));

      await kakaoLogin.logout();

      verify(mockUserApi.unlink()).called(1);
      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('loginWithKakaoTalk fails and returns null', () async {
      kakaoLogin = KakaoLogin(
        userApi: mockUserApi,
        auth: mockFirebaseAuth,
        customTokenService: mockCustomTokenService,
        isKakaoTalkInstalledFn: () async => true,
        serverLoginFn: () async => {},
      );

      when(
        mockUserApi.loginWithKakaoTalk(),
      ).thenThrow(Exception('KakaoTalk login failed'));

      final user = await kakaoLogin.login();

      expect(user, isNull);
    });

    test('login returns null when _userApi.me throws', () async {
      when(
        mockUserApi.loginWithKakaoAccount(),
      ).thenAnswer((_) async => mockOAuthToken);
      when(mockUserApi.me()).thenThrow(Exception('Failed to fetch user'));

      final user = await kakaoLogin.login();
      expect(user, isNull);
    });

    test('login returns null if signInWithCustomToken throws', () async {
      when(
        mockUserApi.loginWithKakaoAccount(),
      ).thenAnswer((_) async => mockOAuthToken);
      when(mockUserApi.me()).thenAnswer((_) async => mockKakaoUser);
      when(mockKakaoUser.id).thenReturn(123);
      when(mockKakaoUser.kakaoAccount).thenReturn(mockKakaoAccount);
      when(mockKakaoAccount.profile).thenReturn(mockKakaoProfile);
      when(mockKakaoAccount.email).thenReturn('test@example.com');
      when(mockKakaoProfile.nickname).thenReturn('testuser');
      when(mockKakaoProfile.profileImageUrl).thenReturn('http://image.url');
      when(
        mockCustomTokenService.createCustomToken(any),
      ).thenAnswer((_) async => '{"token": "custom_token"}');
      when(
        mockFirebaseAuth.signInWithCustomToken(any),
      ).thenThrow(Exception('Firebase error'));

      final user = await kakaoLogin.login();
      expect(user, isNull);
    });
    test('can create instance with default parameters', () {
      final login = KakaoLogin(
        isKakaoTalkInstalledFn: () async => false,
        serverLoginFn: () async => {},
      );

      expect(login, isA<KakaoLogin>());
    });
  });
}

// 🔥 MockFirebasePlatform 정의
class MockFirebasePlatform extends FirebasePlatform {
  MockFirebasePlatform() : super();

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return MockFirebaseAppPlatform();
  }

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return MockFirebaseAppPlatform();
  }

  @override
  List<FirebaseAppPlatform> get apps => [MockFirebaseAppPlatform()];
}

class MockFirebaseAppPlatform extends FirebaseAppPlatform {
  MockFirebaseAppPlatform()
    : super(
        '[DEFAULT]',
        const FirebaseOptions(
          apiKey: 'fakeApiKey',
          appId: 'fakeAppId',
          messagingSenderId: 'fakeSenderId',
          projectId: 'fakeProjectId',
        ),
      );

  @override
  String get name => '[DEFAULT]';
}
