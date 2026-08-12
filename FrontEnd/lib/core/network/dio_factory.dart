import 'package:dio/dio.dart';

import 'package:frontend/core/network/api_constants.dart';
import 'package:frontend/core/storage/secure_storage.dart';
import 'package:frontend/features/auth/services/auth_api_service.dart';

class DioFactory {
  DioFactory._();

  static Dio? dio;
  static Dio? _longRunningDio;

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

    dio = _createDio(
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
    );

    return dio!;
  }

  /// Used only for requests that are expected to take longer,
  /// such as the AI weekly-plan workflow.
  static Dio getLongRunningDio() {
    if (_longRunningDio != null) {
      return _longRunningDio!;
    }

    const timeout = Duration(minutes: 10);

    _longRunningDio = _createDio(
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
    );

    return _longRunningDio!;
  }

  static Dio _createDio({
    required Duration connectTimeout,
    required Duration receiveTimeout,
    required Duration sendTimeout,
  }) {
    final client = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: const {
          'Accept': 'application/json',
        },
      ),
    );

    _addDioInterceptors(client);

    return client;
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
      await warmUpDio.get<dynamic>(
        'cron/health',
      );
    } catch (_) {
      // Warm-up is only an optimization.
      // The app should continue normally even if it fails.
    }
  }

  static void _addDioInterceptors(
    Dio client,
  ) {
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final isPublicRequest =
              _isPublicAuthRequest(options.path);

          final alreadyHasAuthorization =
              options.headers['Authorization'] != null;

          if (!isPublicRequest &&
              !alreadyHasAuthorization) {
            final accessToken =
                SecureStorage.cachedAccessToken;

            if (accessToken != null &&
                accessToken.isNotEmpty) {
              options.headers['Authorization'] =
                  accessToken;
            }
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;

          final alreadyRetried =
              request.extra[_retriedAfterRefreshKey] ==
                  true;

          final isRefreshRequest =
              _normalizePath(request.path) ==
                  ApiConstants.refresh;

          if (!_isExpiredAccessTokenError(error) ||
              isRefreshRequest ||
              alreadyRetried) {
            handler.next(error);
            return;
          }

          try {
            final newAccessToken =
                await _refreshAccessTokenOnce();

            request.headers['Authorization'] =
                newAccessToken;

            request.extra[_retriedAfterRefreshKey] =
                true;

            final response =
                await client.fetch<dynamic>(
              request,
            );

            handler.resolve(response);
          } on DioException catch (refreshError) {
            final statusCode =
                refreshError.response?.statusCode;

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
                await SecureStorage
                    .getRefreshToken();

            if (refreshToken == null ||
                refreshToken.isEmpty) {
              await _expireSession();
            }

            handler.next(error);
          }
        },
      ),
    );
  }

  static bool _isPublicAuthRequest(
    String path,
  ) {
    final normalizedPath =
        _normalizePath(path);

    return normalizedPath ==
            ApiConstants.login ||
        normalizedPath ==
            ApiConstants.register ||
        normalizedPath ==
            ApiConstants.childLogin ||
        normalizedPath ==
            ApiConstants.refresh;
  }

  static String _normalizePath(
    String path,
  ) {
    if (path.startsWith('/')) {
      return path.substring(1);
    }

    return path;
  }

  static bool _isExpiredAccessTokenError(
    DioException error,
  ) {
    final responseData =
        error.response?.data;

    return error.response?.statusCode == 401 &&
        responseData is Map &&
        responseData['error'] ==
            'Token has expired';
  }

  static Future<String>
      _refreshAccessTokenOnce() {
    final activeRefresh = _refreshingToken;

    if (activeRefresh != null) {
      return activeRefresh;
    }

    late final Future<String> refreshFuture;

    refreshFuture = AuthApiService()
        .refreshAccessToken()
        .whenComplete(() {
      if (identical(
        _refreshingToken,
        refreshFuture,
      )) {
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