import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/child_model.dart';

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


  @POST('/auth/refresh')
  Future<HttpResponse<dynamic>> refreshToken(
    @Body() Map<String, dynamic> body,
  );


  @POST('/auth/logout')
  Future<HttpResponse<dynamic>> logout(
    @Body() Map<String, dynamic> body,
  );
  
  @GET('/users/me')
  Future<HttpResponse<dynamic>> getCurrentUser();

  @GET('/children/')
  Future<HttpResponse<List<ChildModel>>> getChildren();

  @POST('/children/')
  Future<HttpResponse<ChildModel>> addChild(
  @Body() Map<String, dynamic> body,
);
}
