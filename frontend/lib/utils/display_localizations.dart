import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../models/device_alert.dart';
import '../models/history_data.dart';
import '../services/api_error.dart';

String localizedApiError(Object error, AppLocalizations l10n) =>
    switch (ApiError.from(error).kind) {
      ApiErrorKind.network || ApiErrorKind.timeout => l10n.networkError,
      ApiErrorKind.authentication => l10n.sessionExpired,
      ApiErrorKind.authorization => l10n.deviceActionForbidden,
      ApiErrorKind.rateLimited => l10n.tooManyRequests,
      ApiErrorKind.server => l10n.serverUnavailable,
      ApiErrorKind.validation => l10n.requestValidationFailed,
      _ => l10n.actionFailed,
    };

extension LocalizedHistoryRange on HistoryRange {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    HistoryRange.day => '24h',
    HistoryRange.week => l10n.historySevenDays,
    HistoryRange.month => l10n.historyThirtyDays,
    HistoryRange.custom => l10n.customize,
  };
}

extension LocalizedHistorySensor on HistorySensor {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    HistorySensor.temperature => l10n.airTemperature,
    HistorySensor.solutionTemperature => l10n.solutionTemperature,
    HistorySensor.humidity => l10n.humidity,
    HistorySensor.tds => 'TDS',
    HistorySensor.ph => 'pH',
    HistorySensor.waterLevel => l10n.waterLevel,
    HistorySensor.lux => l10n.lightSensorTitle,
  };
}

/// Resolve catalog data at render time so a locale change preserves plant and
/// alert identities, selections, and read/resolved state.
extension LocalizedPlant on Plant {
  String localizedName(AppLocalizations l10n) => switch (id) {
    '1' => l10n.plantLettuce,
    '2' => l10n.plantBasil,
    '3' => l10n.plantSpinach,
    '4' => l10n.plantMint,
    '5' => l10n.plantKale,
    '6' => l10n.plantCoriander,
    _ => name,
  };

  String localizedDifficulty(AppLocalizations l10n) => switch (difficulty) {
    'Dễ' => l10n.difficultyEasy,
    'Trung bình' => l10n.difficultyMedium,
    _ => difficulty,
  };
}

extension LocalizedAppAlert on AppAlert {
  String localizedTitle(AppLocalizations l10n) => switch (id) {
    'water_low' => l10n.lowWaterTitle,
    'nutrient_low' => l10n.lowNutrientTitle,
    _ => title,
  };

  String localizedMessage(AppLocalizations l10n) => switch (id) {
    'water_low' => l10n.lowWaterMessage,
    'nutrient_low' => l10n.lowNutrientMessage,
    _ => message,
  };

  String localizedAction(AppLocalizations l10n) => switch (id) {
    'water_low' => l10n.refillWater,
    'nutrient_low' => l10n.addNutrients,
    _ => actionLabel,
  };
}

extension LocalizedDeviceAlert on DeviceAlert {
  String localizedTitle(AppLocalizations l10n) {
    final normalized = type.toUpperCase();
    if (normalized.contains('HIGH_TEMPERATURE')) {
      return l10n.highTemperatureTitle;
    }
    if (normalized.contains('LOW_TEMPERATURE')) return l10n.lowTemperatureTitle;
    if (normalized.contains('LOW_WATER')) return l10n.lowWaterTitle;
    if (normalized.contains('EMPTY')) return l10n.waterEmptyTitle;
    if (normalized.contains('HUMIDITY')) return l10n.humidityAlertTitle;
    if (normalized.contains('PUMP_FAULT')) return l10n.pumpFaultTitle;
    if (normalized.contains('OFFLINE')) return l10n.deviceOfflineTitle;
    if (normalized.contains('BACK_ONLINE')) return l10n.deviceOnlineTitle;
    if (normalized.contains('NUTRIENT') || normalized.contains('EC')) {
      return l10n.nutrientAlertTitle;
    }
    if (normalized.contains('PH')) return l10n.phAlertTitle;
    return l10n.sensorAlertTitle;
  }

  String localizedMessage(AppLocalizations l10n) {
    final normalized = type.toUpperCase();
    if (normalized.contains('HIGH_TEMPERATURE')) {
      return l10n.highTemperatureMessage(
        measuredValue.toStringAsFixed(1),
        threshold.toStringAsFixed(1),
      );
    }
    if (normalized.contains('LOW_WATER')) {
      return l10n.lowWaterThresholdMessage(
        measuredValue.toStringAsFixed(0),
        threshold.toStringAsFixed(0),
      );
    }
    return l10n.sensorThresholdMessage(
      measuredValue.toStringAsFixed(1),
      threshold.toStringAsFixed(1),
    );
  }
}
