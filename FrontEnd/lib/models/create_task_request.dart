import 'package:json_annotation/json_annotation.dart';

part 'create_task_request.g.dart';

@JsonSerializable()
class CreateTaskRequest {
  @JsonKey(name: 'child_ids')
  final List<String> childIds;

  final String title;
  final String description;
  final int points;

  @JsonKey(name: 'task_frequency')
  final String taskFrequency;

  @JsonKey(name: 'recurrence_day')
  final int? recurrenceDay;

  final String category;

  @JsonKey(name: 'is_auto_verified')
  final bool isAutoVerified;

  const CreateTaskRequest({
    required this.childIds,
    required this.title,
    required this.description,
    required this.points,
    required this.taskFrequency,
    this.recurrenceDay,
    required this.category,
    required this.isAutoVerified,
  });

  factory CreateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTaskRequestToJson(this);
}