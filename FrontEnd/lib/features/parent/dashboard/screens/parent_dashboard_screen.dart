import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/parent_dashboard_controller.dart';
import '../repositories/parent_dashboard_repository.dart';
import '../widgets/parent_dashboard_view.dart';

class ParentDashboardScreen extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onChildrenChanged;

  const ParentDashboardScreen({
    super.key,
    required this.isArabic,
    required this.onChildrenChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return ParentDashboardController(ParentDashboardRepository())
          ..loadDashboard();
      },
      child: ParentDashboardView(
        isArabic: isArabic,
        onChildrenChanged: onChildrenChanged,
      ),
    );
  }
}
