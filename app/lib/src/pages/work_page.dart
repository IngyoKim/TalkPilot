import 'package:flutter/material.dart';

class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      /// 이곳에 발표 프로젝트 list 구현
      /// 나중에 ui 구현 후 로직 연결할 예정
    );
  }
}
