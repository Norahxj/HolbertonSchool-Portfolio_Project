import 'package:dio/dio.dart';
import 'package:frontend/models/task_model.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/child_model.dart';

part 'api_service.g.dart';

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

  @GET('/children/{id}')
  Future<HttpResponse<ChildModel>> getChild(
    @Path('id') String childId,
  );
  
  @POST('/tasks/')
Future<HttpResponse<TaskModel>> createTask(
  @Body() Map<String, dynamic> body,
  );

@GET('/tasks/')
Future<HttpResponse<List<TaskModel>>> getTasks();

@GET('/tasks/{taskId}')
Future<HttpResponse<TaskModel>> getTask(
  @Path('taskId') String taskId,
);

@PUT('/tasks/{taskId}')
Future<HttpResponse<TaskModel>> updateTask(
  @Path('taskId') String taskId,
  @Body() Map<String, dynamic> body,
);

@GET('/tasks/child/{childId}')
Future<HttpResponse<List<TaskModel>>> getTasksByChild(
  @Path('childId') String childId,
);
}