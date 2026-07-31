class WishModel {
  final String id;
  final String childId;
  final String name;
  final int? targetPoints;
  final String status;
  final String? reviewedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;

  // تكون موجودة عند طلب أمنيات جميع أطفال ولي الأمر
  final String? childName;
  final int? childAvatarIndex;

  const WishModel({
    required this.id,
    required this.childId,
    required this.name,
    this.targetPoints,
    required this.status,
    this.reviewedBy,
    this.approvedAt,
    required this.createdAt,
    this.childName,
    this.childAvatarIndex,
  });

  factory WishModel.fromJson(Map<String, dynamic> json) {
    final childData = json['child'] as Map<String, dynamic>?;

    return WishModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      name: json['name'] as String,
      targetPoints: (json['target_points'] as num?)?.toInt(),
      status: json['status'] as String,
      reviewedBy: json['reviewed_by'] as String?,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      childName: childData?['name'] as String?,
      childAvatarIndex: (childData?['avatar_index'] as num?)?.toInt(),
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
      if (childName != null || childAvatarIndex != null)
        'child': {'name': childName, 'avatar_index': childAvatarIndex},
    };
  }
}
