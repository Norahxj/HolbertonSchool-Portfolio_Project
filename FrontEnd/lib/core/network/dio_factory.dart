import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_constants.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

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


      addDioHeaders();
      addDioInterceptor();
    }

    return dio!;
  }

  static void addDioHeaders() async {
    dio?.options.headers = {};
  }

  static void addDioInterceptor() {
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