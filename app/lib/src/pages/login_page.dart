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
                  children: [
                    TextButton(
                      onPressed: () async {
                        tryLogin(
                          context: context,
                          loginAction: () async {
                            /// 여기에 카카오 로그인 로직 구현 예정
                          },
                          setLoading: _setLoading,
                        );
                      },
                      child: Text("kakao"),
                    ),
                    TextButton(
                      onPressed: () async {
                        tryLogin(
                          context: context,
                          loginAction: () async {
                            /// 여기에 구글 로그인 로직 구현 예정
                          },
                          setLoading: _setLoading,
                        );
                      },
                      child: Text("google"),
                    ),
                  ],
                ),
      ),
    );
  }
}
