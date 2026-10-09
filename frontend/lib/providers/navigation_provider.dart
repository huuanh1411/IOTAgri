// lib/providers/navigation_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the currently selected index for the floating navigation bar.
final navIndexProvider = StateProvider<int>((ref) => 0);
