import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../child_form/screens/child_form_screen.dart';
import '../../parent_child_details/screens/parent_child_details_screen.dart';
import '../../task_review/screens/task_review_screen.dart';
import '../controllers/parent_dashboard_controller.dart';
import '../models/parent_dashboard_data.dart';
import '../widgets/parent_dashboard_view.dart';

class ParentDashboardScreen extends StatefulWidget {
  final VoidCallback onChildrenChanged;

  const ParentDashboardScreen({super.key, required this.onChildrenChanged});

  @override
  State<ParentDashboardScreen> createState() {
    return _ParentDashboardScreenState();
  }
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  late final ParentDashboardController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ParentDashboardController()..loadDashboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openAddChild() async {
    final wasAdded = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return const ChildFormScreen.add();
        },
      ),
    );

    if (!mounted || wasAdded != true) {
      return;
    }

    await _controller.refresh();

    if (!mounted) {
      return;
    }

    widget.onChildrenChanged();
  }

  Future<void> _openTaskReview() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return const TaskReviewScreen();
        },
      ),
    );

    if (!mounted) {
      return;
    }

    await _controller.refresh();
  }

  Future<void> _openChildDetails(ParentDashboardChildItem item) async {
    final childChanged = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ParentChildDetailsScreen(
            child: item.child,
            points: item.points,
            progressPercentage: item.dashboard.progressPercentage.round(),
          );
        },
      ),
    );

    if (!mounted || childChanged != true) {
      return;
    }

    await _controller.refresh();

    if (!mounted) {
      return;
    }

    widget.onChildrenChanged();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: ParentDashboardView(
        onAddChild: _openAddChild,
        onReviewTasks: _openTaskReview,
        onChildTap: _openChildDetails,
      ),
    );
  }
}
