import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/parent_child_details_controller.dart';
import '../models/parent_dashboard_data.dart';
import '../repositories/parent_child_details_repository.dart';
import '../parent_child_details/widgets/parent_child_details_view.dart';

class ParentChildDetailsScreen extends StatelessWidget {
  final ParentDashboardChildItem item;
  final bool isArabic;

  const ParentChildDetailsScreen({
    super.key,
    required this.item,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ParentChildDetailsController(ParentChildDetailsRepository())
            ..loadTasks(item.child.id),
      child: ParentChildDetailsView(item: item, isArabic: isArabic),
    );
  }
}
