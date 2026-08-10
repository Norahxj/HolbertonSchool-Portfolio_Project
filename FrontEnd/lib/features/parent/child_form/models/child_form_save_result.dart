import '../../../../models/child_model.dart';
import 'child_form_errors.dart';

class ChildFormSaveResult {
  final ChildModel? child;
  final ChildFormErrorCode? errorCode;
  final String? backendMessage;

  const ChildFormSaveResult._({
    this.child,
    this.errorCode,
    this.backendMessage,
  });

  const ChildFormSaveResult.success(ChildModel child) : this._(child: child);

  const ChildFormSaveResult.failure({
    required ChildFormErrorCode errorCode,
    String? backendMessage,
  }) : this._(errorCode: errorCode, backendMessage: backendMessage);

  const ChildFormSaveResult.validationFailure() : this._();

  bool get isSuccess => child != null;
}
