import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/child_progress_controller.dart';
import '../widgets/child_progress_view.dart';

class ChildProgressScreen
    extends StatefulWidget {
  const ChildProgressScreen({
    super.key,
  });

  @override
  State<ChildProgressScreen> createState() {
    return _ChildProgressScreenState();
  }
}

class _ChildProgressScreenState
    extends State<ChildProgressScreen> {
  late final ChildProgressController
      _controller;

  @override
  void initState() {
    super.initState();

    _controller = ChildProgressController()
      ..loadProgress();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _controller.loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: ChildProgressView(
        onRefresh: _refresh,
        onRetry: _refresh,
      ),
    );
  }
}