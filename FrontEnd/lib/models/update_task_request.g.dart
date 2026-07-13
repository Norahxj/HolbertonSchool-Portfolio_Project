// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_task_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateTaskRequest _$UpdateTaskRequestFromJson(Map<String, dynamic> json) =>
    UpdateTaskRequest(
      title: json['title'] as String?,
      description: json['description'] as String?,
      points: (json['points'] as num?)?.toInt(),
      taskFrequency: json['task_frequency'] as String?,
      recurrenceDay: (json['recurrence_day'] as num?)?.toInt(),
      category: json['category'] as String?,
      isAutoVerified: json['is_auto_verified'] as bool?,
    );

Map<String, dynamic> _$UpdateTaskRequestToJson(UpdateTaskRequest instance) =>
    <String, dynamic>{
      'title': ?instance.title,
      'description': ?instance.description,
      'points': ?instance.points,
      'task_frequency': ?instance.taskFrequency,
      'recurrence_day': ?instance.recurrenceDay,
      'category': ?instance.category,
      'is_auto_verified': ?instance.isAutoVerified,
    };
