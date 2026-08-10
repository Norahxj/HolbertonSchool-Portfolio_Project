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
  String get weekly => 'Weekly';

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

  @override
  String get failedToLoadDashboard => 'Failed to load the dashboard.';

  @override
  String get failedToRefreshDashboard => 'Failed to refresh the dashboard.';

  @override
  String get failedToDeleteChild =>
      'Failed to delete the child. Please try again.';

  @override
  String get childNotFoundForFamily =>
      'The child was not found or is no longer linked to this family.';

  @override
  String get parentAccountNotFound => 'The parent account could not be found.';

  @override
  String get parentAccessRequired =>
      'This action is available to parent accounts only.';

  @override
  String get failedToDeleteChildRelatedData =>
      'Failed to delete the child and the related data.';

  @override
  String get yourChildren => 'Your children';

  @override
  String get addChild => 'Add child';

  @override
  String get reviewTasks => 'Review tasks';

  @override
  String childAgeYears(int age) {
    return '$age years old';
  }

  @override
  String pointsCount(int count) {
    return '$count points';
  }

  @override
  String get noChildrenAddedYet => 'No children added yet';

  @override
  String get welcome => 'Welcome';

  @override
  String get buildingWonderfulGeneration =>
      'You are building a wonderful generation';

  @override
  String get failedToLoadChildTasks => 'Could not load the child tasks.';

  @override
  String get failedToRefreshChildTasks => 'Could not refresh the child tasks.';

  @override
  String get couldNotIdentifyChild => 'Could not identify the child.';

  @override
  String get onlyCreatorCanDeleteTask =>
      'You can only delete tasks you created.';

  @override
  String get failedToDeleteTask => 'Could not delete the task.';

  @override
  String deleteChildConfirmationTitle(String childName) {
    return 'Delete $childName?';
  }

  @override
  String get deleteChildConfirmationDescription =>
      'The child account and all related data will be permanently deleted. This action cannot be undone.';

  @override
  String get childDeletedSuccessfully => 'Child deleted successfully';

  @override
  String get childDetails => 'Child details';

  @override
  String get weeklyProgress => 'Weekly progress';

  @override
  String get noorPointsHistory => 'Noor Points History';

  @override
  String get viewPointsHistory => 'View points history';

  @override
  String rateChildDayAndViewHistory(String childName) {
    return 'Rate $childName\'s day and view history';
  }

  @override
  String viewChildTasks(String childName) {
    return 'View $childName\'s tasks';
  }

  @override
  String get editChildInformation => 'Edit child information';

  @override
  String get deleting => 'Deleting...';

  @override
  String get deleteChild => 'Delete child';

  @override
  String get childAccessCode => 'Child access code';

  @override
  String get childAccessCodeCopied => 'Child access code copied';

  @override
  String get copyCode => 'Copy code';

  @override
  String get tasks => 'Tasks';

  @override
  String get deleteTaskTitle => 'Delete task?';

  @override
  String deleteTaskConfirmation(String taskTitle) {
    return 'The task \"$taskTitle\" will be permanently deleted. This action cannot be undone.';
  }

  @override
  String get taskDeletedSuccessfully => 'Task deleted successfully';

  @override
  String childTasksTitle(String childName) {
    return '$childName\'s Tasks';
  }

  @override
  String get all => 'All';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get active => 'Active';

  @override
  String get awaitingReview => 'Awaiting review';

  @override
  String get completed => 'Completed';

  @override
  String get rejected => 'Rejected';

  @override
  String get noTasks => 'No tasks';

  @override
  String get noUpcomingTasks => 'No upcoming tasks';

  @override
  String get noActiveTasks => 'No active tasks';

  @override
  String get noTasksAwaitingReview => 'No tasks awaiting review';

  @override
  String get noCompletedTasks => 'No completed tasks';

  @override
  String get noRejectedTasks => 'No rejected tasks';

  @override
  String get childHasNoTasks => 'This child has no tasks yet';

  @override
  String get failedToLoadTasks => 'Failed to load tasks';

  @override
  String nextTaskDate(String date) {
    return 'Next date: $date';
  }

  @override
  String get deleteTask => 'Delete task';

  @override
  String get failedToLoadFamilySettings => 'Failed to load family settings.';

  @override
  String get familyNameTooShort =>
      'Family name must be at least two characters.';

  @override
  String get invalidGuardianEmail => 'Enter a valid email address.';

  @override
  String get failedToUpdateFamilyName => 'Failed to update the family name.';

  @override
  String get failedToSendInvitation => 'Failed to send the invitation.';

  @override
  String get failedToAcceptInvitation => 'Failed to accept the invitation.';

  @override
  String get failedToRejectInvitation => 'Failed to reject the invitation.';

  @override
  String get familySettingsGenericError => 'An unexpected error occurred.';

  @override
  String get familyName => 'Family name';

  @override
  String get saveFamilyName => 'Save name';

  @override
  String get guardians => 'Guardians';

  @override
  String get noGuardians => 'No guardians';

  @override
  String get father => 'Father';

  @override
  String get mother => 'Mother';

  @override
  String get guardian => 'Guardian';

  @override
  String get you => 'You';

  @override
  String get incomingInvitations => 'Incoming invitations';

  @override
  String get noIncomingInvitations => 'There are no incoming invitations';

  @override
  String get incomingInvitationsDescription =>
      'Family invitations will appear here';

  @override
  String get family => 'the family';

  @override
  String invitationToJoinFamily(String familyName) {
    return 'Invitation to join $familyName';
  }

  @override
  String invitationSentBy(String name) {
    return 'Sent by $name';
  }

  @override
  String get accept => 'Accept';

  @override
  String get inviteAnotherGuardian => 'Invite another guardian';

  @override
  String get guardianEmailAddress => 'Guardian email address';

  @override
  String get sending => 'Sending...';

  @override
  String get sendInvitation => 'Send invitation';

  @override
  String get guardianInvitationExplanation =>
      'The guardian must already have a registered account, and the invitation will appear in their account.';

  @override
  String get pendingSentInvitations => 'Pending sent invitations';

  @override
  String get noPendingSentInvitations =>
      'There are no pending sent invitations';

  @override
  String get pendingInvitationsDescription =>
      'Invitations you sent that have not yet been accepted will appear here';

  @override
  String get waitingForInvitationAcceptance =>
      'Waiting for invitation acceptance';

  @override
  String get invitationAcceptedSuccessfully =>
      'Invitation accepted and joined the family';

  @override
  String get invitationRejectedSuccessfully => 'Invitation rejected';

  @override
  String get familyNameUpdatedSuccessfully => 'Family name updated';

  @override
  String get invitationSentSuccessfully => 'Invitation sent successfully';

  @override
  String familyNameDisplay(String name) {
    return '$name Family';
  }

  @override
  String get unableToLoadReviewTasks => 'Unable to load tasks for review.';

  @override
  String get unableToApproveTask => 'Unable to accept the task.';

  @override
  String get onlyTaskCreatorCanApprove =>
      'Only the guardian who created this task can accept it.';

  @override
  String get unableToSendTaskForRetry =>
      'Unable to send the task back for another try.';

  @override
  String get onlyTaskCreatorCanRequestRetry =>
      'Only the guardian who created this task can send it back for another try.';

  @override
  String get completedRecently => 'Completed recently';

  @override
  String completedAt(String time) {
    return 'Completed at $time';
  }

  @override
  String get taskReview => 'Task review';

  @override
  String get reviewCompletedTasks => 'Review your children’s completed tasks';

  @override
  String get pendingReview => 'Pending review';

  @override
  String tasksCount(int count) {
    return '$count tasks';
  }

  @override
  String get acceptTask => 'Accept';

  @override
  String get tryAgain => 'Try again';

  @override
  String get noTasksPendingReview => 'No tasks are pending review';

  @override
  String taskAcceptedSuccessfully(String taskTitle) {
    return 'Task accepted: \"$taskTitle\"';
  }

  @override
  String taskSentForRetrySuccessfully(String taskTitle) {
    return 'Task sent back for another try: \"$taskTitle\"';
  }

  @override
  String get taskReviewGenericError =>
      'An unexpected error occurred while reviewing the task.';

  @override
  String get addChildSubtitle =>
      'Add your child\'s information to begin their journey';

  @override
  String get editChildSubtitle => 'Update the child information, then save';

  @override
  String get chooseAvatar => 'Choose an avatar';

  @override
  String get childName => 'Child name';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get selectDateOfBirth => 'Select date of birth';

  @override
  String get select => 'Select';

  @override
  String get openCalendarToSelectDate => 'Open the calendar to select a date';

  @override
  String get phoneNumberOptional => 'Phone number (optional)';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get childAddedSuccessfully => 'Child added successfully';

  @override
  String get childUpdatedSuccessfully =>
      'Child information updated successfully';

  @override
  String get childNameRequired => 'Child name is required';

  @override
  String get childNameTooShort =>
      'Child name must contain at least 2 characters';

  @override
  String get childNameTooLong => 'Child name must not exceed 100 characters';

  @override
  String get childNameLettersOnly => 'The name must contain letters only';

  @override
  String get birthDateRequired => 'Date of birth is required';

  @override
  String get invalidChildAge => 'Child age must be between 6 and 18 years';

  @override
  String get invalidSaudiPhone =>
      'Enter a valid Saudi phone number starting with 05';

  @override
  String get failedToAddChild => 'Could not add the child. Please try again.';

  @override
  String get failedToUpdateChild =>
      'Could not update the child. Please try again.';

  @override
  String get phoneAlreadyUsed => 'This phone number is already in use.';

  @override
  String get parentNotLinkedToFamily =>
      'The parent account is not linked to a family.';

  @override
  String get onlyParentsCanAddChildren => 'Only parents can add children.';

  @override
  String get onlyParentsCanUpdateChildren =>
      'Only parents can update child information.';

  @override
  String get childNotFound => 'The child was not found.';

  @override
  String get couldNotCreateChild => 'Could not create the child account.';

  @override
  String get couldNotSaveChildChanges => 'Could not save the changes.';

  @override
  String get couldNotIdentifyChildToUpdate =>
      'Could not identify the child to update.';

  @override
  String get unexpectedAddChildError =>
      'An unexpected error occurred while adding the child.';

  @override
  String get unexpectedUpdateChildError =>
      'An unexpected error occurred while updating the child.';

  @override
  String get profile => 'Profile';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get email => 'Email';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get familyRelationship => 'Family Relationship';

  @override
  String get profileUpdatedSuccessfully => 'Changes saved successfully ✓';

  @override
  String get failedToLoadProfile => 'Unable to load profile data.';

  @override
  String get failedToSaveProfile => 'Unable to save changes.';

  @override
  String get unexpectedProfileSaveError =>
      'An error occurred while saving changes.';

  @override
  String get firstNameTooShort => 'First name must be at least two characters.';

  @override
  String get lastNameTooShort => 'Last name must be at least two characters.';

  @override
  String get invalidEmailAddress => 'Please enter a valid email address.';

  @override
  String get phoneNumberRequired => 'Please enter a phone number.';

  @override
  String get emailAlreadyUsed => 'Email is already in use.';

  @override
  String get failedToLoadUserInformation => 'Could not load user information.';

  @override
  String get invitedUserNotFound =>
      'No parent account exists with this email address.';

  @override
  String get cannotInviteYourself => 'You cannot invite your own account.';

  @override
  String get userAlreadyInFamily => 'This parent is already in the family.';

  @override
  String get guardianTypeAlreadyExists =>
      'A parent with the same guardian type already exists in the family.';

  @override
  String get invitationAlreadyPending =>
      'An invitation is already pending for this email.';

  @override
  String get familyInformationNotFound =>
      'Unable to find the family information.';

  @override
  String get invalidEnteredData => 'Please check the entered information.';

  @override
  String get parentNavigationTasks => 'Tasks';

  @override
  String get parentNavigationWishes => 'Wishes';

  @override
  String get parentNavigationHome => 'Home';

  @override
  String get parentNavigationRewards => 'Rewards';

  @override
  String get parentNavigationMore => 'More';

  @override
  String get childNavigationHome => 'Home';

  @override
  String get childNavigationWishes => 'Wishes';

  @override
  String get childNavigationRewards => 'Rewards';

  @override
  String get childNavigationProgress => 'Progress';

  @override
  String get switchLanguage => 'English';

  @override
  String get childTaskAutoApprovedSuccess =>
      'Well done! The task is complete and your points were added.';

  @override
  String get childTaskSentForReviewSuccess =>
      'Well done! The task was sent to your guardian for review.';

  @override
  String get childTaskCompleteFailed =>
      'Could not complete the task. Please try again.';

  @override
  String get childTaskUnexpectedError =>
      'An error occurred while completing the task.';

  @override
  String get childTaskCompletedApproved => 'Completed and approved';

  @override
  String get childTaskWaitingGuardianReview => 'Waiting for guardian review';

  @override
  String get childTaskReadyToComplete => 'Ready to complete';

  @override
  String get childTaskApproved => 'Task approved';

  @override
  String get childTaskCompleteButton => 'I completed the task';

  @override
  String get childTaskAutoVerificationMessage =>
      'This task will be approved automatically when completed, and the points will be added directly to your balance.';

  @override
  String get childTaskGuardianVerificationMessage =>
      'After you complete the task, your guardian will review it. Once approved, the points will be added to your balance.';

  @override
  String get childTaskNoDescription => 'There is no description for this task.';

  @override
  String noorPointsCount(int points) {
    return '$points Noor Points';
  }

  @override
  String get notSpecified => 'Not specified';

  @override
  String get once => 'One time';
}
