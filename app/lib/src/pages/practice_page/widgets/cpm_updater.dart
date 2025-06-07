import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';

class CpmUpdater extends StatefulWidget {
  final double progress;
  final double currentCpm;
  final bool alreadyUpdated;
  final VoidCallback onUpdated;

  const CpmUpdater({
    super.key,
    required this.progress,
    required this.currentCpm,
    required this.alreadyUpdated,
    required this.onUpdated,
  });

  @override
  State<CpmUpdater> createState() => _CpmUpdaterState();
}

class _CpmUpdaterState extends State<CpmUpdater> {
  final _userService = UserService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryUpdateCpmIfEligible();
  }

  @override
  void didUpdateWidget(covariant CpmUpdater oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tryUpdateCpmIfEligible();
  }

  void _tryUpdateCpmIfEligible() async {
    if (widget.alreadyUpdated) return;
    if (widget.progress < 0.9 || widget.currentCpm <= 0) return;

    final user = context.read<UserProvider>().currentUser;
    if (user == null) return;

    final existing = await _userService.readUser(user.uid);
    if (existing == null) return;

    final newAvg = ((existing.cpm! + widget.currentCpm) / 2).toStringAsFixed(2);

    await _userService.updateUser(user.uid, {'cpm': double.parse(newAvg)});

    widget.onUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
