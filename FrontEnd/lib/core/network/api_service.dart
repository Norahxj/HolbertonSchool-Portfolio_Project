import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
part 'api_service.g.dart';

// Remove passing a non-constant value to the annotation. The baseUrl can
// be supplied at runtime via th
//e generated client or left empty here.
@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST('/auth/login')
  Future<HttpResponse<dynamic>> login(
    @Body() Map<String, dynamic> body,
  );

  @POST('/auth/register')
  Future<HttpResponse<dynamic>> register(
    @Body() Map<String, dynamic> body,
  );
}