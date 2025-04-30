import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk_pilot/src/services/cpm/cpm_calculate_service.dart';

class CpmCalculatePage extends StatelessWidget {
  const CpmCalculatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CpmCalculateService(),
      child: const _CpmCalculateView(),
    );
  }
}

class _CpmCalculateView extends StatelessWidget {
  const _CpmCalculateView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<CpmCalculateService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'CPM 계산',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              service.displayedSentence,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: service.toggleTimer,
              child: Text(
                service.isRunning ? '종료' : '시작',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    service.isRunning ? Colors.indigo : Colors.deepPurple,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 30),
            if (service.cpmResult != null)
              Text(
                '당신의 CPM: ${service.cpmResult!.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
          ],
        ),
      ),
    );
  }
}
