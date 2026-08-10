import '../../../../models/child_model.dart';
import '../../services/child_api_service.dart';

class ChildFormRepository {
  final ChildApiService _childApiService;

  ChildFormRepository({ChildApiService? childApiService})
    : _childApiService = childApiService ?? ChildApiService();

  Future<ChildModel> addChild({
    required String name,
    required String birthDate,
    required int avatarIndex,
    String? phone,
  }) {
    return _childApiService.addChild(
      name: name,
      birthDate: birthDate,
      avatarIndex: avatarIndex,
      phone: phone,
    );
  }

  Future<ChildModel> updateChild({
    required String childId,
    required String name,
    required String birthDate,
    required int avatarIndex,
    String? phone,
  }) {
    return _childApiService.updateChild(
      childId: childId,
      name: name,
      birthDate: birthDate,
      avatarIndex: avatarIndex,
      phone: phone,
    );
  }
}
