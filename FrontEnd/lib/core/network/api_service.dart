import 'package:dio/dio.dart';
import 'package:frontend/models/task_model.dart';
import 'package:frontend/models/task_suggestions_response.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/child_model.dart';
import '../../models/child_dashboard_model.dart';
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

  @POST('/task-bank/suggestions')
  Future<HttpResponse<TaskSuggestionsResponse>> getTaskSuggestions(
  @Body() Map<String, dynamic> body,
);  

// Task Assignments

@GET('/task-assignments/my')
Future<HttpResponse<dynamic>> getMyAssignments();

@PUT('/task-assignments/{assignmentId}/complete')
Future<HttpResponse<dynamic>> completeAssignment(
  @Path('assignmentId') String assignmentId,
);

@PUT('/task-assignments/{assignmentId}/approve')
Future<HttpResponse<dynamic>> approveAssignment(
  @Path('assignmentId') String assignmentId,
);

@PUT('/task-assignments/{assignmentId}/reject')
Future<HttpResponse<dynamic>> rejectAssignment(
  @Path('assignmentId') String assignmentId,
);

@GET('/task-assignments/task/{taskId}')
Future<HttpResponse<dynamic>> getAssignmentsForTask(
  @Path('taskId') String taskId,
);
@GET('/task-assignments/child/{childId}')
Future<HttpResponse<dynamic>> getAssignmentsForChild(
  @Path('childId') String childId,
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
  @PUT('/wishlists/{wishId}/reject')
Future<HttpResponse<dynamic>> rejectWish(
  @Path('wishId') String wishId,
);

@PUT('/wishlists/{wishId}/achieve')
Future<HttpResponse<dynamic>> achieveWish(
  @Path('wishId') String wishId,
);

@DELETE('/wishlists/{wishId}')
Future<HttpResponse<dynamic>> deleteWish(
  @Path('wishId') String wishId,
);
// Points

@GET('/points/my')
Future<HttpResponse<dynamic>> getMyPoints();

@GET('/points/child/{childId}')
Future<HttpResponse<dynamic>> getChildPoints(
  @Path('childId') String childId,
);
// Daily Feedback

@POST('/daily-feedback/')
Future<HttpResponse<dynamic>> createDailyFeedback(
  @Body() Map<String, dynamic> body,
);

@GET('/daily-feedback/child/{childId}')
Future<HttpResponse<dynamic>> getDailyFeedbackForChild(
  @Path('childId') String childId,
);

@GET('/daily-feedback/today/{childId}')
Future<HttpResponse<dynamic>> getTodayFeedback(
  @Path('childId') String childId,
);

@GET('/daily-feedback/my')
Future<HttpResponse<dynamic>> getMyDailyFeedback();

@PUT('/daily-feedback/{feedbackId}')
Future<HttpResponse<dynamic>> updateDailyFeedback(
  @Path('feedbackId') String feedbackId,
  @Body() Map<String, dynamic> body,
);
// Rewards

@POST('/rewards/')
Future<HttpResponse<dynamic>> createReward(
  @Body() Map<String, dynamic> body,
);

@GET('/rewards/child/{childId}')
Future<HttpResponse<dynamic>> getRewardsForChild(
  @Path('childId') String childId,
);

@GET('/rewards/my')
Future<HttpResponse<dynamic>> getMyRewards();

@PUT('/rewards/{rewardId}/claim')
Future<HttpResponse<dynamic>> claimReward(
  @Path('rewardId') String rewardId,
);

@DELETE('/rewards/{rewardId}')
Future<HttpResponse<dynamic>> deleteReward(
  @Path('rewardId') String rewardId,
);
// Reward Bank

// Reward Bank

@POST('/reward-bank/suggestions')
Future<HttpResponse<dynamic>> getRewardBankSuggestions(
  @Body() Map<String, dynamic> body,
);
@GET('/dashboard/')
Future<HttpResponse<List<ChildDashboardModel>>> getDashboard();
}