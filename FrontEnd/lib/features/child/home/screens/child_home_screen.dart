import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app.dart';
import '../../../../models/task_assignment_model.dart';
import '../../../auth/services/auth_api_service.dart';
import '../../screens/child_settings_screen.dart';
import '../../screens/child_task_details_screen.dart';
import '../controllers/child_home_controller.dart';
import '../models/child_home_action_result.dart';
import '../widgets/child_home_view.dart';

class ChildHomeScreen extends StatefulWidget {
  final bool isArabic;
  final VoidCallback onLanguageToggle;

  const ChildHomeScreen({
    super.key,
    required this.isArabic,
    required this.onLanguageToggle,
  });

  @override
  State<ChildHomeScreen> createState() {
    return _ChildHomeScreenState();
  }
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  late final ChildHomeController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ChildHomeController()..loadHome();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeAssignment(String assignmentId) async {
    final result = await _controller.completeAssignment(assignmentId);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showCompleteError(result);
      return;
    }

    _showMessage(
      widget.isArabic
          ? 'أحسنت! أُرسلت المهمة إلى ولي أمرك للمراجعة.'
          : 'Well done! The task was sent to your guardian for review.',
    );
  }

  void _showCompleteError(ChildHomeActionResult result) {
    final message =
        result.backendMessage ??
        (widget.isArabic
            ? 'تعذّر إكمال المهمة. حاول مرة أخرى.'
            : 'The task could not be completed. Please try again.');

    _showMessage(message);
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  Future<void> _openAssignmentDetails(
    TaskAssignmentModel assignment,
    IconData icon,
  ) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ChildTaskDetailsScreen(
            assignment: assignment,
            icon: icon,
            isArabic: widget.isArabic,
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    await _controller.refreshTasksAndPoints();
  }

  void _openSettings() {
    final child = _controller.child;

    if (child == null) {
      return;
    }

    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ChildSettingsScreen(
            childName: child.name,
            avatarIndex: child.avatarIndex,
            isArabic: widget.isArabic,
            onLanguageToggle: widget.onLanguageToggle,
            onLogout: _logout,
          );
        },
      ),
    );
  }

  Future<void> _logout() async {
    await AuthApiService().logout();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const AsalahApp(),
      ),
      (route) => false,
    );
  }

  Future<void> _refresh() async {
    await _controller.refresh();
  }

  Future<void> _retry() async {
    await _controller.loadHome();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: ChildHomeView(
        isArabic: widget.isArabic,
        onSettingsPressed: _openSettings,
        onRefresh: _refresh,
        onRetry: _retry,
        onCompleteAssignment: _completeAssignment,
        onAssignmentTap: _openAssignmentDetails,
      ),
    );
  }
}