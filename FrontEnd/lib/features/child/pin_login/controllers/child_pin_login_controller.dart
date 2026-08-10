import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/child_pin_login_result.dart';
import '../repositories/child_pin_login_repository.dart';

class ChildPinLoginController extends ChangeNotifier {
  final ChildPinLoginRepository _repository;

  ChildPinLoginController({
    ChildPinLoginRepository? repository,
  }) : _repository =
            repository ?? ChildPinLoginRepository();

  String _pin = '';
  bool _isLoading = false;
  bool _isDisposed = false;

  String get pin => _pin;

  bool get isLoading => _isLoading;

  bool get isComplete => _pin.length == 6;

  void updatePin(String value) {
    final normalizedValue =
        value.length > 6
            ? value.substring(0, 6)
            : value;

    if (_pin == normalizedValue) {
      return;
    }

    _pin = normalizedValue;
    _notify();
  }

  Future<ChildPinLoginResult> login() async {
    if (_pin.length != 6) {
      return const ChildPinLoginResult.failure(
        errorCode:
            ChildPinLoginErrorCode.incompleteCode,
      );
    }

    if (_isLoading) {
      return const ChildPinLoginResult.success();
    }

    _isLoading = true;
    _notify();

    try {
      await _repository.login(_pin);

      return const ChildPinLoginResult.success();
    } on DioException catch (error) {
      final backendMessage =
          _readBackendMessage(error);

      return ChildPinLoginResult.failure(
        errorCode:
            ChildPinLoginErrorCode.invalidCode,
        backendMessage: backendMessage,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Child PIN login failed: '
        '$error\n$stackTrace',
      );

      return const ChildPinLoginResult.failure(
        errorCode:
            ChildPinLoginErrorCode.loginFailed,
      );
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  String? _readBackendMessage(
    DioException error,
  ) {
    final data = error.response?.data;

    if (data is! Map) {
      return null;
    }

    final errorMessage =
        data['error']?.toString().trim();

    if (errorMessage != null &&
        errorMessage.isNotEmpty) {
      return errorMessage;
    }

    final message =
        data['message']?.toString().trim();

    if (message == null ||
        message.isEmpty) {
      return null;
    }

    return message;
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}