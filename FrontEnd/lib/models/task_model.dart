import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel {
  final String id;
  final String title;
  final String description;
  final int points;

  @JsonKey(name: 'task_frequency')
  final String taskFrequency;

  @JsonKey(name: 'recurrence_day')
  final int? recurrenceDay;

  final String? category;

  @JsonKey(name: 'is_auto_verified')
  final bool isAutoVerified;

  @JsonKey(name: 'created_by')
  final String createdBy;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.taskFrequency,
    this.recurrenceDay,
    this.category,
    required this.isAutoVerified,
    required this.createdBy,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
}
@JsonSerializable()
class MessageResponse {
  final String message;

  const MessageResponse({
    required this.message,
  });
}