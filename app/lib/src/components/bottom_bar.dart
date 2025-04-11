import 'package:flutter/material.dart';
import 'package:talk_pilot/src/pages/schedule_page.dart';
import 'package:talk_pilot/src/pages/work_page.dart';
import 'package:talk_pilot/src/pages/profile_page/profile_page.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar>
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
        children: [const SchedulePage(), WorkPage(), const ProfilePage()],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              icon: Icon(Icons.calendar_month_rounded, size: 24),
              text: "Schedule",
            ),
            Tab(icon: Icon(Icons.work_rounded, size: 24), text: "Work"),
            Tab(icon: Icon(Icons.person_rounded, size: 24), text: "Profile"),
          ],
        ),
      ),
    );
  }
}
