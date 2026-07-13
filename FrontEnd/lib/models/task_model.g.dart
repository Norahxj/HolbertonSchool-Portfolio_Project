// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  points: (json['points'] as num).toInt(),
  taskFrequency: json['task_frequency'] as String,
  recurrenceDay: (json['recurrence_day'] as num?)?.toInt(),
  category: json['category'] as String?,
  isAutoVerified: json['is_auto_verified'] as bool,
  createdBy: json['created_by'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'points': instance.points,
  'task_frequency': instance.taskFrequency,
  'recurrence_day': instance.recurrenceDay,
  'category': instance.category,
  'is_auto_verified': instance.isAutoVerified,
  'created_by': instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
};

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(message: json['message'] as String);

Map<String, dynamic> _$MessageResponseToJson(MessageResponse instance) =>
    <String, dynamic>{'message': instance.message};
