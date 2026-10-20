import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @customize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

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

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @choosePlant.
  ///
  /// In en, this message translates to:
  /// **'Choose Plant'**
  String get choosePlant;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @lowWaterAlert.
  ///
  /// In en, this message translates to:
  /// **'Low water alert'**
  String get lowWaterAlert;

  /// No description provided for @lowNutrientAlert.
  ///
  /// In en, this message translates to:
  /// **'Low nutrient alert'**
  String get lowNutrientAlert;

  /// No description provided for @temperatureAlert.
  ///
  /// In en, this message translates to:
  /// **'Temperature alert'**
  String get temperatureAlert;

  /// No description provided for @harvestReminder.
  ///
  /// In en, this message translates to:
  /// **'Harvest reminder'**
  String get harvestReminder;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get goodNight;

  /// No description provided for @gardenOf.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Garden'**
  String gardenOf(String name);

  /// No description provided for @gardenOfEndingWithS.
  ///
  /// In en, this message translates to:
  /// **'{name}\' Garden'**
  String gardenOfEndingWithS(String name);

  /// No description provided for @gardenTitle.
  ///
  /// In en, this message translates to:
  /// **'Your garden'**
  String get gardenTitle;

  /// No description provided for @gardenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your green space'**
  String get gardenSubtitle;

  /// No description provided for @sensorLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load sensor data'**
  String get sensorLoadError;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'HEALTHY'**
  String get healthy;

  /// No description provided for @growing.
  ///
  /// In en, this message translates to:
  /// **'GROWING'**
  String get growing;

  /// No description provided for @dayProgress.
  ///
  /// In en, this message translates to:
  /// **'{variety} · Day {day} / {totalDays}'**
  String dayProgress(String variety, int day, int totalDays);

  /// No description provided for @germination.
  ///
  /// In en, this message translates to:
  /// **'Germination'**
  String get germination;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @harvest.
  ///
  /// In en, this message translates to:
  /// **'Harvest'**
  String get harvest;

  /// No description provided for @liveSensors.
  ///
  /// In en, this message translates to:
  /// **'Live sensors'**
  String get liveSensors;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'● Synced'**
  String get synced;

  /// No description provided for @waterLevel.
  ///
  /// In en, this message translates to:
  /// **'Water level'**
  String get waterLevel;

  /// No description provided for @airTemperature.
  ///
  /// In en, this message translates to:
  /// **'Air temperature'**
  String get airTemperature;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'LIGHT'**
  String get light;

  /// No description provided for @waterTemperature.
  ///
  /// In en, this message translates to:
  /// **'WATER TEMPERATURE'**
  String get waterTemperature;

  /// No description provided for @airHumidity.
  ///
  /// In en, this message translates to:
  /// **'AIR HUMIDITY'**
  String get airHumidity;

  /// No description provided for @careScheduleFor.
  ///
  /// In en, this message translates to:
  /// **'Care schedule for {plantName}'**
  String careScheduleFor(String plantName);

  /// No description provided for @automaticOptimized.
  ///
  /// In en, this message translates to:
  /// **'Optimized automatically'**
  String get automaticOptimized;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @wateringCycle.
  ///
  /// In en, this message translates to:
  /// **'WATERING CYCLE'**
  String get wateringCycle;

  /// No description provided for @wateringCycleValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min every {interval} min'**
  String wateringCycleValue(int minutes, int interval);

  /// No description provided for @nutrientCycle.
  ///
  /// In en, this message translates to:
  /// **'NUTRIENT CYCLE'**
  String get nutrientCycle;

  /// No description provided for @nutrientCycleValue.
  ///
  /// In en, this message translates to:
  /// **'{amount} ml every {days} days'**
  String nutrientCycleValue(int amount, int days);

  /// No description provided for @idealTemperature.
  ///
  /// In en, this message translates to:
  /// **'IDEAL TEMPERATURE'**
  String get idealTemperature;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @alertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track issues in your garden.'**
  String get alertsSubtitle;

  /// No description provided for @unresolved.
  ///
  /// In en, this message translates to:
  /// **'Unresolved'**
  String get unresolved;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @noAlerts.
  ///
  /// In en, this message translates to:
  /// **'There are no alerts yet.'**
  String get noAlerts;

  /// No description provided for @noUnresolvedAlerts.
  ///
  /// In en, this message translates to:
  /// **'There are no unresolved alerts.'**
  String get noUnresolvedAlerts;

  /// No description provided for @noResolvedAlerts.
  ///
  /// In en, this message translates to:
  /// **'There are no resolved alerts yet.'**
  String get noResolvedAlerts;

  /// No description provided for @markResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark as resolved'**
  String get markResolved;

  /// No description provided for @choosePlantTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a plant'**
  String get choosePlantTitle;

  /// No description provided for @choosePlantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a plant — the system will automatically adjust light, water, and nutrients.'**
  String get choosePlantSubtitle;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @replacePlantConfirmation.
  ///
  /// In en, this message translates to:
  /// **'You will replace \"{currentPlant}\" with \"{newPlant}\". Continue?'**
  String replacePlantConfirmation(String currentPlant, String newPlant);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @agree.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get agree;

  /// No description provided for @startedPlanting.
  ///
  /// In en, this message translates to:
  /// **'Started growing {plantName}'**
  String startedPlanting(String plantName);

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks'**
  String weeks(int count);

  /// No description provided for @pumpCycle.
  ///
  /// In en, this message translates to:
  /// **'Pump {minutes} min every {interval} min'**
  String pumpCycle(int minutes, int interval);

  /// No description provided for @nutrientCycleShort.
  ///
  /// In en, this message translates to:
  /// **'Add {amount} ml every {days} days'**
  String nutrientCycleShort(int amount, int days);

  /// No description provided for @currentlyGrowing.
  ///
  /// In en, this message translates to:
  /// **'Currently growing'**
  String get currentlyGrowing;

  /// No description provided for @startGrowing.
  ///
  /// In en, this message translates to:
  /// **'Start growing'**
  String get startGrowing;

  /// No description provided for @devicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devicesTitle;

  /// No description provided for @devicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage and connect Aerogreen devices.'**
  String get devicesSubtitle;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @moreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account and application options.'**
  String get moreSubtitle;

  /// No description provided for @customization.
  ///
  /// In en, this message translates to:
  /// **'Customization'**
  String get customization;

  /// No description provided for @languageAndNotifications.
  ///
  /// In en, this message translates to:
  /// **'Language and notifications'**
  String get languageAndNotifications;

  /// No description provided for @harvestHistory.
  ///
  /// In en, this message translates to:
  /// **'Harvest history'**
  String get harvestHistory;

  /// No description provided for @plantsGrown.
  ///
  /// In en, this message translates to:
  /// **'32 plants grown'**
  String get plantsGrown;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpAndSupport;

  /// No description provided for @faqAndChat.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions and chat'**
  String get faqAndChat;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @authHeadline.
  ///
  /// In en, this message translates to:
  /// **'Effortless urban gardening'**
  String get authHeadline;

  /// No description provided for @authTagline.
  ///
  /// In en, this message translates to:
  /// **'Grow fresh vegetables on your countertop — Aerogreen handles the rest.'**
  String get authTagline;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @emailExample.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailExample;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordRequired;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Your password must include:\n• At least 8 characters\n• A lowercase letter\n• An uppercase letter\n• A number\n• A special character'**
  String get passwordRequirements;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @checkSignUpDetails.
  ///
  /// In en, this message translates to:
  /// **'Check your email, password (at least 8 characters), and password confirmation.'**
  String get checkSignUpDetails;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @termsNotice.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to the Terms and Privacy Policy.'**
  String get termsNotice;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get authInvalidCredentials;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Connection problem. Please try again.'**
  String get authNetworkError;

  /// No description provided for @authGenericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get authGenericError;

  /// No description provided for @socialSignInNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Social sign-in is not available yet.'**
  String get socialSignInNotAvailable;

  /// No description provided for @harvestLog.
  ///
  /// In en, this message translates to:
  /// **'Harvest log'**
  String get harvestLog;

  /// No description provided for @startedOn.
  ///
  /// In en, this message translates to:
  /// **'Started: {date}'**
  String startedOn(String date);

  /// No description provided for @harvestedOn.
  ///
  /// In en, this message translates to:
  /// **'Harvested: {date}'**
  String harvestedOn(String date);

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @chatNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Chat is not integrated yet'**
  String get chatNotAvailable;

  /// No description provided for @chatWithUs.
  ///
  /// In en, this message translates to:
  /// **'Chat with us'**
  String get chatWithUs;

  /// No description provided for @faqAddPlantQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I add a new plant?'**
  String get faqAddPlantQuestion;

  /// No description provided for @faqAddPlantAnswer.
  ///
  /// In en, this message translates to:
  /// **'Open the Plants tab, tap the + button, and enter the plant details.'**
  String get faqAddPlantAnswer;

  /// No description provided for @faqAlertsQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I configure alerts?'**
  String get faqAlertsQuestion;

  /// No description provided for @faqAlertsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Open More, then Customization, and enable the alert switches.'**
  String get faqAlertsAnswer;

  /// No description provided for @faqUnitsQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I change units?'**
  String get faqUnitsQuestion;

  /// No description provided for @faqUnitsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Open More, then Customization, to select units and language.'**
  String get faqUnitsAnswer;

  /// No description provided for @faqHarvestQuestion.
  ///
  /// In en, this message translates to:
  /// **'Where are past harvests?'**
  String get faqHarvestQuestion;

  /// No description provided for @faqHarvestAnswer.
  ///
  /// In en, this message translates to:
  /// **'View past harvests in Harvest history.'**
  String get faqHarvestAnswer;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Showing the most recent data.'**
  String get offlineBanner;

  /// No description provided for @offlineBannerSemantics.
  ///
  /// In en, this message translates to:
  /// **'Network connection warning. You are offline. Showing the most recent data.'**
  String get offlineBannerSemantics;

  /// No description provided for @idealRange.
  ///
  /// In en, this message translates to:
  /// **'Ideal range'**
  String get idealRange;

  /// No description provided for @selectTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Select time range'**
  String get selectTimeRange;

  /// No description provided for @trendDescription.
  ///
  /// In en, this message translates to:
  /// **'Track changes over time'**
  String get trendDescription;

  /// No description provided for @sensorHistoryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load sensor history.'**
  String get sensorHistoryLoadError;

  /// No description provided for @noSensorHistory.
  ///
  /// In en, this message translates to:
  /// **'No data is available for this time range.'**
  String get noSensorHistory;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cannotStartPumpLowWater.
  ///
  /// In en, this message translates to:
  /// **'The pump cannot start while the water level is low.'**
  String get cannotStartPumpLowWater;

  /// No description provided for @frontendSimulationOnly.
  ///
  /// In en, this message translates to:
  /// **'Frontend simulation only'**
  String get frontendSimulationOnly;

  /// No description provided for @automaticScheduleSimulation.
  ///
  /// In en, this message translates to:
  /// **'Automatic schedule (simulation)'**
  String get automaticScheduleSimulation;

  /// No description provided for @addSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add schedule'**
  String get addSchedule;

  /// No description provided for @noSchedules.
  ///
  /// In en, this message translates to:
  /// **'There are no schedules. Select Add schedule to preview one in the interface.'**
  String get noSchedules;

  /// No description provided for @invalidSchedule.
  ///
  /// In en, this message translates to:
  /// **'Enter valid times and select at least one day.'**
  String get invalidSchedule;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @manualControl.
  ///
  /// In en, this message translates to:
  /// **'Manual {device} control'**
  String manualControl(String device);

  /// No description provided for @deviceOn.
  ///
  /// In en, this message translates to:
  /// **'{device} is on'**
  String deviceOn(String device);

  /// No description provided for @deviceOff.
  ///
  /// In en, this message translates to:
  /// **'{device} is off'**
  String deviceOff(String device);

  /// No description provided for @lowWaterPumpOnlyOff.
  ///
  /// In en, this message translates to:
  /// **'Water level is below 30%: the pump can only be turned off.'**
  String get lowWaterPumpOnlyOff;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeletion;

  /// No description provided for @deleteScheduleConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this schedule?'**
  String get deleteScheduleConfirmation;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dismiss;

  /// No description provided for @deleteScheduleFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete: {error}'**
  String deleteScheduleFailed(String error);

  /// No description provided for @wateringScheduleFor.
  ///
  /// In en, this message translates to:
  /// **'Watering schedule - {deviceName}'**
  String wateringScheduleFor(String deviceName);

  /// No description provided for @scheduleLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load schedules'**
  String get scheduleLoadError;

  /// No description provided for @noSchedulesYet.
  ///
  /// In en, this message translates to:
  /// **'No schedules yet'**
  String get noSchedulesYet;

  /// No description provided for @addAutomaticWateringSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add an automatic watering schedule'**
  String get addAutomaticWateringSchedule;

  /// No description provided for @addScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Add schedule'**
  String get addScheduleTitle;

  /// No description provided for @deviceSetup.
  ///
  /// In en, this message translates to:
  /// **'Device setup'**
  String get deviceSetup;

  /// No description provided for @copiedLabel.
  ///
  /// In en, this message translates to:
  /// **'{label} copied.'**
  String copiedLabel(String label);

  /// No description provided for @manualMode.
  ///
  /// In en, this message translates to:
  /// **'Manual mode'**
  String get manualMode;

  /// No description provided for @autoMode.
  ///
  /// In en, this message translates to:
  /// **'Automatic mode'**
  String get autoMode;

  /// No description provided for @keepManual.
  ///
  /// In en, this message translates to:
  /// **'Keep manual'**
  String get keepManual;

  /// No description provided for @switchToAuto.
  ///
  /// In en, this message translates to:
  /// **'Switch to automatic'**
  String get switchToAuto;

  /// No description provided for @switchToManual.
  ///
  /// In en, this message translates to:
  /// **'Switch to manual'**
  String get switchToManual;

  /// No description provided for @autoScheduleWillPause.
  ///
  /// In en, this message translates to:
  /// **'Automatic schedules will pause. Are you sure?'**
  String get autoScheduleWillPause;

  /// No description provided for @cannotStartPumpLowWaterDetail.
  ///
  /// In en, this message translates to:
  /// **'The pump cannot start while the water level is low.'**
  String get cannotStartPumpLowWaterDetail;

  /// No description provided for @cannotSendCommand.
  ///
  /// In en, this message translates to:
  /// **'Unable to send command: {error}'**
  String cannotSendCommand(String error);

  /// No description provided for @selectRunDuration.
  ///
  /// In en, this message translates to:
  /// **'Choose run duration'**
  String get selectRunDuration;

  /// No description provided for @pumpAutoStop.
  ///
  /// In en, this message translates to:
  /// **'The pump will turn off automatically after the selected duration.'**
  String get pumpAutoStop;

  /// No description provided for @seconds30.
  ///
  /// In en, this message translates to:
  /// **'30 seconds'**
  String get seconds30;

  /// No description provided for @minute1.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get minute1;

  /// No description provided for @minutes5.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get minutes5;

  /// No description provided for @minutes10.
  ///
  /// In en, this message translates to:
  /// **'10 minutes'**
  String get minutes10;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @sensors.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get sensors;

  /// No description provided for @noRecentData.
  ///
  /// In en, this message translates to:
  /// **'No recent data'**
  String get noRecentData;

  /// No description provided for @stableConnection.
  ///
  /// In en, this message translates to:
  /// **'Stable connection'**
  String get stableConnection;

  /// No description provided for @deviceOffline.
  ///
  /// In en, this message translates to:
  /// **'Device is offline'**
  String get deviceOffline;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @cannotPauseAutoSchedule.
  ///
  /// In en, this message translates to:
  /// **'Unable to pause automatic schedules: {error}'**
  String cannotPauseAutoSchedule(String error);

  /// No description provided for @cannotRestoreAutoSchedule.
  ///
  /// In en, this message translates to:
  /// **'Unable to restore automatic schedules: {error}'**
  String cannotRestoreAutoSchedule(String error);

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String updatedAt(String time);

  /// No description provided for @schedulesContinueOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved schedules continue to run while the device is offline.'**
  String get schedulesContinueOffline;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @solutionTemperature.
  ///
  /// In en, this message translates to:
  /// **'Solution temperature'**
  String get solutionTemperature;

  /// No description provided for @pumpControl.
  ///
  /// In en, this message translates to:
  /// **'Pump control'**
  String get pumpControl;

  /// No description provided for @unavailableOffline.
  ///
  /// In en, this message translates to:
  /// **'Unavailable while offline'**
  String get unavailableOffline;

  /// No description provided for @sendingCommand.
  ///
  /// In en, this message translates to:
  /// **'Sending command…'**
  String get sendingCommand;

  /// No description provided for @pumpRunning.
  ///
  /// In en, this message translates to:
  /// **'Pump is running'**
  String get pumpRunning;

  /// No description provided for @pumpStopped.
  ///
  /// In en, this message translates to:
  /// **'Pump is off'**
  String get pumpStopped;

  /// No description provided for @nextSprayIn.
  ///
  /// In en, this message translates to:
  /// **'Next spray in {time}'**
  String nextSprayIn(String time);

  /// No description provided for @noActiveSpraySchedule.
  ///
  /// In en, this message translates to:
  /// **'No active spray schedule'**
  String get noActiveSpraySchedule;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @startPump.
  ///
  /// In en, this message translates to:
  /// **'START PUMP'**
  String get startPump;

  /// No description provided for @wateringSchedule.
  ///
  /// In en, this message translates to:
  /// **'Watering schedule'**
  String get wateringSchedule;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @noAutomaticSchedules.
  ///
  /// In en, this message translates to:
  /// **'No automatic schedules.'**
  String get noAutomaticSchedules;

  /// No description provided for @history24Hours.
  ///
  /// In en, this message translates to:
  /// **'24-hour history'**
  String get history24Hours;

  /// No description provided for @notEnoughChartData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data to draw a chart.'**
  String get notEnoughChartData;

  /// No description provided for @alertsOpen.
  ///
  /// In en, this message translates to:
  /// **'{count} open alerts'**
  String alertsOpen(int count);

  /// No description provided for @noOpenAlerts.
  ///
  /// In en, this message translates to:
  /// **'No open alerts.'**
  String get noOpenAlerts;

  /// No description provided for @renameDevice.
  ///
  /// In en, this message translates to:
  /// **'Rename device'**
  String get renameDevice;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get deviceName;

  /// No description provided for @deviceNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Device name is required'**
  String get deviceNameRequired;

  /// No description provided for @deviceRenamed.
  ///
  /// In en, this message translates to:
  /// **'Device renamed'**
  String get deviceRenamed;

  /// No description provided for @cannotRenameDevice.
  ///
  /// In en, this message translates to:
  /// **'Unable to rename device: {error}'**
  String cannotRenameDevice(String error);

  /// No description provided for @deleteDevice.
  ///
  /// In en, this message translates to:
  /// **'Delete device'**
  String get deleteDevice;

  /// No description provided for @deleteDeviceWarning.
  ///
  /// In en, this message translates to:
  /// **'The device will be reset and stop reporting. Saved spray schedules may stop. Make sure the plants are cared for.'**
  String get deleteDeviceWarning;

  /// No description provided for @cannotDeleteDevice.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete device: {error}'**
  String cannotDeleteDevice(String error);

  /// No description provided for @deviceSettings.
  ///
  /// In en, this message translates to:
  /// **'Device settings'**
  String get deviceSettings;

  /// No description provided for @highTemperatureAlert.
  ///
  /// In en, this message translates to:
  /// **'High temperature alert (°C)'**
  String get highTemperatureAlert;

  /// No description provided for @lowWaterAlertThreshold.
  ///
  /// In en, this message translates to:
  /// **'Low water alert (%)'**
  String get lowWaterAlertThreshold;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get saveSettings;

  /// No description provided for @deviceInformation.
  ///
  /// In en, this message translates to:
  /// **'Device information'**
  String get deviceInformation;

  /// No description provided for @wifiSignal.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi signal'**
  String get wifiSignal;

  /// No description provided for @cannotLoadDeviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Unable to load device details'**
  String get cannotLoadDeviceDetails;

  /// No description provided for @addDevice.
  ///
  /// In en, this message translates to:
  /// **'Add device'**
  String get addDevice;

  /// No description provided for @createDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your Aerogreen device'**
  String get createDeviceTitle;

  /// No description provided for @createDeviceExplanation.
  ///
  /// In en, this message translates to:
  /// **'Name the device first. After it is created, you will receive a one-time setup code.'**
  String get createDeviceExplanation;

  /// No description provided for @createAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Create and continue'**
  String get createAndContinue;

  /// No description provided for @returnToDeviceList.
  ///
  /// In en, this message translates to:
  /// **'Return to device list'**
  String get returnToDeviceList;

  /// No description provided for @deviceCreateOutcomeUnknown.
  ///
  /// In en, this message translates to:
  /// **'The request was interrupted, so the device may already exist. Return to the device list before trying again to avoid a duplicate.'**
  String get deviceCreateOutcomeUnknown;

  /// No description provided for @deviceCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to create the device. Please try again.'**
  String get deviceCreateFailed;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @deviceActionForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to manage this device.'**
  String get deviceActionForbidden;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait before trying again.'**
  String get tooManyRequests;

  /// No description provided for @serverUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The server is temporarily unavailable. Please try again later.'**
  String get serverUnavailable;

  /// No description provided for @provisioningCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'This setup code has expired. Generate a new code.'**
  String get provisioningCodeExpired;

  /// No description provided for @provisioningAcceptedWaiting.
  ///
  /// In en, this message translates to:
  /// **'Setup was accepted. Waiting for the backend to confirm the device is online.'**
  String get provisioningAcceptedWaiting;

  /// No description provided for @provisioningOutcomeUnknown.
  ///
  /// In en, this message translates to:
  /// **'The request was interrupted and this one-time code may have been consumed. Generate a new code before trying again.'**
  String get provisioningOutcomeUnknown;

  /// No description provided for @deviceOnlineConfirmed.
  ///
  /// In en, this message translates to:
  /// **'The backend confirms that the device is online.'**
  String get deviceOnlineConfirmed;

  /// No description provided for @deviceOnlineNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Setup was accepted, but the backend has not confirmed the device online yet. Check the device list again shortly.'**
  String get deviceOnlineNotConfirmed;

  /// No description provided for @malformedProvisioningResponse.
  ///
  /// In en, this message translates to:
  /// **'The server returned an invalid setup-code response.'**
  String get malformedProvisioningResponse;

  /// No description provided for @provisioningCodeRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to generate a setup code.'**
  String get provisioningCodeRequestFailed;

  /// No description provided for @regenerateCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate a new code?'**
  String get regenerateCodeTitle;

  /// No description provided for @regenerateCodeWarning.
  ///
  /// In en, this message translates to:
  /// **'The current code will stop working immediately.'**
  String get regenerateCodeWarning;

  /// No description provided for @generateNewCode.
  ///
  /// In en, this message translates to:
  /// **'Generate new code'**
  String get generateNewCode;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Check your network connection and try again.'**
  String get networkError;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
