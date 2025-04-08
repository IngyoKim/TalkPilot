import 'package:flutter/material.dart';

/// Loading 중에 표시
class LoadingIndicator extends StatelessWidget {
  final bool isFetching;
  final String? message; // 로딩 중에 표시될 메시지

  const LoadingIndicator({super.key, required this.isFetching, this.message});

  @override
  Widget build(BuildContext context) {
    if (!isFetching) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16.0),
            Text(
              message!,
              style: const TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
