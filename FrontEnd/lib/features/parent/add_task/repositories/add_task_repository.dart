import '../../../../models/child_model.dart';
import '../../../../models/task_suggestion_model.dart';
import '../../../../services/task_api_service.dart';
import '../../services/child_api_service.dart';
import '../models/task_draft.dart';

class AddTaskRepository {
  final TaskApiService _taskApiService;
  final ChildApiService _childApiService;

  AddTaskRepository({
    TaskApiService? taskApiService,
    ChildApiService? childApiService,
  }) : _taskApiService = taskApiService ?? TaskApiService(),
       _childApiService = childApiService ?? ChildApiService();

  Future<List<ChildModel>> getChildren() {
    return _childApiService.getChildren();
  }

  Future<List<TaskSuggestionModel>> getTaskSuggestions({
    required List<String> childIds,
    required String category,
    required String languageCode,
  }) {
    return _taskApiService.getTaskSuggestions({
      'child_ids': childIds,
      'category': category,
      'lang': languageCode,
    });
  }

  Future<void> createTask(TaskDraft draft) {
    return _taskApiService.createTask(draft.toRequestBody());
  }
}
