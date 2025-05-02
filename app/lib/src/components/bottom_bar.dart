import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:talk_pilot/src/pages/schedule_page/schedule_page.dart';
import 'package:talk_pilot/src/pages/work_page/work_page.dart';
import 'package:talk_pilot/src/pages/profile_page/profile_page.dart';

import 'package:talk_pilot/src/provider/project_provider.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/components/toast_message.dart';
import 'package:talk_pilot/src/components/loading_indicator.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isUserLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userProvider = context.read<UserProvider>();
      final projectProvider = context.read<ProjectProvider>();

      await UserService().initUser(user);
      await userProvider.loadUser(user.uid);
      await projectProvider.initAllProjects(user.uid);

      ToastMessage.show("${user.displayName}님 환영합니다.");
    }
    if (mounted) setState(() => _isUserLoaded = true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUserLoaded) {
      return const Scaffold(
        body: LoadingIndicator(
          isFetching: true,
          message: "사용자 정보를 불러오는 중입니다...",
        ),
      );
    }

    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [const SchedulePage(), WorkPage(), const ProfilePage()],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month_rounded), text: "Schedule"),
            Tab(icon: Icon(Icons.work_rounded), text: "Work"),
            Tab(icon: Icon(Icons.person_rounded), text: "Profile"),
          ],
        ),
      ),
    );
  }
}
