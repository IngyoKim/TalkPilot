import 'package:flutter/material.dart';
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
                          '',//로고 사진
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
                        // 여기에 카카오 로그인 로직 구현
                        await Future.delayed(const Duration(seconds: 2)); // 임시 딜레이
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
                              '',//카카오 사진진
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
                        // 구글 로그인 로직 구현
                        tryLogin(
                        context: context,
                        loginAction: () async {
                        // 여기에 카카오 로그인 로직 구현
                        await Future.delayed(const Duration(seconds: 2)); // 임시 딜레이
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
                              '',//구글 사진
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