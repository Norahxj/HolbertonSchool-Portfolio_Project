// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChildModel _$ChildModelFromJson(Map<String, dynamic> json) => ChildModel(
  id: json['id'] as String,
  name: json['name'] as String,
  birthDate: json['birth_date'] as String,
  phone: json['phone'] as String?,
  age: (json['age'] as num).toInt(),
  accessCode: json['access_code'] as String,
  role: json['role'] as String,
  weeklyProgress: (json['weekly_progress'] as num).toInt(),
);

Map<String, dynamic> _$ChildModelToJson(ChildModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'birth_date': instance.birthDate,
      'phone': instance.phone,
      'age': instance.age,
      'access_code': instance.accessCode,
      'role': instance.role,
      'weekly_progress': instance.weeklyProgress,
    };
