import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [], // 이곳에 페이지들 연결 예정정
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: [], // 이곳에 페이지로 연결할 탭(버튼) 구성 예정정
        ),
      ),
    );
  }
}
