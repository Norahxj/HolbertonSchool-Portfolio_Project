class WeeklyPlanResult {
  final String proposalId;
  final String proposalStatus;
  final String childId;
  final WeeklyPlan plan;
  final int revisionCount;

  const WeeklyPlanResult({
    required this.proposalId,
    required this.proposalStatus,
    required this.childId,
    required this.plan,
    required this.revisionCount,
  });

  factory WeeklyPlanResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return WeeklyPlanResult(
      proposalId: json['proposal_id'].toString(),
      proposalStatus:
          json['proposal_status']?.toString() ?? 'PENDING',
      childId: json['child_id'].toString(),
      plan: WeeklyPlan.fromJson(
        Map<String, dynamic>.from(
          json['plan'] as Map,
        ),
      ),
      revisionCount:
          (json['revision_count'] as num?)?.toInt() ?? 0,
    );
  }
}


class WeeklyPlan {
  final List<WeeklyPlanTask> tasks;
  final int totalTasks;
  final int weeklyPoints;
  final bool isColdStart;
  final String summaryAr;
  final String summaryEn;

  const WeeklyPlan({
    required this.tasks,
    required this.totalTasks,
    required this.weeklyPoints,
    required this.isColdStart,
    required this.summaryAr,
    required this.summaryEn,
  });

  factory WeeklyPlan.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawTasks = json['tasks'] as List? ?? [];

    return WeeklyPlan(
      tasks: rawTasks
          .map(
            (task) => WeeklyPlanTask.fromJson(
              Map<String, dynamic>.from(
                task as Map,
              ),
            ),
          )
          .toList(),
      totalTasks:
          (json['total_tasks'] as num?)?.toInt() ?? 0,
      weeklyPoints:
          (json['weekly_points'] as num?)?.toInt() ?? 0,
      isColdStart:
          json['is_cold_start'] as bool? ?? false,
      summaryAr:
          json['summary_ar']?.toString() ?? '',
      summaryEn:
          json['summary_en']?.toString() ?? '',
    );
  }
}


class WeeklyPlanTask {
  final String source;
  final String? bankId;

  final String titleEn;
  final String titleAr;

  final String descriptionEn;
  final String descriptionAr;

  final String category;
  final int points;
  final String frequency;
  final String reason;

  const WeeklyPlanTask({
    required this.source,
    required this.bankId,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.category,
    required this.points,
    required this.frequency,
    required this.reason,
  });

  factory WeeklyPlanTask.fromJson(
    Map<String, dynamic> json,
  ) {
    return WeeklyPlanTask(
      source: json['source']?.toString() ?? '',
      bankId: json['bank_id']?.toString(),
      titleEn: json['title_en']?.toString() ?? '',
      titleAr: json['title_ar']?.toString() ?? '',
      descriptionEn:
          json['description_en']?.toString() ?? '',
      descriptionAr:
          json['description_ar']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      points:
          (json['points'] as num?)?.toInt() ?? 0,
      frequency:
          json['frequency']?.toString() ?? 'ONCE',
      reason: json['reason']?.toString() ?? '',
    );
  }

  String titleFor(String languageCode) {
    return languageCode == 'ar'
        ? titleAr
        : titleEn;
  }

  String descriptionFor(String languageCode) {
    return languageCode == 'ar'
        ? descriptionAr
        : descriptionEn;
  }
}


class WeeklyPlanApprovalResult {
  final String proposalId;
  final String proposalStatus;
  final String childId;
  final int createdTasksCount;
  final List<String> createdTaskIds;

  const WeeklyPlanApprovalResult({
    required this.proposalId,
    required this.proposalStatus,
    required this.childId,
    required this.createdTasksCount,
    required this.createdTaskIds,
  });

  factory WeeklyPlanApprovalResult.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawTaskIds =
        json['created_task_ids'] as List? ?? [];

    return WeeklyPlanApprovalResult(
      proposalId: json['proposal_id'].toString(),
      proposalStatus:
          json['proposal_status']?.toString() ?? 'APPROVED',
      childId: json['child_id'].toString(),
      createdTasksCount:
          (json['created_tasks_count'] as num?)?.toInt() ?? 0,
      createdTaskIds: rawTaskIds
          .map((id) => id.toString())
          .toList(),
    );
  }
}