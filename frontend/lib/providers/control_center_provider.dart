// lib/providers/control_center_provider.dart
// Phase 6: providers for Control Center tab (mode, pump state, spray duration)

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Smart vs Manual control mode.
enum ControlMode { smart, manual }

/// Holds the currently selected control mode.
final controlModeProvider = StateProvider<ControlMode>((ref) => ControlMode.smart);

/// Pump running state – true when the water pump is active.
final pumpRunningProvider = StateProvider<bool>((ref) => false);

/// Nutrient spray duration in seconds (5‑90, default 30).
final sprayDurationProvider = StateProvider<int>((ref) => 30);
