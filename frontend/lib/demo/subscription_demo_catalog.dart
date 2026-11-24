/// Frontend-only subscription catalog.
///
/// Keep this data isolated so an API-backed catalog can replace it without
/// changing the selection and order-summary UI.
class DemoSubscriptionPlan {
  const DemoSubscriptionPlan({
    required this.id,
    required this.monthlyPrice,
    required this.benefitKeys,
  });

  final String id;
  final int monthlyPrice;
  final List<String> benefitKeys;
}

class DemoPlantOption {
  const DemoPlantOption({
    required this.id,
    required this.imageAsset,
    required this.seedlingsPerTower,
    required this.nutrientMlPerTower,
  });

  final String id;
  final String imageAsset;
  final int seedlingsPerTower;
  final int nutrientMlPerTower;
}

abstract final class SubscriptionDemoCatalog {
  static const plans = <DemoSubscriptionPlan>[
    DemoSubscriptionPlan(
      id: 'starter',
      monthlyPrice: 99000,
      benefitKeys: ['monitoring', 'support'],
    ),
    DemoSubscriptionPlan(
      id: 'garden',
      monthlyPrice: 179000,
      benefitKeys: ['monitoring', 'support', 'insights'],
    ),
    DemoSubscriptionPlan(
      id: 'pro',
      monthlyPrice: 249000,
      benefitKeys: ['monitoring', 'support', 'insights', 'priority'],
    ),
  ];

  static const plants = <DemoPlantOption>[
    DemoPlantOption(
      id: 'butterhead',
      imageAsset: 'assets/images/plants/lettuce.png',
      seedlingsPerTower: 12,
      nutrientMlPerTower: 250,
    ),
    DemoPlantOption(
      id: 'genovese',
      imageAsset: 'assets/images/plants/basil.png',
      seedlingsPerTower: 12,
      nutrientMlPerTower: 250,
    ),
    DemoPlantOption(
      id: 'baby-leaf',
      imageAsset: 'assets/images/plants/spinach.png',
      seedlingsPerTower: 12,
      nutrientMlPerTower: 250,
    ),
    DemoPlantOption(
      id: 'spearmint',
      imageAsset: 'assets/images/plants/mint.png',
      seedlingsPerTower: 12,
      nutrientMlPerTower: 250,
    ),
    DemoPlantOption(
      id: 'tuscan',
      imageAsset: 'assets/images/plants/kale.png',
      seedlingsPerTower: 12,
      nutrientMlPerTower: 250,
    ),
    DemoPlantOption(
      id: 'slow-bolt',
      imageAsset: 'assets/images/plants/coriander.png',
      seedlingsPerTower: 12,
      nutrientMlPerTower: 250,
    ),
  ];

  static const plantPackPricePerTower = 24000;
  static const nutrientPricePerTower = 18000;
}
