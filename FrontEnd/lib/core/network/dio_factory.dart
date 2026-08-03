import 'package:dio/dio.dart';

import 'package:frontend/core/network/api_constants.dart';
import 'package:frontend/core/storage/secure_storage.dart';
import 'package:frontend/features/auth/services/auth_api_service.dart';

class DioFactory {
  DioFactory._();

  static Dio? dio;

  /// One shared refresh operation for all failed requests.
  static Future<String>? _refreshingToken;

  /// One shared backend warm-up operation.
  static Future<void>? _warmUpFuture;

  /// Called when the refresh token is no longer valid.
  static Future<void> Function()? onSessionExpired;

  static const String _retriedAfterRefreshKey =
      'retried_after_token_refresh';

  static Dio getDio() {
    if (dio != null) {
      return dio!;
    }

    const timeout = Duration(seconds: 25);

    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: const {
          'Accept': 'application/json',
        },
      ),
    );

    _addDioInterceptors();

    return dio!;
  }

  /// Starts waking the hosted backend as soon as the app opens.
  ///
  /// The app does not wait for this request, so the interface can start
  /// immediately.
  static Future<void> warmUp() {
    return _warmUpFuture ??= _performWarmUp();
  }

  static Future<void> _performWarmUp() async {
    final warmUpDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        validateStatus: (_) => true,
      ),
    );

    try {
      await warmUpDio.get<dynamic>('');
    } catch (_) {
      // Warm-up is only an optimization. The app should continue normally
      // even when this request fails.
    }
  }

  static void _addDioInterceptors() {
    dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final isPublicRequest = _isPublicAuthRequest(options.path);

          final alreadyHasAuthorization =
              options.headers['Authorization'] != null;

          if (!isPublicRequest && !alreadyHasAuthorization) {
            final accessToken = SecureStorage.cachedAccessToken;

            if (accessToken != null && accessToken.isNotEmpty) {
              options.headers['Authorization'] = accessToken;
            }
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;

          final alreadyRetried =
              request.extra[_retriedAfterRefreshKey] == true;

          final isRefreshRequest =
              _normalizePath(request.path) == ApiConstants.refresh;

          if (!_isExpiredAccessTokenError(error) ||
              isRefreshRequest ||
              alreadyRetried) {
            handler.next(error);
            return;
          }

          try {
            final newAccessToken = await _refreshAccessTokenOnce();

            request.headers['Authorization'] = newAccessToken;
            request.extra[_retriedAfterRefreshKey] = true;

            final response = await dio!.fetch<dynamic>(request);

            handler.resolve(response);
          } on DioException catch (refreshError) {
            final statusCode = refreshError.response?.statusCode;

            final sessionIsInvalid =
                statusCode == 401 ||
                statusCode == 403 ||
                statusCode == 404;

            if (sessionIsInvalid) {
              await _expireSession();
            }

            handler.next(error);
          } catch (_) {
            final refreshToken =
                await SecureStorage.getRefreshToken();

            if (refreshToken == null || refreshToken.isEmpty) {
              await _expireSession();
            }

            handler.next(error);
          }
        },
      ),
    );

    // PrettyDioLogger was removed intentionally.
    // Logging every request and response makes debug builds slower and can
    // expose sensitive authentication information.
  }

  static bool _isPublicAuthRequest(String path) {
    final normalizedPath = _normalizePath(path);

    return normalizedPath == ApiConstants.login ||
        normalizedPath == ApiConstants.register ||
        normalizedPath == ApiConstants.childLogin ||
        normalizedPath == ApiConstants.refresh;
  }

  static String _normalizePath(String path) {
    if (path.startsWith('/')) {
      return path.substring(1);
    }

    return path;
  }

  static bool _isExpiredAccessTokenError(DioException error) {
    final responseData = error.response?.data;

    return error.response?.statusCode == 401 &&
        responseData is Map &&
        responseData['error'] == 'Token has expired';
  }

  static Future<String> _refreshAccessTokenOnce() {
    final activeRefresh = _refreshingToken;

    if (activeRefresh != null) {
      return activeRefresh;
    }

    late final Future<String> refreshFuture;

    refreshFuture = AuthApiService()
        .refreshAccessToken()
        .whenComplete(() {
          if (identical(_refreshingToken, refreshFuture)) {
            _refreshingToken = null;
          }
        });

    _refreshingToken = refreshFuture;

    return refreshFuture;
  }

  static Future<void> _expireSession() async {
    await SecureStorage.clear();

    final callback = onSessionExpired;

    if (callback != null) {
      await callback();
    }
  }
}
