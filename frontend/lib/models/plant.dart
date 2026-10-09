// lib/models/plant.dart
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
  final int tempMin;
  final int tempMax;
  final String illustration; // emoji or asset name
  final int tintColor; // ARGB int

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
