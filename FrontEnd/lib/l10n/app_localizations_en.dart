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

  @override
  String get failedToLoadChildren => 'Failed to load children';

  @override
  String get failedToLoadChildRewards => 'Failed to load child rewards';

  @override
  String get failedToLoadRewardSuggestions =>
      'Failed to load suggested rewards';

  @override
  String get deleteRewardNotAllowed =>
      'You cannot delete this reward. Only the parent who added it can delete it.';

  @override
  String get deleteClaimedRewardNotAllowed =>
      'A claimed reward cannot be deleted.';

  @override
  String get failedToDeleteReward =>
      'Failed to delete the reward. Please try again.';

  @override
  String get rewardAddedSuccessfully => 'Reward added successfully 🎉';

  @override
  String get deleteRewardTitle => 'Delete Reward';

  @override
  String deleteRewardConfirmation(String rewardName) {
    return 'Do you want to delete the reward \"$rewardName\"?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get rewardDeleted => 'Reward deleted';

  @override
  String get rewardManagement => 'Reward Management';

  @override
  String get rewardManagementSubtitle =>
      'Weekly rewards based on the child’s performance';

  @override
  String get noChildrenAddFirst => 'No children yet. Add a child first.';

  @override
  String get currentChildRewards => 'Current Child Rewards';

  @override
  String get noRewardsForChild => 'This child has no rewards yet';

  @override
  String get selectChildForSuggestions =>
      'Select a child first to view suggested rewards';

  @override
  String get rewardStatusUnlocked => 'Unlocked';

  @override
  String get rewardStatusClaimed => 'Claimed';

  @override
  String get rewardStatusLocked => 'Locked';

  @override
  String rewardUnlockDay(String day) {
    return 'Reward unlock day';
  }

  @override
  String get noSuggestedRewards => 'No suggested rewards available';

  @override
  String get addReward => 'Add Reward';

  @override
  String get rewardNameRequired => 'Enter the reward name first';

  @override
  String get couldNotSaveReward => 'Could not save the reward';

  @override
  String get saveRewardGenericError =>
      'An error occurred while saving the reward';

  @override
  String get newReward => 'New Reward';

  @override
  String get rewardName => 'Reward name';

  @override
  String get rewardNameExample => 'Example: A trip to the park';

  @override
  String get rewardDescription => 'Reward description';

  @override
  String get rewardDescriptionExample =>
      'Example: A weekend visit to the park with the family';

  @override
  String rewardAvailableEveryWeek(String day) {
    return 'The reward will become available to the child every $day.';
  }

  @override
  String get saveReward => 'Save Reward';

  @override
  String get rewardUnlockDayLabel => 'Reward unlock day';

  @override
  String get failedToLoadFeedbackHistory => 'Unable to load feedback history';

  @override
  String get failedToSaveFeedback =>
      'Unable to save feedback. Please try again.';

  @override
  String get feedbackSavedSuccessfully => 'Feedback saved successfully ✓';

  @override
  String get dailyFeedback => 'Daily Feedback';

  @override
  String get feedbackHistory => 'Feedback History';

  @override
  String get todayFeedbackEditable => 'Today\'s Feedback (You Can Edit It)';

  @override
  String howWasChildDay(String childName) {
    return 'How was $childName\'s day?';
  }

  @override
  String get updateFeedback => 'Update Feedback';

  @override
  String get saveFeedback => 'Save Feedback';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodProud => 'Proud';

  @override
  String get moodGreat => 'Great';

  @override
  String get moodLoved => 'Loved';

  @override
  String get moodStrong => 'Strong';

  @override
  String get moodStar => 'Star';

  @override
  String childPointsHistory(String childName) {
    return '$childName\'s Points History';
  }

  @override
  String taskCompletedPointsHistory(String taskTitle) {
    return 'Task completed: $taskTitle';
  }

  @override
  String wishAchievedPointsHistory(String wishName) {
    return 'Wish achieved: $wishName';
  }

  @override
  String get pointsUpdate => 'Points update';

  @override
  String get noPointsHistoryYet => 'No points history yet';

  @override
  String get pointsHistoryDescription =>
      'Earned and deducted points will appear here.';

  @override
  String get failedToLoadPointsHistory => 'Could not load points history.';

  @override
  String get childrenWishes => 'Children’s Wishes';

  @override
  String get childrenWishesSubtitle =>
      'Review your child’s wish and set how many Noor points they need to collect to achieve it';

  @override
  String get failedToRefreshWishes => 'Unable to refresh wishes';

  @override
  String get failedToApproveWish => 'Unable to approve the wish';

  @override
  String get failedToRejectWish => 'Unable to reject the wish';

  @override
  String get wishApprovalExplanation =>
      'After the wish is approved, the child starts collecting Noor points until reaching the selected goal.';

  @override
  String get pendingApproval => 'Pending Approval';

  @override
  String get pendingWishSubtitle =>
      'Requested this wish and is waiting for you to set the points goal';

  @override
  String get pointsGoal => 'Points Goal';

  @override
  String get convertWishExplanation =>
      'After converting the wish into a goal, the child starts collecting these Noor points to achieve it.';

  @override
  String get pointsMustBePositive => 'Points must be greater than zero';

  @override
  String get convertToGoal => 'Convert to Goal';

  @override
  String get reject => 'Reject';

  @override
  String get goalCreated => 'Goal Created';

  @override
  String get wishApprovedSubtitle => 'This wish has been approved';

  @override
  String get selectedPointsGoal => 'Selected Points Goal';

  @override
  String get wishAchieved => 'Achieved';

  @override
  String get wishAchievedSuccessfully =>
      'This wish was achieved successfully 🎉';

  @override
  String get completedNoorPointsGoal =>
      'The child completed the Noor Points goal';

  @override
  String get failedToLoadWishes =>
      'An error occurred while loading wishes. Please try again.';

  @override
  String get noWishesYet => 'No wishes yet.';

  @override
  String get more => 'More';

  @override
  String get comingSoonMessage => 'This feature is coming soon.';

  @override
  String get personalProfile => 'Personal profile';

  @override
  String get familySettings => 'Family settings';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get helpAndSupport => 'Help and support';

  @override
  String get soon => 'Soon';

  @override
  String get logOut => 'Log out';

  @override
  String get logoutFailed => 'Unable to log out. Please try again.';
}
