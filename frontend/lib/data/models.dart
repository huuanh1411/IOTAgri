// lib/data/models.dart

import 'package:flutter/material.dart';

/// Plant model representing a plant variety.
class Plant {
  final String id;
  final String name;
  final String variety;
  final int durationWeeks;
  final String difficulty; // "Dễ" or "Trung bình"
  final int pumpMinutes;
  final int pumpEveryMinutes;
  final int nutrientMl;
  final int nutrientEveryDays;
  final double tempMin;
  final double tempMax;
  final String illustration; // emoji or asset name
  final Color tintColor;

  const Plant({
    required this.id,
    required this.name,
    required this.variety,
    required this.durationWeeks,
    required this.difficulty,
    required this.pumpMinutes,
    required this.pumpEveryMinutes,
    required this.nutrientMl,
    required this.nutrientEveryDays,
    required this.tempMin,
    required this.tempMax,
    required this.illustration,
    required this.tintColor,
  });
}

/// Active plant with start date and current day index.
class ActivePlant {
  final Plant plant;
  final DateTime startDate;

  const ActivePlant({required this.plant, required this.startDate});

  /// Zero-based growing day derived from the persisted planting date.
  int currentDayAt(DateTime now) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(start).inDays.clamp(0, plant.durationWeeks * 7 - 1);
  }

  int get currentDay => currentDayAt(DateTime.now());

  int get totalDays => plant.durationWeeks * 7;

  double progressAt(DateTime now) =>
      ((currentDayAt(now) + 1) / totalDays).clamp(0.0, 1.0);
}

/// Sensor readings drifting over time.
class SensorReading {
  final double waterLevel; // percentage 0‑100
  final double nutrientLevel; // percentage 0‑100
  final double temperature; // °C
  final double lightLevel; // percentage 0-100

  const SensorReading({
    required this.waterLevel,
    required this.nutrientLevel,
    required this.temperature,
    this.lightLevel = 76,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      waterLevel: (json['waterLevel'] as num).toDouble(),
      nutrientLevel: (json['nutrientLevel'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      lightLevel: (json['lightLevel'] as num?)?.toDouble() ?? 76,
    );
  }
}

/// Alert information displayed to the user.
class AppAlert {
  final String id;
  final String title;
  final String message;
  final String actionLabel;
  final String type; // e.g., "warning", "info"

  const AppAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.type,
  });
}

/// Simple user profile model.
class UserProfile {
  final String fullName;
  final String email;
  final String plan; // e.g., "Pro"

  const UserProfile({
    required this.fullName,
    required this.email,
    required this.plan,
  });
}
