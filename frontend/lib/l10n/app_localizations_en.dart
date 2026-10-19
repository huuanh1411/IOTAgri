// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get customize => 'Customize';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get home => 'Home';

  @override
  String get alerts => 'Alerts';

  @override
  String get choosePlant => 'Choose Plant';

  @override
  String get more => 'More';

  @override
  String get lowWaterAlert => 'Low water alert';

  @override
  String get lowNutrientAlert => 'Low nutrient alert';

  @override
  String get temperatureAlert => 'Temperature alert';

  @override
  String get harvestReminder => 'Harvest reminder';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String gardenOf(String name) {
    return '$name\'s Garden';
  }

  @override
  String get gardenTitle => 'Your garden';

  @override
  String get gardenSubtitle => 'Your green space';

  @override
  String get sensorLoadError => 'Unable to load sensor data';

  @override
  String get healthy => 'HEALTHY';

  @override
  String get growing => 'GROWING';

  @override
  String dayProgress(String variety, int day, int totalDays) {
    return '$variety · Day $day / $totalDays';
  }

  @override
  String get germination => 'Germination';

  @override
  String get growth => 'Growth';

  @override
  String get harvest => 'Harvest';

  @override
  String get liveSensors => 'Live sensors';

  @override
  String get synced => '● Synced';

  @override
  String get waterLevel => 'Water level';

  @override
  String get airTemperature => 'Air temperature';

  @override
  String get light => 'LIGHT';

  @override
  String get waterTemperature => 'WATER TEMPERATURE';

  @override
  String get airHumidity => 'AIR HUMIDITY';

  @override
  String careScheduleFor(String plantName) {
    return 'Care schedule for $plantName';
  }

  @override
  String get automaticOptimized => 'Optimized automatically';

  @override
  String get paused => 'Paused';

  @override
  String get wateringCycle => 'WATERING CYCLE';

  @override
  String wateringCycleValue(int minutes, int interval) {
    return '$minutes min every $interval min';
  }

  @override
  String get nutrientCycle => 'NUTRIENT CYCLE';

  @override
  String nutrientCycleValue(int amount, int days) {
    return '$amount ml every $days days';
  }

  @override
  String get idealTemperature => 'IDEAL TEMPERATURE';

  @override
  String get all => 'All';

  @override
  String get alertsSubtitle => 'Track issues in your garden.';

  @override
  String get unresolved => 'Unresolved';

  @override
  String get resolved => 'Resolved';

  @override
  String get noAlerts => 'There are no alerts yet.';

  @override
  String get noUnresolvedAlerts => 'There are no unresolved alerts.';

  @override
  String get noResolvedAlerts => 'There are no resolved alerts yet.';

  @override
  String get markResolved => 'Mark as resolved';

  @override
  String get choosePlantTitle => 'Choose a plant';

  @override
  String get choosePlantSubtitle =>
      'Choose a plant — the system will automatically adjust light, water, and nutrients.';

  @override
  String get confirm => 'Confirm';

  @override
  String replacePlantConfirmation(String currentPlant, String newPlant) {
    return 'You will replace \"$currentPlant\" with \"$newPlant\". Continue?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get agree => 'Continue';

  @override
  String startedPlanting(String plantName) {
    return 'Started growing $plantName';
  }

  @override
  String weeks(int count) {
    return '$count weeks';
  }

  @override
  String pumpCycle(int minutes, int interval) {
    return 'Pump $minutes min every $interval min';
  }

  @override
  String nutrientCycleShort(int amount, int days) {
    return 'Add $amount ml every $days days';
  }

  @override
  String get currentlyGrowing => 'Currently growing';

  @override
  String get startGrowing => 'Start growing';

  @override
  String get devicesTitle => 'Devices';

  @override
  String get devicesSubtitle => 'Manage and connect Aerogreen devices.';

  @override
  String get account => 'Account';

  @override
  String get moreSubtitle => 'Account and application options.';

  @override
  String get customization => 'Customization';

  @override
  String get languageAndNotifications => 'Language and notifications';

  @override
  String get harvestHistory => 'Harvest history';

  @override
  String get plantsGrown => '32 plants grown';

  @override
  String get helpAndSupport => 'Help & support';

  @override
  String get faqAndChat => 'Frequently asked questions and chat';

  @override
  String get logOut => 'Log out';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get authHeadline => 'Effortless urban gardening';

  @override
  String get authTagline =>
      'Grow fresh vegetables on your countertop — Aerogreen handles the rest.';

  @override
  String get fullName => 'Full name';

  @override
  String get emailExample => 'you@example.com';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get passwordRequired => 'Enter your password';

  @override
  String get passwordRequirements =>
      'Your password must include:\n• At least 8 characters\n• A lowercase letter\n• An uppercase letter\n• A number\n• A special character';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get checkSignUpDetails =>
      'Check your email, password (at least 8 characters), and password confirmation.';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get createAccount => 'Create account';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get termsNotice =>
      'By continuing, you agree to the Terms and Privacy Policy.';

  @override
  String get authInvalidCredentials => 'Incorrect email or password.';

  @override
  String get authNetworkError => 'Connection problem. Please try again.';

  @override
  String get authGenericError => 'An error occurred. Please try again.';

  @override
  String get socialSignInNotAvailable => 'Social sign-in is not available yet.';

  @override
  String get harvestLog => 'Harvest log';

  @override
  String startedOn(String date) {
    return 'Started: $date';
  }

  @override
  String harvestedOn(String date) {
    return 'Harvested: $date';
  }

  @override
  String get help => 'Help';

  @override
  String get support => 'Support';

  @override
  String get chatNotAvailable => 'Chat is not integrated yet';

  @override
  String get chatWithUs => 'Chat with us';

  @override
  String get faqAddPlantQuestion => 'How do I add a new plant?';

  @override
  String get faqAddPlantAnswer =>
      'Open the Plants tab, tap the + button, and enter the plant details.';

  @override
  String get faqAlertsQuestion => 'How do I configure alerts?';

  @override
  String get faqAlertsAnswer =>
      'Open More, then Customization, and enable the alert switches.';

  @override
  String get faqUnitsQuestion => 'How do I change units?';

  @override
  String get faqUnitsAnswer =>
      'Open More, then Customization, to select units and language.';

  @override
  String get faqHarvestQuestion => 'Where are past harvests?';

  @override
  String get faqHarvestAnswer => 'View past harvests in Harvest history.';

  @override
  String get offlineBanner => 'You are offline. Showing the most recent data.';

  @override
  String get offlineBannerSemantics =>
      'Network connection warning. You are offline. Showing the most recent data.';

  @override
  String get idealRange => 'Ideal range';

  @override
  String get selectTimeRange => 'Select time range';

  @override
  String get trendDescription => 'Track changes over time';

  @override
  String get sensorHistoryLoadError => 'Unable to load sensor history.';

  @override
  String get noSensorHistory => 'No data is available for this time range.';

  @override
  String get retry => 'Retry';

  @override
  String get cannotStartPumpLowWater =>
      'The pump cannot start while the water level is low.';

  @override
  String get frontendSimulationOnly => 'Frontend simulation only';

  @override
  String get automaticScheduleSimulation => 'Automatic schedule (simulation)';

  @override
  String get addSchedule => 'Add schedule';

  @override
  String get noSchedules =>
      'There are no schedules. Select Add schedule to preview one in the interface.';

  @override
  String get invalidSchedule =>
      'Enter valid times and select at least one day.';

  @override
  String get save => 'Save';

  @override
  String manualControl(String device) {
    return 'Manual $device control';
  }

  @override
  String deviceOn(String device) {
    return '$device is on';
  }

  @override
  String deviceOff(String device) {
    return '$device is off';
  }

  @override
  String get lowWaterPumpOnlyOff =>
      'Water level is below 30%: the pump can only be turned off.';

  @override
  String get confirmDeletion => 'Confirm deletion';

  @override
  String get deleteScheduleConfirmation =>
      'Are you sure you want to delete this schedule?';

  @override
  String get delete => 'Delete';

  @override
  String get error => 'Error';

  @override
  String get dismiss => 'OK';

  @override
  String deleteScheduleFailed(String error) {
    return 'Unable to delete: $error';
  }

  @override
  String wateringScheduleFor(String deviceName) {
    return 'Watering schedule - $deviceName';
  }

  @override
  String get scheduleLoadError => 'Unable to load schedules';

  @override
  String get noSchedulesYet => 'No schedules yet';

  @override
  String get addAutomaticWateringSchedule =>
      'Add an automatic watering schedule';

  @override
  String get addScheduleTitle => 'Add schedule';

  @override
  String get deviceSetup => 'Device setup';

  @override
  String copiedLabel(String label) {
    return '$label copied.';
  }

  @override
  String get manualMode => 'Manual mode';

  @override
  String get autoMode => 'Automatic mode';

  @override
  String get keepManual => 'Keep manual';

  @override
  String get switchToAuto => 'Switch to automatic';

  @override
  String get switchToManual => 'Switch to manual';

  @override
  String get autoScheduleWillPause =>
      'Automatic schedules will pause. Are you sure?';

  @override
  String get cannotStartPumpLowWaterDetail =>
      'The pump cannot start while the water level is low.';

  @override
  String cannotSendCommand(String error) {
    return 'Unable to send command: $error';
  }

  @override
  String get selectRunDuration => 'Choose run duration';

  @override
  String get pumpAutoStop =>
      'The pump will turn off automatically after the selected duration.';

  @override
  String get seconds30 => '30 seconds';

  @override
  String get minute1 => '1 minute';

  @override
  String get minutes5 => '5 minutes';

  @override
  String get minutes10 => '10 minutes';

  @override
  String get device => 'Device';

  @override
  String get sensors => 'Sensors';

  @override
  String get noRecentData => 'No recent data';

  @override
  String get stableConnection => 'Stable connection';

  @override
  String get deviceOffline => 'Device is offline';

  @override
  String get noData => 'No data';

  @override
  String cannotPauseAutoSchedule(String error) {
    return 'Unable to pause automatic schedules: $error';
  }

  @override
  String cannotRestoreAutoSchedule(String error) {
    return 'Unable to restore automatic schedules: $error';
  }

  @override
  String updatedAt(String time) {
    return 'Updated $time';
  }

  @override
  String get schedulesContinueOffline =>
      'Saved schedules continue to run while the device is offline.';

  @override
  String get humidity => 'Humidity';

  @override
  String get solutionTemperature => 'Solution temperature';

  @override
  String get pumpControl => 'Pump control';

  @override
  String get unavailableOffline => 'Unavailable while offline';

  @override
  String get sendingCommand => 'Sending command…';

  @override
  String get pumpRunning => 'Pump is running';

  @override
  String get pumpStopped => 'Pump is off';

  @override
  String nextSprayIn(String time) {
    return 'Next spray in $time';
  }

  @override
  String get noActiveSpraySchedule => 'No active spray schedule';

  @override
  String get stop => 'Stop';

  @override
  String get startPump => 'START PUMP';

  @override
  String get wateringSchedule => 'Watering schedule';

  @override
  String get edit => 'Edit';

  @override
  String get noAutomaticSchedules => 'No automatic schedules.';

  @override
  String get history24Hours => '24-hour history';

  @override
  String get notEnoughChartData => 'Not enough data to draw a chart.';

  @override
  String alertsOpen(int count) {
    return '$count open alerts';
  }

  @override
  String get noOpenAlerts => 'No open alerts.';

  @override
  String get renameDevice => 'Rename device';

  @override
  String get deviceName => 'Device name';

  @override
  String get deviceNameRequired => 'Device name is required';

  @override
  String get deviceRenamed => 'Device renamed';

  @override
  String cannotRenameDevice(String error) {
    return 'Unable to rename device: $error';
  }

  @override
  String get deleteDevice => 'Delete device';

  @override
  String get deleteDeviceWarning =>
      'The device will be reset and stop reporting. Saved spray schedules may stop. Make sure the plants are cared for.';

  @override
  String cannotDeleteDevice(String error) {
    return 'Unable to delete device: $error';
  }

  @override
  String get deviceSettings => 'Device settings';

  @override
  String get highTemperatureAlert => 'High temperature alert (°C)';

  @override
  String get lowWaterAlertThreshold => 'Low water alert (%)';

  @override
  String get saveSettings => 'Save settings';

  @override
  String get deviceInformation => 'Device information';

  @override
  String get wifiSignal => 'Wi-Fi signal';

  @override
  String get cannotLoadDeviceDetails => 'Unable to load device details';
}
