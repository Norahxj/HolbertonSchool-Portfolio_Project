import 'package:json_annotation/json_annotation.dart';

part 'child_model.g.dart';

@JsonSerializable()
class ChildModel {
  final String id;
  final String name;

  @JsonKey(name: 'birth_date')
  final String birthDate;

  final String? phone;
  final int age;

  @JsonKey(name: 'access_code')
  final String accessCode;

  final String role;

  @JsonKey(name: 'weekly_progress')
  final int weeklyProgress;

  ChildModel({
    required this.id,
    required this.name,
    required this.birthDate,
    this.phone,
    required this.age,
    required this.accessCode,
    required this.role,
    required this.weeklyProgress,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) =>
      _$ChildModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChildModelToJson(this);
}