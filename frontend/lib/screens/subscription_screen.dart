import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/page_header.dart';
import '../models/crop_subscription.dart';
import '../models/device.dart';
import '../services/api_service.dart';
import '../utils/l10n.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key, ApiService? apiService})
    : _apiService = apiService;

  final ApiService? _apiService;

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late final ApiService _apiService = widget._apiService ?? ApiService();
  List<Device> _devices = const [];
  List<CropSubscription> _subscriptions = const [];
  Device? _selectedDevice;
  String? _selectedCropName;
  CropSubscriptionPayment? _payment;
  Timer? _statusTimer;
  bool _loadingDevices = true;
  bool _creating = false;
  bool _refreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDevices());
    unawaited(_loadSubscriptions());
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _loadingDevices = true;
      _error = null;
    });
    try {
      final devices = (await _apiService.getDevices())
          .map((item) => Device.fromJson(item as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() {
        _devices = devices;
        _selectedDevice = devices.isEmpty ? null : devices.first;
      });
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.subscriptionLoadFailed);
    } finally {
      if (mounted) setState(() => _loadingDevices = false);
    }
  }

  Future<void> _loadSubscriptions() async {
    try {
      final subscriptions = await _apiService.getSubscriptions();
      if (!mounted) return;
      setState(() => _subscriptions = subscriptions);
    } catch (_) {
      // Keep checkout usable if history cannot be loaded.
    }
  }

  Future<void> _createPayment() async {
    final device = _selectedDevice;
    final cropName = _selectedCropName;
    if (device == null || cropName == null) {
      setState(() => _error = context.l10n.subscriptionFormRequired);
      return;
    }
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final payment = await _apiService.createCropSubscription(
        deviceId: device.id,
        cropName: cropName,
      );
      if (!mounted) return;
      setState(() => _payment = payment);
      unawaited(_loadSubscriptions());
      _startStatusPolling();
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.l10n.subscriptionCreateFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
  }

  bool _isTerminal(CropSubscription subscription) =>
      subscription.isActive ||
      (subscription.isPending &&
          !subscription.paymentExpiresAt.isAfter(DateTime.now().toUtc())) ||
      subscription.status == 'Expired';

  void _startStatusPolling() {
    _statusTimer?.cancel();
    final payment = _payment;
    if (payment == null || _isTerminal(payment.subscription)) return;
    _statusTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => unawaited(_refreshStatus()),
    );
  }

  Future<void> _refreshStatus() async {
    final payment = _payment;
    if (payment == null || _refreshing || _isTerminal(payment.subscription)) {
      _statusTimer?.cancel();
      return;
    }
    setState(() => _refreshing = true);
    try {
      final subscriptions = await _apiService.getSubscriptions();
      final matches = subscriptions.where(
        (item) => item.id == payment.subscription.id,
      );
      if (!mounted || matches.isEmpty) return;
      final subscription = matches.single;
      setState(() {
        _subscriptions = subscriptions;
        _payment = CropSubscriptionPayment(
          subscription: subscription,
          bankCode: payment.bankCode,
          accountNumber: payment.accountNumber,
          accountName: payment.accountName,
        );
      });
      if (_isTerminal(subscription)) {
        _statusTimer?.cancel();
      }
    } catch (_) {
      // Keep the issued payment reference visible through a transient failure.
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: PageHeader(
                    title: context.l10n.subscription,
                    subtitle: context.l10n.paymentSubtitle,
                  ),
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _payment == null ? _form() : _paymentDetails(),
                        const SizedBox(height: 24),
                        _history(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _history() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.subscriptionHistory,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryText,
        ),
      ),
      const SizedBox(height: 12),
      if (_subscriptions.isEmpty)
        _messageCard(context.l10n.subscriptionHistoryEmpty)
      else
        Card(
          margin: EdgeInsets.zero,
          color: AppColors.surface,
          child: Column(
            children: _subscriptions
                .map(
                  (subscription) => ListTile(
                    title: Text(subscription.cropName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_money(subscription.amountVnd)),
                        Text(_subscriptionStatusLabel(subscription)),
                        Text(
                          '${_historyDateLabel(subscription)}: ${_dateTime(_historyDate(subscription))}',
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                )
                .toList(),
          ),
        ),
    ],
  );

  String _subscriptionStatusLabel(CropSubscription subscription) =>
      switch (subscription.status) {
        'Pending' => context.l10n.subscriptionStatusPending,
        'Active' => context.l10n.subscriptionStatusActive,
        'Expired' => context.l10n.subscriptionStatusExpired,
        _ => subscription.status,
      };

  String _historyDateLabel(CropSubscription subscription) =>
      subscription.isActive
      ? context.l10n.subscriptionPaidAt
      : subscription.isPending
      ? context.l10n.subscriptionExpiryLabel
      : context.l10n.subscriptionCreatedAt;

  DateTime _historyDate(CropSubscription subscription) => subscription.isActive
      ? subscription.paidAt ?? subscription.createdAt
      : subscription.isPending
      ? subscription.paymentExpiresAt
      : subscription.createdAt;

  Widget _form() => Card(
    margin: EdgeInsets.zero,
    color: AppColors.surface,
    elevation: 3,
    shadowColor: AppColors.primaryText.withValues(alpha: .18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.mintChip,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.forestGreen,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.subscriptionRealPaymentNotice,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_loadingDevices)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_devices.isEmpty)
            _messageCard(context.l10n.subscriptionNoDevices)
          else ...[
            _fieldLabel(context.l10n.subscriptionDeviceLabel),
            const SizedBox(height: 8),
            DropdownButtonFormField<Device>(
              initialValue: _selectedDevice,
              isExpanded: true,
              decoration: _fieldDecoration(),
              items: _devices
                  .map(
                    (device) => DropdownMenuItem(
                      value: device,
                      child: Text(device.name),
                    ),
                  )
                  .toList(),
              onChanged: (device) => setState(() => _selectedDevice = device),
            ),
            const SizedBox(height: 20),
            _fieldLabel(context.l10n.subscriptionCropLabel),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedCropName,
              isExpanded: true,
              decoration: _fieldDecoration(
                hintText: context.l10n.subscriptionCropHint,
              ),
              items: [
                DropdownMenuItem(
                  value: context.l10n.demoPlantButterhead,
                  child: Text(context.l10n.demoPlantButterhead),
                ),
                DropdownMenuItem(
                  value: context.l10n.demoPlantGenovese,
                  child: Text(context.l10n.demoPlantGenovese),
                ),
                DropdownMenuItem(
                  value: context.l10n.demoPlantBabyLeaf,
                  child: Text(context.l10n.demoPlantBabyLeaf),
                ),
                DropdownMenuItem(
                  value: context.l10n.demoPlantSpearmint,
                  child: Text(context.l10n.demoPlantSpearmint),
                ),
                DropdownMenuItem(
                  value: context.l10n.demoPlantTuscan,
                  child: Text(context.l10n.demoPlantTuscan),
                ),
                DropdownMenuItem(
                  value: context.l10n.demoPlantSlowBolt,
                  child: Text(context.l10n.demoPlantSlowBolt),
                ),
              ],
              onChanged: (cropName) =>
                  setState(() => _selectedCropName = cropName),
            ),
            const SizedBox(height: 10),
            Text(
              context.l10n.subscriptionPriceFromServer,
              style: const TextStyle(color: AppColors.mutedSage, fontSize: 13),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _creating ? null : _createPayment,
                icon: _creating
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.qr_code_2_outlined),
                label: Text(context.l10n.continueToPayment),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            _messageCard(_error!, isError: true),
            if (!_loadingDevices)
              TextButton(
                onPressed: _loadDevices,
                child: Text(context.l10n.retry),
              ),
          ],
        ],
      ),
    ),
  );

  Widget _fieldLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryText,
    ),
  );

  InputDecoration _fieldDecoration({String? hintText}) => InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: AppColors.rowBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.paleSageAccent),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.forestGreen, width: 1.5),
    ),
  );

  Widget _paymentDetails() {
    final payment = _payment!;
    final subscription = payment.subscription;
    final expired =
        subscription.isPending &&
        !subscription.paymentExpiresAt.isAfter(DateTime.now().toUtc());
    final status = subscription.isActive
        ? context.l10n.paymentSucceeded
        : expired
        ? context.l10n.paymentExpired
        : context.l10n.paymentPending;
    final qrUri = Uri.https(
      'img.vietqr.io',
      '/image/${payment.bankCode}-${payment.accountNumber}-compact2.svg',
      {
        'amount': subscription.amountVnd.toString(),
        'addInfo': subscription.paymentCode,
        'accountName': payment.accountName,
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _statusCard(status, subscription.isActive, expired),
        const SizedBox(height: 16),
        Card(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (!subscription.isActive && !expired)
                  LayoutBuilder(
                    builder: (context, constraints) => Image.network(
                      qrUri.toString(),
                      height: constraints.maxWidth,
                      width: constraints.maxWidth,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) =>
                          loadingProgress == null
                          ? child
                          : const SizedBox.square(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.qr_code_2_outlined,
                        size: 120,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ),
                if (!subscription.isActive && !expired)
                  const SizedBox(height: 16),
                Text(
                  _money(subscription.amountVnd),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestGreen,
                  ),
                ),
                const SizedBox(height: 16),
                _paymentRow(
                  context.l10n.subscriptionBankLabel,
                  payment.bankCode,
                ),
                _paymentRow(
                  context.l10n.subscriptionAccountLabel,
                  payment.accountNumber,
                ),
                _paymentRow(
                  context.l10n.subscriptionAccountNameLabel,
                  payment.accountName,
                ),
                _paymentRow(
                  context.l10n.subscriptionTransferContentLabel,
                  subscription.paymentCode,
                ),
                _paymentRow(
                  context.l10n.subscriptionExpiryLabel,
                  _dateTime(subscription.paymentExpiresAt),
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
        const SizedBox(height: 16),
        if (!_isTerminal(subscription))
          OutlinedButton.icon(
            onPressed: _refreshing ? null : _refreshStatus,
            icon: _refreshing
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(context.l10n.subscriptionRefreshStatus),
          ),
        TextButton(
          onPressed: () {
            _statusTimer?.cancel();
            setState(() => _payment = null);
          },
          child: Text(context.l10n.backToPlans),
        ),
      ],
    );
  }

  Widget _paymentRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.secondaryText),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: SelectableText(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  Widget _statusCard(String text, bool success, bool expired) => Card(
    color: AppColors.mintChip,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(
            success
                ? Icons.check_circle_outline
                : expired
                ? Icons.schedule_outlined
                : Icons.hourglass_top,
            color: AppColors.forestGreen,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _messageCard(String message, {bool isError = false}) => Card(
    color: isError
        ? Theme.of(context).colorScheme.errorContainer
        : AppColors.surface,
    child: Padding(padding: const EdgeInsets.all(14), child: Text(message)),
  );

  String _money(int amount) =>
      '${amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')} đ';

  String _dateTime(DateTime value) {
    final local = value.toLocal();
    return '${MaterialLocalizations.of(context).formatMediumDate(local)} ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
  }
}
