import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../demo/subscription_demo_catalog.dart';
import '../utils/l10n.dart';

enum _DemoPaymentStatus { pending, success, failed }

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  DemoSubscriptionPlan? _selectedPlan;
  final Set<String> _selectedPlantIds = {};
  bool _showPayment = false;
  _DemoPaymentStatus _paymentStatus = _DemoPaymentStatus.pending;

  List<DemoPlantOption> get _selectedPlants => SubscriptionDemoCatalog.plants
      .where((plant) => _selectedPlantIds.contains(plant.id))
      .toList();
  int get _seedlings => _selectedPlants.fold(0, (n, plant) => n + plant.seedlingsPerTower);
  int get _nutrientMl => _selectedPlants.fold(0, (n, plant) => n + plant.nutrientMlPerTower);
  int get _plantPackTotal => _selectedPlants.length * SubscriptionDemoCatalog.plantPackPricePerTower;
  int get _nutrientTotal => _selectedPlants.length * SubscriptionDemoCatalog.nutrientPricePerTower;
  int get _orderTotal => (_selectedPlan?.monthlyPrice ?? 0) + _plantPackTotal + _nutrientTotal;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(_showPayment ? context.l10n.paymentDetails : context.l10n.subscription),
      leading: _showPayment ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _showPayment = false)) : null,
    ),
    body: SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            child: _showPayment ? _paymentView() : _selectionView(),
          ),
        ),
      ),
    ),
  );

  Widget _selectionView() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(context.l10n.subscriptionSubtitle, style: const TextStyle(color: AppColors.secondaryText)),
    const SizedBox(height: 10), _demoNotice(), const SizedBox(height: 20),
    Text(context.l10n.choosePlan, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 10),
    ...SubscriptionDemoCatalog.plans.map(_planCard),
    if (_selectedPlan != null) ...[
      const SizedBox(height: 20), Text(context.l10n.choosePlants, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 4),
      Text(context.l10n.choosePlantsSubtitle, style: const TextStyle(color: AppColors.secondaryText)), const SizedBox(height: 12),
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: SubscriptionDemoCatalog.plants.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .82),
          itemBuilder: (context, index) => _plantCard(SubscriptionDemoCatalog.plants[index]),
        );
      }),
    ],
    const SizedBox(height: 20), _orderSummary(), const SizedBox(height: 16),
    SizedBox(width: double.infinity, child: FilledButton.icon(
      onPressed: _selectedPlan == null ? null : () => setState(() => _showPayment = true), icon: const Icon(Icons.qr_code_2_outlined), label: Text(context.l10n.openDemoQr),
      style: FilledButton.styleFrom(backgroundColor: AppColors.forestGreen, padding: const EdgeInsets.symmetric(vertical: 15)),
    )),
  ]);

  Widget _demoNotice() => Container(
    width: double.infinity, padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.mintChip, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [const Icon(Icons.info_outline, color: AppColors.forestGreen), const SizedBox(width: 10), Expanded(child: Text(context.l10n.demoDataNotice, style: const TextStyle(color: AppColors.secondaryText)))]),
  );

  Widget _planCard(DemoSubscriptionPlan plan) {
    final selected = _selectedPlan?.id == plan.id;
    return Card(margin: const EdgeInsets.only(bottom: 10), color: selected ? AppColors.mintChip : AppColors.surface, shape: RoundedRectangleBorder(side: BorderSide(color: selected ? AppColors.forestGreen : Colors.transparent, width: 1.5), borderRadius: BorderRadius.circular(16)), child: InkWell(
      borderRadius: BorderRadius.circular(16), onTap: () => setState(() => _selectedPlan = plan), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(_planName(plan), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))), Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: selected ? AppColors.forestGreen : AppColors.mutedSage)]),
        const SizedBox(height: 4), Text(_planDescription(plan), style: const TextStyle(color: AppColors.secondaryText)),
        Padding(padding: const EdgeInsets.only(top: 10, bottom: 6), child: Text(_money(plan.monthlyPrice), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.forestGreen))),
        ...plan.benefitKeys.map((key) => Padding(padding: const EdgeInsets.only(top: 3), child: Text('• ${_benefit(key)}'))),
      ])),
    ));
  }

  Widget _plantCard(DemoPlantOption plant) {
    final selected = _selectedPlantIds.contains(plant.id);
    return Semantics(selected: selected, button: true, label: _plantName(plant), child: InkWell(
      borderRadius: BorderRadius.circular(16), onTap: () => setState(() => selected ? _selectedPlantIds.remove(plant.id) : _selectedPlantIds.add(plant.id)), child: Ink(
        decoration: BoxDecoration(color: selected ? AppColors.mintChip : AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? AppColors.forestGreen : Colors.transparent, width: 1.5)), padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Align(alignment: Alignment.topRight, child: Icon(selected ? Icons.check_circle : Icons.add_circle_outline, color: selected ? AppColors.forestGreen : AppColors.mutedSage)),
          Expanded(child: Center(child: Image.asset(plant.imageAsset, fit: BoxFit.contain))),
          Text(_plantName(plant), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(_plantVariety(plant), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)), const SizedBox(height: 3),
          Text(context.l10n.oneTower, style: const TextStyle(color: AppColors.mutedSage, fontSize: 12)),
        ]),
      ),
    ));
  }

  Widget _orderSummary() => Card(color: AppColors.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(context.l10n.orderSummary, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 10),
    _summaryRow(context.l10n.selectedPlan, _selectedPlan == null ? '—' : _planName(_selectedPlan!)), _summaryRow(context.l10n.selectedPlants, '${_selectedPlants.length}'), _summaryRow(context.l10n.growingTowers, '${_selectedPlants.length}'), _summaryRow(context.l10n.seedlings, '$_seedlings'), _summaryRow(context.l10n.nutrientSolution, '$_nutrientMl ml'), const Divider(height: 24),
    _summaryRow(context.l10n.planPrice, _selectedPlan == null ? '—' : _money(_selectedPlan!.monthlyPrice)), _summaryRow(context.l10n.seedlingPrice, _money(_plantPackTotal)), _summaryRow(context.l10n.nutrientPrice, _money(_nutrientTotal)), const Divider(height: 24),
    _summaryRow(context.l10n.demoTotal, _money(_orderTotal), bold: true), const SizedBox(height: 8), Text(context.l10n.demoPriceDisclaimer, style: const TextStyle(color: AppColors.mutedSage, fontSize: 12)),
  ])));
  Widget _summaryRow(String label, String value, {bool bold = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Expanded(child: Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w700 : null))), Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w700 : null, color: bold ? AppColors.forestGreen : null))]));

  Widget _paymentView() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _demoNotice(), const SizedBox(height: 16), _orderSummary(), const SizedBox(height: 16),
    Card(color: AppColors.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      _paymentStatusLabel(), const SizedBox(height: 16), const _DemoQrCode(), const SizedBox(height: 16), Text(_money(_orderTotal), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.forestGreen)), const SizedBox(height: 6), Text(context.l10n.demoOrderReference, style: const TextStyle(color: AppColors.secondaryText)), const SizedBox(height: 14), Text(context.l10n.demoQrNotice, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.mutedSage)),
    ]))), const SizedBox(height: 16), Text(context.l10n.paymentInstructions, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.secondaryText)), const SizedBox(height: 20), Text(context.l10n.tryDemoStatus, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8),
    Wrap(spacing: 8, runSpacing: 8, children: _DemoPaymentStatus.values.map((status) => ChoiceChip(label: Text(_statusText(status)), selected: _paymentStatus == status, onSelected: (_) => setState(() => _paymentStatus = status))).toList()),
  ]);

  Widget _paymentStatusLabel() {
    final (text, color, icon) = switch (_paymentStatus) { _DemoPaymentStatus.pending => (context.l10n.paymentPending, AppColors.mutedSage, Icons.schedule_outlined), _DemoPaymentStatus.success => (context.l10n.paymentSucceededDemo, AppColors.mint, Icons.check_circle_outline), _DemoPaymentStatus.failed => (context.l10n.paymentFailedDemo, AppColors.danger, Icons.error_outline) };
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
  String _statusText(_DemoPaymentStatus status) => switch (status) { _DemoPaymentStatus.pending => context.l10n.paymentPending, _DemoPaymentStatus.success => context.l10n.paymentSuccessStatus, _DemoPaymentStatus.failed => context.l10n.paymentFailedStatus };
  String _planName(DemoSubscriptionPlan p) => switch (p.id) { 'starter' => context.l10n.demoPlanStarterName, 'garden' => context.l10n.demoPlanGardenName, _ => context.l10n.demoPlanProName };
  String _planDescription(DemoSubscriptionPlan p) => switch (p.id) { 'starter' => context.l10n.demoPlanStarterDescription, 'garden' => context.l10n.demoPlanGardenDescription, _ => context.l10n.demoPlanProDescription };
  String _benefit(String key) => switch (key) { 'monitoring' => context.l10n.demoBenefitMonitoring, 'support' => context.l10n.demoBenefitSupport, 'insights' => context.l10n.demoBenefitInsights, _ => context.l10n.demoBenefitPriority };
  String _plantName(DemoPlantOption p) => switch (p.id) { 'butterhead' => context.l10n.demoPlantButterhead, 'genovese' => context.l10n.demoPlantGenovese, 'baby-leaf' => context.l10n.demoPlantBabyLeaf, 'spearmint' => context.l10n.demoPlantSpearmint, 'tuscan' => context.l10n.demoPlantTuscan, _ => context.l10n.demoPlantSlowBolt };
  String _plantVariety(DemoPlantOption p) => switch (p.id) { 'butterhead' => 'Butterhead', 'genovese' => 'Genovese', 'baby-leaf' => 'Baby leaf', 'spearmint' => 'Spearmint', 'tuscan' => 'Tuscan', _ => 'Slow-bolt' };
  String _money(int amount) => '${amount.toString().replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (_) => '.')} đ';
}

class _DemoQrCode extends StatelessWidget { const _DemoQrCode(); @override Widget build(BuildContext context) => AspectRatio(aspectRatio: 1, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(border: Border.all(color: AppColors.mutedSage), borderRadius: BorderRadius.circular(12)), child: CustomPaint(painter: _QrPainter()))); }
class _QrPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) { const cells = 21; final unit = size.width / cells; final paint = Paint()..color = AppColors.primaryText; bool inFinder(int x, int y) => (x < 7 && y < 7) || (x >= 14 && y < 7) || (x < 7 && y >= 14); for (var y = 0; y < cells; y++) { for (var x = 0; x < cells; x++) { final finder = inFinder(x, y); final border = finder && ((x % 7 == 0 || x % 7 == 6) || (y % 7 == 0 || y % 7 == 6) || ((x % 7 >= 2 && x % 7 <= 4) && (y % 7 >= 2 && y % 7 <= 4))); if (border || (!finder && ((x * 13 + y * 7 + x * y) % 5 < 2))) canvas.drawRect(Rect.fromLTWH(x * unit, y * unit, unit, unit), paint); } } }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
