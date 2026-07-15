import 'package:frontend/models/task_suggestion_model.dart';

import 'task_model.dart';

class TaskSuggestionsResponse {
  final List<TaskSuggestionModel> suggestions;

  TaskSuggestionsResponse({
    required this.suggestions,
  });

  factory TaskSuggestionsResponse.fromJson(Map<String, dynamic> json) {
    return TaskSuggestionsResponse(
      suggestions: (json['suggestions'] as List)
          .map((e) => TaskSuggestionModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suggestions': suggestions.map((e) => e.toJson()).toList(),
    };
  }
}