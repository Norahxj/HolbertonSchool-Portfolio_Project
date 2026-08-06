import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Asalah'**
  String get appName;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @taskDetails.
  ///
  /// In en, this message translates to:
  /// **'Task Details'**
  String get taskDetails;

  /// No description provided for @saveTask.
  ///
  /// In en, this message translates to:
  /// **'Save Task'**
  String get saveTask;

  /// No description provided for @taskName.
  ///
  /// In en, this message translates to:
  /// **'Task Name'**
  String get taskName;

  /// No description provided for @taskDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskDescription;

  /// No description provided for @taskFrequency.
  ///
  /// In en, this message translates to:
  /// **'Task Frequency'**
  String get taskFrequency;

  /// No description provided for @taskType.
  ///
  /// In en, this message translates to:
  /// **'Task Type'**
  String get taskType;

  /// No description provided for @noorPoints.
  ///
  /// In en, this message translates to:
  /// **'Noor Points'**
  String get noorPoints;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @chooseChildSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Who is this task for? (You can select more than one child)'**
  String get chooseChildSubtitle;

  /// No description provided for @taskDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add the task details and choose how often it repeats'**
  String get taskDetailsSubtitle;

  /// No description provided for @selectChildFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a child first to enable task types'**
  String get selectChildFirst;

  /// No description provided for @chooseTaskType.
  ///
  /// In en, this message translates to:
  /// **'Choose a task type'**
  String get chooseTaskType;

  /// No description provided for @noChildrenYet.
  ///
  /// In en, this message translates to:
  /// **'No children yet. Please add a child first.'**
  String get noChildrenYet;

  /// No description provided for @culturalTasks.
  ///
  /// In en, this message translates to:
  /// **'Cultural Tasks'**
  String get culturalTasks;

  /// No description provided for @dailyTasks.
  ///
  /// In en, this message translates to:
  /// **'Daily Tasks'**
  String get dailyTasks;

  /// No description provided for @religiousTasks.
  ///
  /// In en, this message translates to:
  /// **'Religious Tasks'**
  String get religiousTasks;

  /// No description provided for @financialTasks.
  ///
  /// In en, this message translates to:
  /// **'Financial Tasks'**
  String get financialTasks;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAdd;

  /// No description provided for @unableToLoadSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Unable to load suggested tasks'**
  String get unableToLoadSuggestions;

  /// No description provided for @noSuggestions.
  ///
  /// In en, this message translates to:
  /// **'No suggested tasks available right now'**
  String get noSuggestions;

  /// No description provided for @taskNameExample.
  ///
  /// In en, this message translates to:
  /// **'Example: Make your bed'**
  String get taskNameExample;

  /// No description provided for @taskDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe the task...'**
  String get taskDescriptionHint;

  /// No description provided for @chooseWeekDay.
  ///
  /// In en, this message translates to:
  /// **'Choose a day of the week'**
  String get chooseWeekDay;

  /// No description provided for @chooseMonthDay.
  ///
  /// In en, this message translates to:
  /// **'Choose a day of the month'**
  String get chooseMonthDay;

  /// No description provided for @chooseRepeatDate.
  ///
  /// In en, this message translates to:
  /// **'Choose the repeat date'**
  String get chooseRepeatDate;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @pointsValue.
  ///
  /// In en, this message translates to:
  /// **'{points} points'**
  String pointsValue(int points);

  /// No description provided for @taskNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Task name is required'**
  String get taskNameRequired;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// No description provided for @selectAtLeastOneChild.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one child'**
  String get selectAtLeastOneChild;

  /// No description provided for @selectTaskTypeError.
  ///
  /// In en, this message translates to:
  /// **'Please select a task type'**
  String get selectTaskTypeError;

  /// No description provided for @pointsRangeError.
  ///
  /// In en, this message translates to:
  /// **'Points must be between 1 and 100'**
  String get pointsRangeError;

  /// No description provided for @taskNameLengthError.
  ///
  /// In en, this message translates to:
  /// **'Task name must be between 2 and 100 characters'**
  String get taskNameLengthError;

  /// No description provided for @descriptionLengthError.
  ///
  /// In en, this message translates to:
  /// **'Description must be between 2 and 500 characters'**
  String get descriptionLengthError;

  /// No description provided for @saveTaskGenericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving the task'**
  String get saveTaskGenericError;

  /// No description provided for @tasksInformation.
  ///
  /// In en, this message translates to:
  /// **'Tasks help children build habits and values while earning Noor points.'**
  String get tasksInformation;

  /// No description provided for @pointsInformation.
  ///
  /// In en, this message translates to:
  /// **'Noor points motivate children and encourage them to keep going.'**
  String get pointsInformation;

  /// No description provided for @trustChildQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you trust your child to complete this task seriously?'**
  String get trustChildQuestion;

  /// No description provided for @trustChildDescription.
  ///
  /// In en, this message translates to:
  /// **'If you do, the task will be approved automatically without your review.'**
  String get trustChildDescription;

  /// No description provided for @dailyFrequencyDescription.
  ///
  /// In en, this message translates to:
  /// **'The task is completed every day'**
  String get dailyFrequencyDescription;

  /// No description provided for @weeklyFrequencyDescription.
  ///
  /// In en, this message translates to:
  /// **'The task is completed once a week'**
  String get weeklyFrequencyDescription;

  /// No description provided for @monthlyFrequencyDescription.
  ///
  /// In en, this message translates to:
  /// **'The task is completed once a month'**
  String get monthlyFrequencyDescription;

  /// No description provided for @failedToLoadChildren.
  ///
  /// In en, this message translates to:
  /// **'Failed to load children'**
  String get failedToLoadChildren;

  /// No description provided for @failedToLoadChildRewards.
  ///
  /// In en, this message translates to:
  /// **'Failed to load child rewards'**
  String get failedToLoadChildRewards;

  /// No description provided for @failedToLoadRewardSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load suggested rewards'**
  String get failedToLoadRewardSuggestions;

  /// No description provided for @deleteRewardNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'You cannot delete this reward. Only the parent who added it can delete it.'**
  String get deleteRewardNotAllowed;

  /// No description provided for @deleteClaimedRewardNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'A claimed reward cannot be deleted.'**
  String get deleteClaimedRewardNotAllowed;

  /// No description provided for @failedToDeleteReward.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete the reward. Please try again.'**
  String get failedToDeleteReward;

  /// No description provided for @rewardAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Reward added successfully 🎉'**
  String get rewardAddedSuccessfully;

  /// No description provided for @deleteRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Reward'**
  String get deleteRewardTitle;

  /// No description provided for @deleteRewardConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the reward \"{rewardName}\"?'**
  String deleteRewardConfirmation(String rewardName);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @rewardDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reward deleted'**
  String get rewardDeleted;

  /// No description provided for @rewardManagement.
  ///
  /// In en, this message translates to:
  /// **'Reward Management'**
  String get rewardManagement;

  /// No description provided for @rewardManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly rewards based on the child’s performance'**
  String get rewardManagementSubtitle;

  /// No description provided for @noChildrenAddFirst.
  ///
  /// In en, this message translates to:
  /// **'No children yet. Add a child first.'**
  String get noChildrenAddFirst;

  /// No description provided for @currentChildRewards.
  ///
  /// In en, this message translates to:
  /// **'Current Child Rewards'**
  String get currentChildRewards;

  /// No description provided for @noRewardsForChild.
  ///
  /// In en, this message translates to:
  /// **'This child has no rewards yet'**
  String get noRewardsForChild;

  /// No description provided for @selectChildForSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Select a child first to view suggested rewards'**
  String get selectChildForSuggestions;

  /// No description provided for @rewardStatusUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get rewardStatusUnlocked;

  /// No description provided for @rewardStatusClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get rewardStatusClaimed;

  /// No description provided for @rewardStatusLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get rewardStatusLocked;

  /// No description provided for @rewardUnlockDay.
  ///
  /// In en, this message translates to:
  /// **'Reward unlock day'**
  String rewardUnlockDay(String day);

  /// No description provided for @noSuggestedRewards.
  ///
  /// In en, this message translates to:
  /// **'No suggested rewards available'**
  String get noSuggestedRewards;

  /// No description provided for @addReward.
  ///
  /// In en, this message translates to:
  /// **'Add Reward'**
  String get addReward;

  /// No description provided for @rewardNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the reward name first'**
  String get rewardNameRequired;

  /// No description provided for @couldNotSaveReward.
  ///
  /// In en, this message translates to:
  /// **'Could not save the reward'**
  String get couldNotSaveReward;

  /// No description provided for @saveRewardGenericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving the reward'**
  String get saveRewardGenericError;

  /// No description provided for @newReward.
  ///
  /// In en, this message translates to:
  /// **'New Reward'**
  String get newReward;

  /// No description provided for @rewardName.
  ///
  /// In en, this message translates to:
  /// **'Reward name'**
  String get rewardName;

  /// No description provided for @rewardNameExample.
  ///
  /// In en, this message translates to:
  /// **'Example: A trip to the park'**
  String get rewardNameExample;

  /// No description provided for @rewardDescription.
  ///
  /// In en, this message translates to:
  /// **'Reward description'**
  String get rewardDescription;

  /// No description provided for @rewardDescriptionExample.
  ///
  /// In en, this message translates to:
  /// **'Example: A weekend visit to the park with the family'**
  String get rewardDescriptionExample;

  /// No description provided for @rewardAvailableEveryWeek.
  ///
  /// In en, this message translates to:
  /// **'The reward will become available to the child every {day}.'**
  String rewardAvailableEveryWeek(String day);

  /// No description provided for @saveReward.
  ///
  /// In en, this message translates to:
  /// **'Save Reward'**
  String get saveReward;

  /// No description provided for @rewardUnlockDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Reward unlock day'**
  String get rewardUnlockDayLabel;

  /// No description provided for @failedToLoadFeedbackHistory.
  ///
  /// In en, this message translates to:
  /// **'Unable to load feedback history'**
  String get failedToLoadFeedbackHistory;

  /// No description provided for @failedToSaveFeedback.
  ///
  /// In en, this message translates to:
  /// **'Unable to save feedback. Please try again.'**
  String get failedToSaveFeedback;

  /// No description provided for @feedbackSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Feedback saved successfully ✓'**
  String get feedbackSavedSuccessfully;

  /// No description provided for @dailyFeedback.
  ///
  /// In en, this message translates to:
  /// **'Daily Feedback'**
  String get dailyFeedback;

  /// No description provided for @feedbackHistory.
  ///
  /// In en, this message translates to:
  /// **'Feedback History'**
  String get feedbackHistory;

  /// No description provided for @todayFeedbackEditable.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Feedback (You Can Edit It)'**
  String get todayFeedbackEditable;

  /// No description provided for @howWasChildDay.
  ///
  /// In en, this message translates to:
  /// **'How was {childName}\'s day?'**
  String howWasChildDay(String childName);

  /// No description provided for @updateFeedback.
  ///
  /// In en, this message translates to:
  /// **'Update Feedback'**
  String get updateFeedback;

  /// No description provided for @saveFeedback.
  ///
  /// In en, this message translates to:
  /// **'Save Feedback'**
  String get saveFeedback;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodProud.
  ///
  /// In en, this message translates to:
  /// **'Proud'**
  String get moodProud;

  /// No description provided for @moodGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get moodGreat;

  /// No description provided for @moodLoved.
  ///
  /// In en, this message translates to:
  /// **'Loved'**
  String get moodLoved;

  /// No description provided for @moodStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get moodStrong;

  /// No description provided for @moodStar.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get moodStar;

  /// No description provided for @childPointsHistory.
  ///
  /// In en, this message translates to:
  /// **'{childName}\'s Points History'**
  String childPointsHistory(String childName);

  /// No description provided for @taskCompletedPointsHistory.
  ///
  /// In en, this message translates to:
  /// **'Task completed: {taskTitle}'**
  String taskCompletedPointsHistory(String taskTitle);

  /// No description provided for @wishAchievedPointsHistory.
  ///
  /// In en, this message translates to:
  /// **'Wish achieved: {wishName}'**
  String wishAchievedPointsHistory(String wishName);

  /// No description provided for @pointsUpdate.
  ///
  /// In en, this message translates to:
  /// **'Points update'**
  String get pointsUpdate;

  /// No description provided for @noPointsHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No points history yet'**
  String get noPointsHistoryYet;

  /// No description provided for @pointsHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Earned and deducted points will appear here.'**
  String get pointsHistoryDescription;

  /// No description provided for @failedToLoadPointsHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load points history.'**
  String get failedToLoadPointsHistory;

  /// No description provided for @childrenWishes.
  ///
  /// In en, this message translates to:
  /// **'Children’s Wishes'**
  String get childrenWishes;

  /// No description provided for @childrenWishesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your child’s wish and set how many Noor points they need to collect to achieve it'**
  String get childrenWishesSubtitle;

  /// No description provided for @failedToRefreshWishes.
  ///
  /// In en, this message translates to:
  /// **'Unable to refresh wishes'**
  String get failedToRefreshWishes;

  /// No description provided for @failedToApproveWish.
  ///
  /// In en, this message translates to:
  /// **'Unable to approve the wish'**
  String get failedToApproveWish;

  /// No description provided for @failedToRejectWish.
  ///
  /// In en, this message translates to:
  /// **'Unable to reject the wish'**
  String get failedToRejectWish;

  /// No description provided for @wishApprovalExplanation.
  ///
  /// In en, this message translates to:
  /// **'After the wish is approved, the child starts collecting Noor points until reaching the selected goal.'**
  String get wishApprovalExplanation;

  /// No description provided for @pendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get pendingApproval;

  /// No description provided for @pendingWishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Requested this wish and is waiting for you to set the points goal'**
  String get pendingWishSubtitle;

  /// No description provided for @pointsGoal.
  ///
  /// In en, this message translates to:
  /// **'Points Goal'**
  String get pointsGoal;

  /// No description provided for @convertWishExplanation.
  ///
  /// In en, this message translates to:
  /// **'After converting the wish into a goal, the child starts collecting these Noor points to achieve it.'**
  String get convertWishExplanation;

  /// No description provided for @pointsMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Points must be greater than zero'**
  String get pointsMustBePositive;

  /// No description provided for @convertToGoal.
  ///
  /// In en, this message translates to:
  /// **'Convert to Goal'**
  String get convertToGoal;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @goalCreated.
  ///
  /// In en, this message translates to:
  /// **'Goal Created'**
  String get goalCreated;

  /// No description provided for @wishApprovedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This wish has been approved'**
  String get wishApprovedSubtitle;

  /// No description provided for @selectedPointsGoal.
  ///
  /// In en, this message translates to:
  /// **'Selected Points Goal'**
  String get selectedPointsGoal;

  /// No description provided for @wishAchieved.
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get wishAchieved;

  /// No description provided for @wishAchievedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'This wish was achieved successfully 🎉'**
  String get wishAchievedSuccessfully;

  /// No description provided for @completedNoorPointsGoal.
  ///
  /// In en, this message translates to:
  /// **'The child completed the Noor Points goal'**
  String get completedNoorPointsGoal;

  /// No description provided for @failedToLoadWishes.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading wishes. Please try again.'**
  String get failedToLoadWishes;

  /// No description provided for @noWishesYet.
  ///
  /// In en, this message translates to:
  /// **'No wishes yet.'**
  String get noWishesYet;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @comingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon.'**
  String get comingSoonMessage;

  /// No description provided for @personalProfile.
  ///
  /// In en, this message translates to:
  /// **'Personal profile'**
  String get personalProfile;

  /// No description provided for @familySettings.
  ///
  /// In en, this message translates to:
  /// **'Family settings'**
  String get familySettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help and support'**
  String get helpAndSupport;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to log out. Please try again.'**
  String get logoutFailed;

  /// No description provided for @failedToLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to load the dashboard.'**
  String get failedToLoadDashboard;

  /// No description provided for @failedToRefreshDashboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh the dashboard.'**
  String get failedToRefreshDashboard;

  /// No description provided for @failedToDeleteChild.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete the child. Please try again.'**
  String get failedToDeleteChild;

  /// No description provided for @childNotFoundForFamily.
  ///
  /// In en, this message translates to:
  /// **'The child was not found or is no longer linked to this family.'**
  String get childNotFoundForFamily;

  /// No description provided for @parentAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'The parent account could not be found.'**
  String get parentAccountNotFound;

  /// No description provided for @parentAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'This action is available to parent accounts only.'**
  String get parentAccessRequired;

  /// No description provided for @failedToDeleteChildRelatedData.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete the child and the related data.'**
  String get failedToDeleteChildRelatedData;

  /// No description provided for @yourChildren.
  ///
  /// In en, this message translates to:
  /// **'Your children'**
  String get yourChildren;

  /// No description provided for @addChild.
  ///
  /// In en, this message translates to:
  /// **'Add child'**
  String get addChild;

  /// No description provided for @reviewTasks.
  ///
  /// In en, this message translates to:
  /// **'Review tasks'**
  String get reviewTasks;

  /// No description provided for @childAgeYears.
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String childAgeYears(int age);

  /// No description provided for @pointsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} points'**
  String pointsCount(int count);

  /// No description provided for @noChildrenAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No children added yet'**
  String get noChildrenAddedYet;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @buildingWonderfulGeneration.
  ///
  /// In en, this message translates to:
  /// **'You are building a wonderful generation'**
  String get buildingWonderfulGeneration;

  /// No description provided for @failedToLoadChildTasks.
  ///
  /// In en, this message translates to:
  /// **'Could not load the child tasks.'**
  String get failedToLoadChildTasks;

  /// No description provided for @failedToRefreshChildTasks.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh the child tasks.'**
  String get failedToRefreshChildTasks;

  /// No description provided for @couldNotIdentifyChild.
  ///
  /// In en, this message translates to:
  /// **'Could not identify the child.'**
  String get couldNotIdentifyChild;

  /// No description provided for @onlyCreatorCanDeleteTask.
  ///
  /// In en, this message translates to:
  /// **'You can only delete tasks you created.'**
  String get onlyCreatorCanDeleteTask;

  /// No description provided for @failedToDeleteTask.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the task.'**
  String get failedToDeleteTask;

  /// No description provided for @deleteChildConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {childName}?'**
  String deleteChildConfirmationTitle(String childName);

  /// No description provided for @deleteChildConfirmationDescription.
  ///
  /// In en, this message translates to:
  /// **'The child account and all related data will be permanently deleted. This action cannot be undone.'**
  String get deleteChildConfirmationDescription;

  /// No description provided for @childDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Child deleted successfully'**
  String get childDeletedSuccessfully;

  /// No description provided for @childDetails.
  ///
  /// In en, this message translates to:
  /// **'Child details'**
  String get childDetails;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly progress'**
  String get weeklyProgress;

  /// No description provided for @noorPointsHistory.
  ///
  /// In en, this message translates to:
  /// **'Noor Points History'**
  String get noorPointsHistory;

  /// No description provided for @viewPointsHistory.
  ///
  /// In en, this message translates to:
  /// **'View points history'**
  String get viewPointsHistory;

  /// No description provided for @rateChildDayAndViewHistory.
  ///
  /// In en, this message translates to:
  /// **'Rate {childName}\'s day and view history'**
  String rateChildDayAndViewHistory(String childName);

  /// No description provided for @viewChildTasks.
  ///
  /// In en, this message translates to:
  /// **'View {childName}\'s tasks'**
  String viewChildTasks(String childName);

  /// No description provided for @editChildInformation.
  ///
  /// In en, this message translates to:
  /// **'Edit child information'**
  String get editChildInformation;

  /// No description provided for @deleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get deleting;

  /// No description provided for @deleteChild.
  ///
  /// In en, this message translates to:
  /// **'Delete child'**
  String get deleteChild;

  /// No description provided for @childAccessCode.
  ///
  /// In en, this message translates to:
  /// **'Child access code'**
  String get childAccessCode;

  /// No description provided for @childAccessCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Child access code copied'**
  String get childAccessCodeCopied;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @deleteTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete task?'**
  String get deleteTaskTitle;

  /// No description provided for @deleteTaskConfirmation.
  ///
  /// In en, this message translates to:
  /// **'The task \"{taskTitle}\" will be permanently deleted. This action cannot be undone.'**
  String deleteTaskConfirmation(String taskTitle);

  /// No description provided for @taskDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Task deleted successfully'**
  String get taskDeletedSuccessfully;

  /// No description provided for @childTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'{childName}\'s Tasks'**
  String childTasksTitle(String childName);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @awaitingReview.
  ///
  /// In en, this message translates to:
  /// **'Awaiting review'**
  String get awaitingReview;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get noTasks;

  /// No description provided for @noUpcomingTasks.
  ///
  /// In en, this message translates to:
  /// **'No upcoming tasks'**
  String get noUpcomingTasks;

  /// No description provided for @noActiveTasks.
  ///
  /// In en, this message translates to:
  /// **'No active tasks'**
  String get noActiveTasks;

  /// No description provided for @noTasksAwaitingReview.
  ///
  /// In en, this message translates to:
  /// **'No tasks awaiting review'**
  String get noTasksAwaitingReview;

  /// No description provided for @noCompletedTasks.
  ///
  /// In en, this message translates to:
  /// **'No completed tasks'**
  String get noCompletedTasks;

  /// No description provided for @noRejectedTasks.
  ///
  /// In en, this message translates to:
  /// **'No rejected tasks'**
  String get noRejectedTasks;

  /// No description provided for @childHasNoTasks.
  ///
  /// In en, this message translates to:
  /// **'This child has no tasks yet'**
  String get childHasNoTasks;

  /// No description provided for @failedToLoadTasks.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tasks'**
  String get failedToLoadTasks;

  /// No description provided for @nextTaskDate.
  ///
  /// In en, this message translates to:
  /// **'Next date: {date}'**
  String nextTaskDate(String date);

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTask;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
