import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/auth_action_result.dart';
import '../repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository;

  AuthController({
    AuthRepository? repository,
  }) : _repository = repository ?? AuthRepository();

  bool _isSubmitting = false;
  bool _isDisposed = false;

  bool get isSubmitting => _isSubmitting;

  Future<AuthActionResult> login({
    required String email,
    required String password,
  }) async {
    if (_isSubmitting) {
      return const AuthActionResult.failure(
        errorCode: AuthErrorCode.loginFailed,
      );
    }

    _isSubmitting = true;
    _notify();

    try {
      await _repository.login(
        email: email,
        password: password,
      );

      return const AuthActionResult.success();
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        return AuthActionResult.failure(
          errorCode: AuthErrorCode.loginFailed,
          fieldErrors: _readFieldErrors(error),
        );
      }

      if (error.response?.statusCode == 401) {
        final message = _readBackendMessage(error);

        return AuthActionResult.failure(
          errorCode: AuthErrorCode.loginFailed,
          fieldErrors: {
  'email': ?message,
  'password': ?message,
},
        );
      }

      return AuthActionResult.failure(
        errorCode: AuthErrorCode.loginFailed,
        backendMessage: _readBackendMessage(error),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Parent login failed: '
        '$error\n$stackTrace',
      );

      return const AuthActionResult.failure(
        errorCode: AuthErrorCode.unexpectedError,
      );
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  Future<AuthActionResult> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String guardianType,
  }) async {
    if (_isSubmitting) {
      return const AuthActionResult.failure(
        errorCode: AuthErrorCode.registerFailed,
      );
    }

    _isSubmitting = true;
    _notify();

    try {
      await _repository.register(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        password: password,
        guardianType: guardianType,
      );

      return const AuthActionResult.success();
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        return AuthActionResult.failure(
          errorCode: AuthErrorCode.registerFailed,
          fieldErrors: _readFieldErrors(error),
        );
      }

      if (error.response?.statusCode == 409) {
        return AuthActionResult.failure(
          errorCode: AuthErrorCode.registerFailed,
          backendMessage: _readBackendMessage(error),
        );
      }

      return AuthActionResult.failure(
        errorCode: AuthErrorCode.registerFailed,
        backendMessage: _readBackendMessage(error),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Parent registration failed: '
        '$error\n$stackTrace',
      );

      return const AuthActionResult.failure(
        errorCode: AuthErrorCode.unexpectedError,
      );
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  Map<String, String> _readFieldErrors(
    DioException error,
  ) {
    final data = error.response?.data;

    if (data is! Map) {
      return const {};
    }

    final errors = data['errors'];

    if (errors is! Map) {
      return const {};
    }

    final result = <String, String>{};

    for (final entry in errors.entries) {
      final value = entry.value;

      if (value is List && value.isNotEmpty) {
        result[entry.key.toString()] =
            value.map((item) => item.toString()).join('\n');
      } else if (value != null) {
        final message = value.toString().trim();

        if (message.isNotEmpty) {
          result[entry.key.toString()] = message;
        }
      }
    }

    return result;
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

    if (message == null || message.isEmpty) {
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