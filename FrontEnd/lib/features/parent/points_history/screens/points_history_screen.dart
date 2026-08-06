import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/points_history_controller.dart';
import '../widgets/points_history_view.dart';

class PointsHistoryScreen extends StatefulWidget {
  final String childId;
  final String childName;

  const PointsHistoryScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<PointsHistoryScreen> createState() {
    return _PointsHistoryScreenState();
  }
}

class _PointsHistoryScreenState extends State<PointsHistoryScreen> {
  late final PointsHistoryController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PointsHistoryController(childId: widget.childId)
      ..loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: PointsHistoryView(
        childName: widget.childName,
        onBack: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
