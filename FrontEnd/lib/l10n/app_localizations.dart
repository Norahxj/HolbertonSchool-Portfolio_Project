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
  /// **'Once a Week'**
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
