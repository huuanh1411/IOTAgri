import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../utils/l10n.dart';

/// Display-ready subscription data supplied by the backend integration.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.benefits,
    this.formattedPrice,
  });
  final String id;
  final String name;
  final String description;
  final List<String> benefits;
  final String? formattedPrice;
}

enum PaymentStatus { pending, succeeded, failed, expired }

/// The frontend deliberately renders, rather than calculates, payment data.
class PaymentDetails {
  const PaymentDetails({
    required this.qrImageUrl,
    required this.status,
    this.formattedAmount,
    this.orderReference,
    this.expiryLabel,
  });
  final String? qrImageUrl;
  final PaymentStatus status;
  final String? formattedAmount;
  final String? orderReference;
  final String? expiryLabel;
}

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key, this.plans = const [], this.payment});
  final List<SubscriptionPlan> plans;
  final PaymentDetails? payment;
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  static const _plants = <_PlantOption>[
    _PlantOption('butterhead', 'Xà lách', 'Butterhead', Icons.spa_outlined),
    _PlantOption('genovese', 'Húng quế', 'Genovese', Icons.grass_outlined),
    _PlantOption('baby-leaf', 'Rau chân vịt', 'Baby leaf', Icons.eco_outlined),
    _PlantOption(
      'spearmint',
      'Bạc hà',
      'Spearmint',
      Icons.energy_savings_leaf_outlined,
    ),
    _PlantOption('tuscan', 'Cải xoăn', 'Tuscan', Icons.park_outlined),
    _PlantOption(
      'slow-bolt',
      'Rau mùi',
      'Slow-bolt',
      Icons.local_florist_outlined,
    ),
  ];
  SubscriptionPlan? _selectedPlan;
  final Set<String> _selectedPlantIds = {};
  bool _showPayment = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        _showPayment ? context.l10n.paymentDetails : context.l10n.subscription,
      ),
    ),
    body: SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
            child: _showPayment ? _payment() : _selection(),
          ),
        ),
      ),
    ),
  );

  Widget _selection() {
    final l = context.l10n;
    if (widget.plans.isEmpty) {
      return _empty(
        l.subscriptionUnavailable,
        l.subscriptionUnavailableDetail,
        Icons.credit_card_off_outlined,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.subscriptionSubtitle,
          style: const TextStyle(color: AppColors.secondaryText),
        ),
        const SizedBox(height: 20),
        Text(l.choosePlan, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        RadioGroup<String>(
          groupValue: _selectedPlan?.id,
          onChanged: (id) => setState(
            () => _selectedPlan = widget.plans.firstWhere(
              (plan) => plan.id == id,
            ),
          ),
          child: Column(children: widget.plans.map(_planCard).toList()),
        ),
        const SizedBox(height: 20),
        Text(l.choosePlants, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          l.choosePlantsSubtitle,
          style: const TextStyle(color: AppColors.secondaryText),
        ),
        const SizedBox(height: 10),
        ..._plants.map(_plantTile),
        const SizedBox(height: 18),
        _summary(),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _selectedPlan == null
                ? null
                : () => setState(() => _showPayment = true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text(l.continueToPayment),
          ),
        ),
      ],
    );
  }

  Widget _empty(String title, String detail, IconData icon) => Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.mutedSage),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.secondaryText),
          ),
        ],
      ),
    ),
  );

  Widget _planCard(SubscriptionPlan plan) {
    final selected = _selectedPlan?.id == plan.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: selected ? AppColors.mintChip : AppColors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selectedPlan = plan),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Radio<String>(value: plan.id),
                ],
              ),
              Text(
                plan.description,
                style: const TextStyle(color: AppColors.secondaryText),
              ),
              if (plan.formattedPrice != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    plan.formattedPrice!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ),
              ...plan.benefits.map(
                (value) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('• $value'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _plantTile(_PlantOption plant) {
    final selected = _selectedPlantIds.contains(plant.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: selected,
        activeColor: AppColors.forestGreen,
        secondary: CircleAvatar(
          backgroundColor: AppColors.mintChip,
          child: Icon(plant.icon, color: AppColors.forestGreen),
        ),
        title: Text(plant.name),
        subtitle: Text(plant.variety),
        onChanged: (_) => setState(
          () => selected
              ? _selectedPlantIds.remove(plant.id)
              : _selectedPlantIds.add(plant.id),
        ),
      ),
    );
  }

  Widget _summary() => Card(
    color: AppColors.surface,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.selectedPlan,
            style: const TextStyle(color: AppColors.secondaryText),
          ),
          Text(
            _selectedPlan?.name ?? '—',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const Divider(height: 24),
          Text('${context.l10n.selectedPlants}: ${_selectedPlantIds.length}'),
          Text(
            '${context.l10n.growingTowers}: ${_selectedPlantIds.length}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );

  Widget _payment() {
    final p = widget.payment;
    if (p == null || p.qrImageUrl == null) {
      return Column(
        children: [
          _empty(
            context.l10n.paymentWaiting,
            context.l10n.paymentWaitingDetail,
            Icons.hourglass_empty_outlined,
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => setState(() => _showPayment = false),
            child: Text(context.l10n.backToPlans),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _summary(),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _status(p.status),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    p.qrImageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: AppColors.mutedSage,
                    ),
                  ),
                ),
                if (p.formattedAmount != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      p.formattedAmount!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ),
                if (p.orderReference != null)
                  Text(
                    p.orderReference!,
                    style: const TextStyle(color: AppColors.secondaryText),
                  ),
                if (p.expiryLabel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      p.expiryLabel!,
                      style: const TextStyle(color: AppColors.secondaryText),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.paymentInstructions,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.secondaryText),
        ),
      ],
    );
  }

  Widget _status(PaymentStatus status) {
    final (label, color, icon) = switch (status) {
      PaymentStatus.pending => (
        context.l10n.paymentPending,
        AppColors.mutedSage,
        Icons.schedule_outlined,
      ),
      PaymentStatus.succeeded => (
        context.l10n.paymentSucceeded,
        AppColors.mint,
        Icons.check_circle_outline,
      ),
      PaymentStatus.failed => (
        context.l10n.paymentFailed,
        AppColors.danger,
        Icons.error_outline,
      ),
      PaymentStatus.expired => (
        context.l10n.paymentExpired,
        AppColors.danger,
        Icons.timer_off_outlined,
      ),
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _PlantOption {
  const _PlantOption(this.id, this.name, this.variety, this.icon);
  final String id;
  final String name;
  final String variety;
  final IconData icon;
}
