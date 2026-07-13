import 'package:json_annotation/json_annotation.dart';

part 'update_task_request.g.dart';

@JsonSerializable(includeIfNull: false)
class UpdateTaskRequest {
  final String? title;
  final String? description;
  final int? points;

  @JsonKey(name: 'task_frequency')
  final String? taskFrequency;

  @JsonKey(name: 'recurrence_day')
  final int? recurrenceDay;

  final String? category;

  @JsonKey(name: 'is_auto_verified')
  final bool? isAutoVerified;

  const UpdateTaskRequest({
    this.title,
    this.description,
    this.points,
    this.taskFrequency,
    this.recurrenceDay,
    this.category,
    this.isAutoVerified,
  });

  factory UpdateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTaskRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateTaskRequestToJson(this);
}