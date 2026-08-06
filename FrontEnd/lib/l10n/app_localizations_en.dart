// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Asalah';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get retry => 'Try Again';

  @override
  String get loading => 'Loading...';

  @override
  String get saving => 'Saving...';

  @override
  String get addTask => 'Add Task';

  @override
  String get taskDetails => 'Task Details';

  @override
  String get saveTask => 'Save Task';

  @override
  String get taskName => 'Task Name';

  @override
  String get taskDescription => 'Description';

  @override
  String get taskFrequency => 'Task Frequency';

  @override
  String get taskType => 'Task Type';

  @override
  String get noorPoints => 'Noor Points';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Once a Week';

  @override
  String get monthly => 'Monthly';

  @override
  String get chooseChildSubtitle =>
      'Who is this task for? (You can select more than one child)';

  @override
  String get taskDetailsSubtitle =>
      'Add the task details and choose how often it repeats';

  @override
  String get selectChildFirst => 'Select a child first to enable task types';

  @override
  String get chooseTaskType => 'Choose a task type';

  @override
  String get noChildrenYet => 'No children yet. Please add a child first.';

  @override
  String get culturalTasks => 'Cultural Tasks';

  @override
  String get dailyTasks => 'Daily Tasks';

  @override
  String get religiousTasks => 'Religious Tasks';

  @override
  String get financialTasks => 'Financial Tasks';

  @override
  String get quickAdd => 'Quick Add';

  @override
  String get unableToLoadSuggestions => 'Unable to load suggested tasks';

  @override
  String get noSuggestions => 'No suggested tasks available right now';

  @override
  String get taskNameExample => 'Example: Make your bed';

  @override
  String get taskDescriptionHint => 'Briefly describe the task...';

  @override
  String get chooseWeekDay => 'Choose a day of the week';

  @override
  String get chooseMonthDay => 'Choose a day of the month';

  @override
  String get chooseRepeatDate => 'Choose the repeat date';

  @override
  String get sunday => 'Sunday';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String pointsValue(int points) {
    return '$points points';
  }

  @override
  String get taskNameRequired => 'Task name is required';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get selectAtLeastOneChild => 'Please select at least one child';

  @override
  String get selectTaskTypeError => 'Please select a task type';

  @override
  String get pointsRangeError => 'Points must be between 1 and 100';

  @override
  String get taskNameLengthError =>
      'Task name must be between 2 and 100 characters';

  @override
  String get descriptionLengthError =>
      'Description must be between 2 and 500 characters';

  @override
  String get saveTaskGenericError => 'An error occurred while saving the task';

  @override
  String get tasksInformation =>
      'Tasks help children build habits and values while earning Noor points.';

  @override
  String get pointsInformation =>
      'Noor points motivate children and encourage them to keep going.';

  @override
  String get trustChildQuestion =>
      'Do you trust your child to complete this task seriously?';

  @override
  String get trustChildDescription =>
      'If you do, the task will be approved automatically without your review.';

  @override
  String get dailyFrequencyDescription => 'The task is completed every day';

  @override
  String get weeklyFrequencyDescription => 'The task is completed once a week';

  @override
  String get monthlyFrequencyDescription =>
      'The task is completed once a month';
}
