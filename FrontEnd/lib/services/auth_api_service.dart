import 'package:dio/dio.dart';

// TODO(backend): This is a temporary stub so the app can compile and run
// while the real backend endpoints are not ready yet.
// Replace the fake Response objects below with real Dio calls once the
// login/register API is available (see lib/core/network/ for the Dio
// setup your teammate already added).
class AuthApiService {
  Future<Response> login({
    required String email,
    required String password,
  }) async {
    // TODO(backend): Replace with a real request, e.g.
    // return dio.post('/auth/login', data: {'email': email, 'password': password});
    return Response(
      requestOptions: RequestOptions(path: '/auth/login'),
      statusCode: 200,
      data: {'message': 'Stub login response - no backend connected yet'},
    );
  }

  Future<Response> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String guardianType,
  }) async {
    // TODO(backend): Replace with a real request, e.g.
    // return dio.post('/auth/register', data: {...});
    return Response(
      requestOptions: RequestOptions(path: '/auth/register'),
      statusCode: 201,
      data: {'message': 'Stub register response - no backend connected yet'},
    );
  }
}
