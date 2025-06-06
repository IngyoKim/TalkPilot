import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:talk_pilot/src/services/auth/custom_token_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('CustomTokenService', () {
    late String fakeUrl;

    setUpAll(() async {
      await dotenv.load(fileName: '.env');
    });

    setUp(() {
      fakeUrl = 'https://fake.url';
    });

    test('returns custom token on success', () async {
      bool requestReceived = false;

      final mockClient = MockClient((request) async {
        requestReceived = true;
        expect(request.url.toString(), fakeUrl);
        expect(request.method, equals('POST'));
        return http.Response('mock_token_string', 200);
      });

      final service = CustomTokenService(client: mockClient, url: fakeUrl);
      final token = await service.createCustomToken({
        'uid': 'user123',
        'email': 'test@test.com',
      });

      expect(requestReceived, isTrue);
      expect(token, equals('mock_token_string'));
    });

    test('throws Exception on HTTP failure', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final service = CustomTokenService(client: mockClient, url: fakeUrl);

      expect(
        () => service.createCustomToken({'uid': 'user123'}),
        throwsA(isA<Exception>()),
      );
    });

    test('throws and logs error on network exception', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network failed');
      });

      final service = CustomTokenService(client: mockClient, url: fakeUrl);

      expect(
        () => service.createCustomToken({'uid': 'user456'}),
        throwsA(isA<Exception>()),
      );
    });

    test('throws and logs error on network exception', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network failed');
      });

      final service = CustomTokenService(client: mockClient, url: fakeUrl);

      expect(
        () => service.createCustomToken({'uid': 'user456'}),
        throwsA(isA<Exception>()),
      );
    });

    test('uses default client and url when not provided', () {
      final service = CustomTokenService();

      expect(service, isA<CustomTokenService>());
    });
  });
}
