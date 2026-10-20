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
  String get goodNight => 'Good night';

  @override
  String gardenOf(String name) {
    return '$name\'s Garden';
  }

  @override
  String gardenOfEndingWithS(String name) {
    return '$name\' Garden';
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

  @override
  String get addDevice => 'Add device';

  @override
  String get createDeviceTitle => 'Create your Aerogreen device';

  @override
  String get createDeviceExplanation =>
      'Name the device first. After it is created, you will receive a one-time setup code.';

  @override
  String get createAndContinue => 'Create and continue';

  @override
  String get returnToDeviceList => 'Return to device list';

  @override
  String get deviceCreateOutcomeUnknown =>
      'The request was interrupted, so the device may already exist. Return to the device list before trying again to avoid a duplicate.';

  @override
  String get deviceCreateFailed =>
      'Unable to create the device. Please try again.';

  @override
  String get sessionExpired => 'Your session expired. Please sign in again.';

  @override
  String get deviceActionForbidden =>
      'You do not have permission to manage this device.';

  @override
  String get tooManyRequests =>
      'Too many requests. Please wait before trying again.';

  @override
  String get serverUnavailable =>
      'The server is temporarily unavailable. Please try again later.';

  @override
  String get provisioningCodeExpired =>
      'This setup code has expired. Generate a new code.';

  @override
  String get provisioningAcceptedWaiting =>
      'Setup was accepted. Waiting for the backend to confirm the device is online.';

  @override
  String get provisioningOutcomeUnknown =>
      'The request was interrupted and this one-time code may have been consumed. Generate a new code before trying again.';

  @override
  String get deviceOnlineConfirmed =>
      'The backend confirms that the device is online.';

  @override
  String get deviceOnlineNotConfirmed =>
      'Setup was accepted, but the backend has not confirmed the device online yet. Check the device list again shortly.';

  @override
  String get malformedProvisioningResponse =>
      'The server returned an invalid setup-code response.';

  @override
  String get provisioningCodeRequestFailed =>
      'Unable to generate a setup code.';

  @override
  String get regenerateCodeTitle => 'Generate a new code?';

  @override
  String get regenerateCodeWarning =>
      'The current code will stop working immediately.';

  @override
  String get generateNewCode => 'Generate new code';

  @override
  String get networkError => 'Check your network connection and try again.';

  @override
  String get deleteDeviceTitle => 'Delete device?';

  @override
  String deleteNamedDeviceConfirmation(String value0) {
    return 'Are you sure you want to delete \"$value0\"? This cannot be undone.';
  }

  @override
  String get actionFailed => 'Unable to complete the action';

  @override
  String get searchDevicesHint => 'Search by name or location';

  @override
  String get noMatchingDevices => 'No devices found.';

  @override
  String get unassignedLocation => 'Location not assigned';

  @override
  String deviceNeverConnected(String value0) {
    return 'No connection yet · $value0';
  }

  @override
  String deviceLastSeen(String value0, String value1) {
    return 'Last seen $value0 · $value1';
  }

  @override
  String get devicesEmptyTitle => 'No devices yet';

  @override
  String get devicesEmptyExplanation =>
      'Create a device to start setting up its connection.';

  @override
  String get devicesLoadFailed => 'Unable to load devices.';

  @override
  String switchDeviceToAutoConfirmation(String value0) {
    return '$value0 is in Manual mode and is not spraying. Switch to Automatic?';
  }

  @override
  String lightCommandFailed(String value0) {
    return 'Unable to send light command: $value0';
  }

  @override
  String get switchMode => 'Switch';

  @override
  String get deviceDeleted => 'Device deleted successfully';

  @override
  String get noReadingsYet => 'No data yet';

  @override
  String get automaticMode => 'Automatic';

  @override
  String pumpRunningCountdown(String value0) {
    return 'Pump is running - $value0 remaining';
  }

  @override
  String get noScheduledTime => 'No schedule';

  @override
  String get scheduledTimePassed => 'Passed';

  @override
  String minutesRemaining(String value0) {
    return '$value0 min';
  }

  @override
  String get lightControl => 'Light control';

  @override
  String get lightIsOn => 'Light is on';

  @override
  String get lightIsOff => 'Light is off';

  @override
  String sprayScheduleSummary(
    String value0,
    String value1,
    String value2,
    String value3,
  ) {
    return 'Spray for $value0 seconds every $value1 minutes, $value2-$value3';
  }

  @override
  String get savedSchedulesContinue =>
      'Saved schedules continue automatically while connected.';

  @override
  String temperatureRecordCount(String value0) {
    return '$value0 readings · Temperature';
  }

  @override
  String get lowWaterTitle => 'Low water level';

  @override
  String get highTemperatureTitle => 'High temperature';

  @override
  String get invalidDeviceThresholds =>
      'Check the temperature and water level thresholds.';

  @override
  String get renameAction => 'Rename';

  @override
  String get wifiSignalGood => 'Good (-65 dBm)';

  @override
  String get wifiSignalMissing => 'No signal';

  @override
  String get espFoundNoNetworks =>
      'ESP detected, but no 2.4 GHz Wi-Fi networks were found.';

  @override
  String get espConnectedChooseNetwork =>
      'Connected to ESP. Choose a Wi-Fi network below.';

  @override
  String get espConnectionFailed =>
      'Unable to connect to ESP. Connect this device to IOTAgri-Setup Wi-Fi and try again.';

  @override
  String get wifiSsidRequired =>
      'Enter or choose a 2.4 GHz Wi-Fi network name.';

  @override
  String get wifiPasswordRequired => 'Enter the Wi-Fi password.';

  @override
  String get espSendingConfiguration =>
      'Sending configuration directly to ESP...';

  @override
  String get setupCodeValidity => 'Valid for 15 minutes';

  @override
  String get setupCodeExpired => 'Code expired';

  @override
  String setupCodeSecondsRemaining(String value0) {
    return '$value0 seconds remaining';
  }

  @override
  String setupCodeExpiresAt(String value0) {
    return 'Expires at $value0';
  }

  @override
  String get setupCodeMissing => 'The server has not returned a setup code.';

  @override
  String get setupCodeLabel => 'Setup code';

  @override
  String get copyCodeAgain => 'Copy code again';

  @override
  String get copySetupCode => 'Copy code';

  @override
  String get espSetupStepOne =>
      'Keep the laptop running the app and server on your main Wi-Fi. Open this screen on your phone first.';

  @override
  String get espSetupStepTwo =>
      'Connect your phone to IOTAgri-Setup Wi-Fi, return to this screen, and tap Check ESP connection.';

  @override
  String get espSetupStepThree =>
      'Choose a 2.4 GHz Wi-Fi network, enter its password, and tap Connect ESP. The app sends the setup code and server address automatically.';

  @override
  String get espSetupStepFour =>
      'Once setup succeeds, reconnect your phone to your main Wi-Fi and wait for the device to come online.';

  @override
  String espBackendAddress(String value0) {
    return 'Server address for ESP: $value0';
  }

  @override
  String get regenerateSetupCode =>
      'Generate a new code (the old code will stop working)';

  @override
  String get directEspSetup => 'Connect directly to ESP';

  @override
  String get directEspSetupHint =>
      'No need to open Swagger or the 192.168.4.1 configuration page.';

  @override
  String get checkEspConnection => 'Check ESP connection';

  @override
  String espDetected(String value0) {
    return 'ESP detected: $value0';
  }

  @override
  String get espAvailableNetworks => '2.4 GHz Wi-Fi networks detected by ESP:';

  @override
  String get wifiSsidHint => '2.4 GHz Wi-Fi name (SSID)';

  @override
  String get wifiPasswordHint => 'Wi-Fi password';

  @override
  String get connectedStatus => 'Connected';

  @override
  String get connectEsp => 'Connect ESP';

  @override
  String get seedlingsPreset => 'Seedlings';

  @override
  String get leafyPreset => 'Leafy greens';

  @override
  String get herbsPreset => 'Herbs';

  @override
  String sprayDurationSummary(String value0) {
    return 'Spray duration: $value0 seconds';
  }

  @override
  String sprayIntervalSummary(String value0) {
    return 'Repeat every $value0 minutes';
  }

  @override
  String scheduleDaysSummary(String value0) {
    return 'Days: $value0';
  }

  @override
  String get noDaysSelected => 'no days selected';

  @override
  String get sprayDurationRequired => 'Enter a spray duration';

  @override
  String get sprayDurationRange => 'Spray duration must be 1-120 seconds';

  @override
  String get scheduleIntervalRequired => 'Enter an interval';

  @override
  String get scheduleIntervalRange => 'Interval must be 1-60 minutes';

  @override
  String get sprayDurationLessThanInterval =>
      'Spray duration must be shorter than the interval';

  @override
  String get scheduleEndAfterStart =>
      'End time must be after start time (unless overnight)';

  @override
  String schedulePreview(
    String value0,
    String value1,
    String value2,
    String value3,
    String value4,
  ) {
    return 'Spray for $value0 seconds every $value1 minutes, $value2-$value3, $value4';
  }

  @override
  String get selectScheduleDay => 'Select at least one day';

  @override
  String get savedTitle => 'Saved';

  @override
  String get savedToDevice => 'Saved to device';

  @override
  String saveFailed(String value0) {
    return 'Unable to save: $value0';
  }

  @override
  String get unsavedTitle => 'Unsaved changes';

  @override
  String get unsavedChangesConfirmation =>
      'You have unsaved changes. Do you want to leave?';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discardChanges => 'Discard changes';

  @override
  String get deviceScheduleTimezoneHint =>
      'Device time: Asia/Ho_Chi_Minh. Schedules take priority over manual controls.';

  @override
  String get schedulePreset => 'Preset';

  @override
  String get sprayDurationSeconds => 'Spray duration (seconds)';

  @override
  String get scheduleIntervalMinutes => 'Interval (minutes)';

  @override
  String get scheduleTimeWindow => 'Active time window';

  @override
  String get scheduleStart => 'Start';

  @override
  String get scheduleEnd => 'End';

  @override
  String get scheduleRepeatDays => 'Repeat on';

  @override
  String get pumpLabel => 'Pump';

  @override
  String get lightLabel => 'Light';

  @override
  String get turnLightOn => 'Turn on light';

  @override
  String localScheduleSummary(
    String value0,
    String value1,
    String value2,
    String value3,
    String value4,
  ) {
    return '$value0 for $value1 seconds every $value2 minutes · $value3\n$value4 · display only';
  }

  @override
  String actionDurationSeconds(String value0) {
    return '$value0 duration (seconds)';
  }

  @override
  String get timezoneLabel => 'Time zone';

  @override
  String get vietnamTimezone => 'Vietnam · GMT+07:00';

  @override
  String get localScheduleNotice =>
      'This schedule is displayed in the app only; it has not been sent to the device or server.';

  @override
  String get waterSensorTitle => 'Water level';

  @override
  String get waterSensorLabel => 'WATER LEVEL';

  @override
  String get waterSensorDescription =>
      'Monitor the water level to keep your plants properly watered.';

  @override
  String get waterSensorHistory => 'Water level history';

  @override
  String get waterSensorLow => 'Low water level';

  @override
  String get waterSensorStable => 'Water level is stable';

  @override
  String get notConfigured => 'Not configured';

  @override
  String get nutrientSensorDescription =>
      'Monitor nutrient levels to support even plant growth.';

  @override
  String get nutrientSensorHistory => 'Nutrient level history';

  @override
  String get dataReceived => 'Data received';

  @override
  String get temperatureSensorTitle => 'Temperature';

  @override
  String get temperatureSensorLabel => 'TEMPERATURE';

  @override
  String get temperatureSensorDescription =>
      'Monitor the ambient temperature around your plants.';

  @override
  String get temperatureSensorHistory => 'Temperature history';

  @override
  String get temperatureSensorAttention => 'Temperature needs attention';

  @override
  String get temperatureSensorHealthy => 'Temperature is suitable';

  @override
  String get waterTemperatureSensorTitle => 'Water temperature';

  @override
  String get waterTemperatureSensorDescription =>
      'Monitor the nutrient solution with the water temperature sensor.';

  @override
  String get waterTemperatureSensorHistory => 'Water temperature history';

  @override
  String get humiditySensorTitle => 'Air humidity';

  @override
  String get humiditySensorDescription =>
      'Monitor air humidity with the AHT20 sensor.';

  @override
  String get humiditySensorHistory => 'Air humidity history';

  @override
  String get lightSensorTitle => 'Light';

  @override
  String get lightSensorDescription =>
      'Monitor light intensity to support plant photosynthesis.';

  @override
  String get lightSensorHistory => 'Light history';

  @override
  String get resolveNow => 'Resolve now';

  @override
  String get plantLettuce => 'Lettuce';

  @override
  String get plantBasil => 'Basil';

  @override
  String get plantSpinach => 'Spinach';

  @override
  String get plantMint => 'Mint';

  @override
  String get plantKale => 'Kale';

  @override
  String get plantCoriander => 'Coriander';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get lowNutrientTitle => 'Low nutrients';

  @override
  String get lowWaterMessage => 'Water level is below 30% – please refill.';

  @override
  String get lowNutrientMessage =>
      'Nutrient level is below 45% – please add nutrients.';

  @override
  String get refillWater => 'Refill water';

  @override
  String get addNutrients => 'Add nutrients';

  @override
  String get lowTemperatureTitle => 'Low temperature';

  @override
  String get waterEmptyTitle => 'Water tank empty';

  @override
  String get humidityAlertTitle => 'Humidity out of range';

  @override
  String get pumpFaultTitle => 'Pump fault';

  @override
  String get deviceOfflineTitle => 'Device offline';

  @override
  String get deviceOnlineTitle => 'Device back online';

  @override
  String get nutrientAlertTitle => 'Nutrient level out of range';

  @override
  String get phAlertTitle => 'pH out of range';

  @override
  String get sensorAlertTitle => 'Sensor alert';

  @override
  String highTemperatureMessage(String value, String threshold) {
    return 'Temperature $value°C exceeds the $threshold°C threshold.';
  }

  @override
  String lowWaterThresholdMessage(String value, String threshold) {
    return 'Water level $value% is below the $threshold% threshold.';
  }

  @override
  String sensorThresholdMessage(String value, String threshold) {
    return 'Value $value · Threshold $threshold.';
  }

  @override
  String get sprayAction => 'Spray';

  @override
  String get sundayShort => 'Sun';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get fridayShort => 'Fri';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get stillActiveTitle => 'Still active';

  @override
  String get alertRecoveredTitle => 'Recovered';

  @override
  String alertResolvedMessage(String device, String alert) {
    return '$device: $alert has been resolved.';
  }

  @override
  String deviceAlertsTitle(String value0) {
    return 'Alerts · $value0';
  }

  @override
  String get markAllAlertsRead => 'Mark all as read';

  @override
  String get todayLabel => 'Today';

  @override
  String get earlierLabel => 'Earlier';

  @override
  String get criticalSeverity => 'Critical';

  @override
  String get unreadFilter => 'Unread';

  @override
  String get activeAlertStatus => 'Active';

  @override
  String get alertDetailsTitle => 'Alert details';

  @override
  String get timeLabel => 'Time';

  @override
  String get statusLabel => 'Status';

  @override
  String get openAlertDevice => 'Go to device';

  @override
  String get alertsQuietTitle => 'All quiet';

  @override
  String get noMatchingAlerts => 'No alerts match this filter.';

  @override
  String get invalidAlertThreshold =>
      'Thresholds must be valid numbers; water level must be 0–100%.';

  @override
  String get alertThresholdsSaved => 'Alert thresholds saved';

  @override
  String deviceSettingsUpdated(String value0) {
    return 'Settings for $value0 have been updated.';
  }

  @override
  String get alertThresholdsTitle => 'Alert thresholds';

  @override
  String get supportedSensorsOnly =>
      'Only sensors supported by this device are shown.';

  @override
  String get resetRecommendedThresholds => 'Reset to recommended values';

  @override
  String get notificationPreferencesTitle => 'Notification preferences';

  @override
  String get notificationsToggleHint => 'Enable or disable all notifications';

  @override
  String get severityHeading => 'SEVERITY';

  @override
  String get criticalNotificationsHint =>
      'Pump faults, empty water tank, connection loss';

  @override
  String get warningNotificationsHint =>
      'Sensor readings outside their thresholds';

  @override
  String get infoSeverity => 'Information';

  @override
  String get infoNotificationsHint =>
      'Schedules saved, devices back online, firmware updates';

  @override
  String get quietHoursTitle => 'Quiet hours';

  @override
  String get criticalIgnoresQuietHours => 'Critical alerts bypass quiet hours.';

  @override
  String deviceHistoryTitle(String value0) {
    return 'History · $value0';
  }

  @override
  String get hourlyAverages => 'Show hourly averages';

  @override
  String get historyFiltersTitle => 'History filters';

  @override
  String get showPumpEvents => 'Show pump events';

  @override
  String get resetAction => 'Reset';

  @override
  String get applyAction => 'Apply';

  @override
  String get fromDateLabel => 'From date';

  @override
  String get toDateLabel => 'To date';

  @override
  String get customHistoryRangeInvalid =>
      'The custom range must be between 1 and 31 days.';

  @override
  String get exportDataTitle => 'Export data';

  @override
  String get exportDataFailed =>
      'Unable to create the file. Try a shorter range.';

  @override
  String get createFileAction => 'Create file';

  @override
  String pumpEventsCount(String value0) {
    return 'Pump events · $value0';
  }

  @override
  String get minimumLabel => 'Minimum';

  @override
  String get maximumLabel => 'Maximum';

  @override
  String get historyLoadFailed => 'Unable to load history';

  @override
  String get newDeviceInsufficientData =>
      'This new device does not have enough data yet';

  @override
  String get historyRangeEmpty => 'No data in this range';

  @override
  String get changeHistoryRange => 'Change time range';

  @override
  String viewSensorDetails(String value0) {
    return 'View $value0 details';
  }

  @override
  String get genericErrorTitle => 'An error occurred';

  @override
  String get requestValidationFailed =>
      'Check the entered information and try again.';

  @override
  String get historySevenDays => '7 days';

  @override
  String get historyThirtyDays => '30 days';

  @override
  String get averageLabel => 'Average';
}
