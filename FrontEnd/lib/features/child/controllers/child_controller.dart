import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/storage/secure_storage.dart';
import 'package:frontend/features/parent/services/child_api_service.dart';

import '../../../models/child_model.dart';
import '../../../models/task_assignment_model.dart';
import '../../../services/task_assignment_api_service.dart';

class ChildController {
  final TaskAssignmentApiService _taskService = TaskAssignmentApiService();
  final ChildApiService _childService = ChildApiService();

  ChildModel? child;
  List<TaskAssignmentModel> assignments = [];

  bool isLoading = true;
  bool isCompleting = false;

  bool get hasData => child != null;

  bool isPending(String status) => status == 'PENDING';
  bool isPendingReview(String status) => status == 'PENDING_REVIEW';
  bool isApproved(String status) => status == 'APPROVED';
  bool isRejected(String status) => status == 'REJECTED';
  bool isCompleted(TaskAssignmentModel assignment) =>
      assignment.status == 'APPROVED';
  Future<void> loadData() async {
  isLoading = true;

  try {
    final data = await SecureStorage.getChild();

    if (data != null) {
      child = data;

      // Child token
      assignments = await _taskService.getMyAssignments();
    }
  } catch (e) {
    print("LOAD CHILD DATA ERROR: $e");
  } finally {
    isLoading = false;
  }
}

Future<void> load(String childId) async {
  isLoading = true;

  try {
    // Parent gets child data
    child = await _childService.getChildById(childId);

    // Parent gets this child's assignments
    assignments = await _taskService.getChildAssignments(childId);
  } catch (e) {
    print("LOAD CHILD PROFILE ERROR: $e");
  } finally {
    isLoading = false;
  }
}

Future<TaskAssignmentModel?> completeTask(String assignmentId) async {
  if (isCompleting) return null;

  isCompleting = true;

  try {
    final updatedAssignment =
        await _taskService.completeAssignment(assignmentId);

    print("UPDATED ASSIGNMENT: $updatedAssignment");
    print("UPDATED STATUS: ${updatedAssignment.status}");

    final index = assignments.indexWhere(
      (e) => e.id == updatedAssignment.id,
    );

    if (index != -1) {
      assignments[index] = updatedAssignment;
    }

    return updatedAssignment;
  } catch (e) {
    print("COMPLETE TASK ERROR: $e");
    return null;
  } finally {
    isCompleting = false;
  }
}

  IconData taskIcon(String? category) {
    switch (category) {
      case 'MORAL':
        return Icons.menu_book_outlined;
      case 'SOCIAL':
        return Icons.groups_outlined;
      case 'FINANCIAL':
        return Icons.credit_card;
      case 'RELIGIOUS':
        return Icons.mosque_outlined;
      default:
        return Icons.assignment_outlined;
    }
  }

  IconData statusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.radio_button_unchecked;
      case 'PENDING_REVIEW':
        return Icons.hourglass_top;
      case 'APPROVED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      default:
        return Icons.task;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.grey;
      case 'PENDING_REVIEW':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getBorderColor(String status) {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFF0DFA8);
      case 'PENDING_REVIEW':
        return Colors.orange.shade100;
      case 'APPROVED':
        return Colors.green.shade100;
      case 'REJECTED':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade300;
    }
  }

  Color getCircleColor(String status) {
    switch (status) {
      case 'PENDING':
        return AppColors.gold;
      case 'PENDING_REVIEW':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String frequencyLabel(String frequency) {
    switch (frequency) {
      case 'DAILY':
        return 'يوميًا';
      case 'WEEKLY':
        return 'أسبوعيًا';
      case 'MONTHLY':
        return 'شهريًا';
      default:
        return frequency;
    }
  }

  String statusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'فلتنجز المهمة';
      case 'PENDING_REVIEW':
        return '⏳ بانتظار موافقة ولي الأمر';
      case 'APPROVED':
        return '✅ تم اعتماد المهمة';
      case 'REJECTED':
        return '❌ تم رفض المهمة';
      default:
        return status;
    }
  }

  int get completedTasks =>
      assignments.where((e) => e.status == "APPROVED").length;

  int get totalTasks => assignments.length;

  double get weeklyProgress {
    if (assignments.isEmpty) return 0;
    return completedTasks / assignments.length;
  }

  int get weeklyProgressPercent => (weeklyProgress * 100).round();
}
