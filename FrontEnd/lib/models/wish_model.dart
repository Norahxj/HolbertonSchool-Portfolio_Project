///creating a link for wish object - to eather pending or approve or reject
class WishModel {
  final String id;
  final String childId;
  final String name;
  final int? targetPoints;
  final String status; // "pending", "approved", "rejected", "achieved"
  final String? reviewedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;

  WishModel({
    required this.id,
    required this.childId,
    required this.name,
    this.targetPoints,
    required this.status,
    this.reviewedBy,
    this.approvedAt,
    required this.createdAt,
  } );

  factory WishModel.fromJson(Map<String, dynamic> json) {
    return WishModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      name: json['name'] as String,
      targetPoints: json['target_points'] as int?,
      status: json['status'] as String,
      reviewedBy: json['reviewed_by'] as String?,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'name': name,
      'target_points': targetPoints,
      'status': status,
      'reviewed_by': reviewedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
