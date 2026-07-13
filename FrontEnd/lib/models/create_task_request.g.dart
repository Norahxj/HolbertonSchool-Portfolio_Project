// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_task_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTaskRequest _$CreateTaskRequestFromJson(Map<String, dynamic> json) =>
    CreateTaskRequest(
      childIds: (json['child_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      title: json['title'] as String,
      description: json['description'] as String,
      points: (json['points'] as num).toInt(),
      taskFrequency: json['task_frequency'] as String,
      recurrenceDay: (json['recurrence_day'] as num?)?.toInt(),
      category: json['category'] as String,
      isAutoVerified: json['is_auto_verified'] as bool,
    );

Map<String, dynamic> _$CreateTaskRequestToJson(CreateTaskRequest instance) =>
    <String, dynamic>{
      'child_ids': instance.childIds,
      'title': instance.title,
      'description': instance.description,
      'points': instance.points,
      'task_frequency': instance.taskFrequency,
      'recurrence_day': instance.recurrenceDay,
      'category': instance.category,
      'is_auto_verified': instance.isAutoVerified,
    };
