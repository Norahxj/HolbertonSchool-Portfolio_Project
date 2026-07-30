import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_constants.dart';
import 'package:frontend/core/storage/secure_storage.dart';
import 'package:frontend/features/auth/services/auth_api_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioFactory {
  DioFactory._();

  static Dio? dio;

  /// Stores the refresh operation that is currently running.
  ///
  /// When several API requests fail at the same time, they will all wait for
  /// this one refresh request instead of sending several refresh requests.
  static Future<String>? _refreshingToken;

  /// Called when the refresh token itself is no longer valid.
  static Future<void> Function()? onSessionExpired;

  static const String _retriedAfterRefreshKey =
      'retried_after_token_refresh';

  static Dio getDio() {
    const timeout = Duration(minutes: 1);

    if (dio == null) {
      dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );

      _addDioInterceptors();
    }

    return dio!;
  }

  static void _addDioInterceptors() {
    dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isPublicRequest = _isPublicAuthRequest(options.path);

          final alreadyHasAuthorization =
              options.headers['Authorization'] != null;

          if (!isPublicRequest && !alreadyHasAuthorization) {
            final accessToken = await SecureStorage.getAccessToken();

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

          /*
           * Refresh only when:
           *
           * 1. The backend returned "Token has expired".
           * 2. This is not the refresh request itself.
           * 3. The original request has not already been retried.
           */
          if (!_isExpiredAccessTokenError(error) ||
              isRefreshRequest ||
              alreadyRetried) {
            handler.next(error);
            return;
          }

          try {
            final newAccessToken = await _refreshAccessTokenOnce();

            // Attach the new access token to the failed request.
            request.headers['Authorization'] = newAccessToken;

            // Prevent this same request from refreshing forever.
            request.extra[_retriedAfterRefreshKey] = true;

            // Retry the original request with the new token.
            final response = await dio!.fetch<dynamic>(request);

            handler.resolve(response);
            return;
          } on DioException catch (refreshError) {
            final refreshStatusCode =
                refreshError.response?.statusCode;

            /*
             * These responses mean the refresh token is invalid,
             * expired, revoked, or no longer belongs to an account.
             */
            final sessionIsInvalid =
                refreshStatusCode == 401 ||
                refreshStatusCode == 403 ||
                refreshStatusCode == 404;

            if (sessionIsInvalid) {
              await _expireSession();
            }

            /*
             * For connection errors or server errors, do not delete the
             * tokens. The problem may only be temporary.
             */
            handler.next(error);
            return;
          } catch (_) {
            final refreshToken =
                await SecureStorage.getRefreshToken();

            /*
             * A missing refresh token means that this session cannot
             * be renewed.
             */
            if (refreshToken == null || refreshToken.isEmpty) {
              await _expireSession();
            }

            handler.next(error);
            return;
          }
        },
      ),
    );

    /*
     * Do not print headers, bodies, tokens, passwords, or login responses.
     */
    dio?.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: false,
        responseBody: false,
        responseHeader: false,
      ),
    );
  }

  /// Returns true for endpoints that should not receive an access token.
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

  /// Checks whether the 401 response was caused specifically by expiry.
  ///
  /// We should not refresh for:
  /// - Invalid login credentials
  /// - A revoked access token
  /// - An invalid access token
  static bool _isExpiredAccessTokenError(DioException error) {
    final responseData = error.response?.data;

    return error.response?.statusCode == 401 &&
        responseData is Map &&
        responseData['error'] == 'Token has expired';
  }

  /// Ensures that only one refresh request runs at a time.
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

  /// Clears the invalid session and informs the application.
  static Future<void> _expireSession() async {
    await SecureStorage.clear();

    final sessionExpiredCallback = onSessionExpired;

    if (sessionExpiredCallback != null) {
      await sessionExpiredCallback();
    }
  }
}