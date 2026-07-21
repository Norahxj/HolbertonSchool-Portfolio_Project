import 'package:dio/dio.dart';
import 'package:frontend/models/task_assignment_model.dart';
import 'package:frontend/models/task_model.dart';
import 'package:frontend/models/task_suggestions_response.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/child_model.dart';
part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST('/auth/login')
  Future<HttpResponse<dynamic>> login(@Body() Map<String, dynamic> body);

  @POST('/auth/register')
  Future<HttpResponse<dynamic>> register(@Body() Map<String, dynamic> body);

  @POST('/auth/refresh')
  Future<HttpResponse<dynamic>> refreshToken(@Body() Map<String, dynamic> body);

  @POST('/auth/logout')
  Future<HttpResponse<dynamic>> logout(@Body() Map<String, dynamic> body);

  @GET('/users/me')
  Future<HttpResponse<dynamic>> getCurrentUser();
 
 // child 
  @POST('/auth/child-login')
  Future<HttpResponse<dynamic>> childLogin(
  @Body() Map<String, dynamic> body,
);

  @GET('/children/')
  Future<HttpResponse<List<ChildModel>>> getChildren();

  @POST('/children/')
  Future<HttpResponse<ChildModel>> addChild(@Body() Map<String, dynamic> body);

  @GET('/children/{id}')
  Future<HttpResponse<ChildModel>> getChild(@Path('id') String childId);

  //task
  
  @POST('/tasks/')
  Future<HttpResponse<TaskModel>> createTask(@Body() Map<String, dynamic> body);

  @GET('/tasks/')
  Future<HttpResponse<List<TaskModel>>> getTasks();

  @GET('/tasks/{taskId}')
  Future<HttpResponse<TaskModel>> getTask(@Path('taskId') String taskId);

  @PUT('/tasks/{taskId}')
  Future<HttpResponse<TaskModel>> updateTask(
    @Path('taskId') String taskId,
    @Body() Map<String, dynamic> body,
  );

  @GET('/tasks/child/{childId}')
  Future<HttpResponse<List<TaskModel>>> getTasksByChild(
  @Path('childId') String childId,
  );
  @GET('/task-assignments/task/{taskId}')
  Future<HttpResponse<List<TaskAssignmentModel>>> getAssignmentsByTask(
  @Path('taskId') String taskId,
);

  @POST('/task-bank/suggestions')
  Future<HttpResponse<TaskSuggestionsResponse>> getTaskSuggestions(
  @Body() Map<String, dynamic> body,
);  
  @GET('/task-assignments/my')
  Future<HttpResponse<List<TaskAssignmentModel>>> getMyAssignments();
  

  @GET('/task-assignments/child/{child_id}')
  Future<HttpResponse<List<TaskAssignmentModel>>>
    getChildAssignments(
  @Path('child_id') String childId,
);

  @PUT('/task-assignments/{assignment_id}/complete')
  Future<HttpResponse<TaskAssignmentModel>>
    completeAssignment(
  @Path('assignment_id') String assignmentId,
);

  @PUT('/task-assignments/{assignment_id}/approve')
  Future<HttpResponse<TaskAssignmentModel>>
    approveAssignment(
  @Path('assignment_id') String assignmentId,
);

  @PUT('/task-assignments/{assignment_id}/reject')
  Future<HttpResponse<TaskAssignmentModel>>
    rejectAssignment(
  @Path('assignment_id') String assignmentId,
);
  
  
  /// whish

  @POST('/wishlists/')
  Future<HttpResponse<dynamic>> createWish(@Body() Map<String, dynamic> body);

  @GET('/wishlists/my')
  Future<HttpResponse<dynamic>> getMyWishes();

  @GET('/wishlists/child/{childId}')
  Future<HttpResponse<dynamic>> getChildWishes(@Path('childId') String childId);

  @PUT('/wishlists/{wishId}/approve')
  Future<HttpResponse<dynamic>> approveWish(
    @Path('wishId') String wishId,
    @Body() Map<String, dynamic> body,
  );
  @PUT('/wishlist/{wishId}/reject')
  Future<HttpResponse<dynamic>> rejectWish(
  @Path('wishId') String wishId,
);

@PUT('/wishlist/{wishId}/achieve')
Future<HttpResponse<dynamic>> achieveWish(
  @Path('wishId') String wishId,
);

@DELETE('/wishlist/{wishId}')
Future<HttpResponse<dynamic>> deleteWish(
  @Path('wishId') String wishId,
);
}