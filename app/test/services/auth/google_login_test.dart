import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:talk_pilot/src/services/auth/google_login.dart';

@GenerateMocks(
  [],
  customMocks: [
    MockSpec<GoogleSignIn>(as: #MockGoogleSignInCustom),
    MockSpec<GoogleSignInAccount>(as: #MockGoogleSignInAccountCustom),
    MockSpec<GoogleSignInAuthentication>(as: #MockGoogleSignInAuthCustom),
    MockSpec<FirebaseAuth>(as: #MockFirebaseAuthCustom),
    MockSpec<UserCredential>(as: #MockUserCredentialCustom),
    MockSpec<User>(as: #MockUserCustom),
  ],
)
import 'google_login_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // FirebasePlatform.instance 를 Mock 처리
    FirebasePlatform.instance = MockFirebasePlatform();

    // initializeApp 정상 호출
    await Firebase.initializeApp();
  });

  group('GoogleLogin', () {
    late GoogleLogin googleLogin;
    late MockGoogleSignInCustom mockGoogleSignIn;
    late MockFirebaseAuthCustom mockFirebaseAuth;
    late MockGoogleSignInAccountCustom mockAccount;
    late MockGoogleSignInAuthCustom mockAuth;
    late MockUserCredentialCustom mockUserCredential;
    late MockUserCustom mockUser;
    late bool serverLoginCalled;

    setUp(() {
      mockGoogleSignIn = MockGoogleSignInCustom();
      mockFirebaseAuth = MockFirebaseAuthCustom();
      mockAccount = MockGoogleSignInAccountCustom();
      mockAuth = MockGoogleSignInAuthCustom();
      mockUserCredential = MockUserCredentialCustom();
      mockUser = MockUserCustom();
      serverLoginCalled = false;

      googleLogin = GoogleLogin(
        googleSignIn: mockGoogleSignIn,
        firebaseAuth: mockFirebaseAuth,
        serverLogin: () async {
          serverLoginCalled = true;
        },
      );
    });

    test('login returns null when user cancels sign-in', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      final user = await googleLogin.login();

      expect(user, isNull);
    });

    test('login returns null when token is missing', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
      when(mockAuth.accessToken).thenReturn(null);
      when(mockAuth.idToken).thenReturn(null);

      final user = await googleLogin.login();

      expect(user, isNull);
    });

    test('login returns user on success and calls serverLogin', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
      when(mockAuth.accessToken).thenReturn('access_token');
      when(mockAuth.idToken).thenReturn('id_token');
      when(
        mockFirebaseAuth.signInWithCredential(any),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);

      final user = await googleLogin.login();

      expect(user, equals(mockUser));
      expect(serverLoginCalled, isTrue);
    });

    test('logout does not throw even if sign out fails', () async {
      when(
        mockGoogleSignIn.signOut(),
      ).thenThrow(Exception('Google sign out failed'));
      when(
        mockFirebaseAuth.signOut(),
      ).thenThrow(Exception('Firebase sign out failed'));

      await googleLogin.logout();

      verify(mockGoogleSignIn.signOut()).called(1);
      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('can create instance with default parameters', () {
      final login = GoogleLogin();

      expect(login, isA<GoogleLogin>());
    });

    test('login returns user even if serverLogin throws', () async {
      googleLogin = GoogleLogin(
        googleSignIn: mockGoogleSignIn,
        firebaseAuth: mockFirebaseAuth,
        serverLogin: () async => throw Exception("server error"),
      );

      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
      when(mockAuth.accessToken).thenReturn('access_token');
      when(mockAuth.idToken).thenReturn('id_token');
      when(
        mockFirebaseAuth.signInWithCredential(any),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);

      final user = await googleLogin.login();

      expect(user, equals(mockUser));
    });

    test('logout completes even if Google signOut throws', () async {
      when(
        mockGoogleSignIn.signOut(),
      ).thenThrow(Exception('Google sign out failed'));
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await googleLogin.logout();

      verify(mockGoogleSignIn.signOut()).called(1);
      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('logout completes even if Firebase signOut throws', () async {
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async {
        return null;
      });
      when(
        mockFirebaseAuth.signOut(),
      ).thenThrow(Exception('Firebase sign out failed'));

      await googleLogin.logout();

      verify(mockGoogleSignIn.signOut()).called(1);
      verify(mockFirebaseAuth.signOut()).called(1);
    });
  });
}

// MockFirebasePlatform 정의
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
