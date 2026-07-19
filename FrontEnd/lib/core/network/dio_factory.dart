import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_constants.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:frontend/core/storage/secure_storage.dart';
import '../../features/auth/services/auth_api_service.dart';
class DioFactory {
  DioFactory._();

  static Dio? dio;

  static Dio getDio() {
    Duration timeout = const Duration(minutes: 1);

    if (dio == null) {
      dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );

      addDioInterceptor();
    }

    return dio!;
  }

  static void addDioInterceptor() {
  dio?.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getAccessToken();

        if (token != null && 
            token.isNotEmpty &&
          !options.path.startsWith('auth/login') && 
          !options.path.startsWith('auth/register')) {
          options.headers["Authorization"] = token;
        }

        handler.next(options);
      },
    onError: (error, handler) async {
  print("Status Code: ${error.response?.statusCode}");
  print("Response: ${error.response?.data}");

  if (error.response?.statusCode == 401 &&
      error.response?.data["error"] == "Token has expired") {
    try {
      final newToken =
          await AuthApiService().refreshAccessToken();

      final request = error.requestOptions;

      request.headers["Authorization"] = newToken;

      final response = await dio!.fetch(request);

      return handler.resolve(response);
    } catch (e) {
      await SecureStorage.clear();
    }
  }

  handler.next(error);
},
    ),
  );


  dio?.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
    ),
  );
}
}