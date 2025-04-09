import 'package:flutter/material.dart';

import 'package:talk_pilot/src/login/kakao_login.dart';
import 'package:talk_pilot/src/login/google_login.dart';
import 'package:talk_pilot/src/components/loading_indicator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  void _setLoading(bool isLoading) {
    if (mounted) {
      setState(() => _isLoading = isLoading);
    }
  }

  Future<void> tryLogin({
    required BuildContext context,
    required Future<void> Function() loginAction,
    required void Function(bool) setLoading,
  }) async {
    setLoading(true);
    try {
      await loginAction();
    } catch (error) {
      debugPrint("로그인에 실패했습니다: $error");
    } finally {
      setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child:
            _isLoading
                ? const LoadingIndicator(isFetching: true)
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: [
                        Image.asset(
                          'assets/login/logo.png', // 로고 사진 추가하기기
                          height: 200,
                          width: 200,
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Talk Pilot',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          '로그인을 위해\nSNS 계정을 연결해주세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: () {
                        // 카카오 로그인 로직 구현
                        tryLogin(
                          context: context,
                          loginAction: () async {
                            final user = await KakaoLogin().login();
                            if (user == null) {
                              throw Exception("Kakao login failed");
                            }
                          },
                          setLoading: _setLoading,
                        );
                      },
                      child: Container(
                        width: 300,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/login/kakao.png', // 카카오 로고 추가하기
                              height: 32,
                              width: 32,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Continue with Kakao',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        tryLogin(
                          context: context,
                          loginAction: () async {
                            final user = await GoogleLogin().login();
                            if (user == null) {
                              throw Exception("Google login failed");
                            }
                          },
                          setLoading: _setLoading,
                        );
                      },
                      child: Container(
                        width: 300,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/login/google.png', // 구글 로고 추가하기
                              height: 32,
                              width: 32,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Continue with Google',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      'CBNU Department of Computer Engineering, 2025',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
      ),
    );
  }
}
