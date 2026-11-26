import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
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
  final _cropName = TextEditingController();
  List<Device> _devices = const [];
  Device? _selectedDevice;
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
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _cropName.dispose();
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

  Future<void> _createPayment() async {
    final device = _selectedDevice;
    final cropName = _cropName.text.trim();
    if (device == null || cropName.isEmpty) {
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
      _startStatusPolling();
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.subscriptionCreateFailed);
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  void _startStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => unawaited(_refreshStatus()),
    );
  }

  Future<void> _refreshStatus() async {
    final payment = _payment;
    if (payment == null || _refreshing || payment.subscription.isActive) return;
    setState(() => _refreshing = true);
    try {
      final subscriptions = await _apiService.getSubscriptions();
      final matches = subscriptions.where(
        (item) => item.id == payment.subscription.id,
      );
      if (!mounted || matches.isEmpty) return;
      final subscription = matches.single;
      setState(() {
        _payment = CropSubscriptionPayment(
          subscription: subscription,
          bankCode: payment.bankCode,
          accountNumber: payment.accountNumber,
          accountName: payment.accountName,
        );
      });
      if (subscription.isActive) _statusTimer?.cancel();
    } catch (_) {
      // Keep the issued payment reference visible through a transient failure.
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(context.l10n.subscription),
    ),
    body: SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            child: _payment == null ? _form() : _paymentDetails(),
          ),
        ),
      ),
    ),
  );

  Widget _form() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.subscriptionRealPaymentNotice,
        style: const TextStyle(color: AppColors.secondaryText),
      ),
      const SizedBox(height: 20),
      if (_loadingDevices)
        const Center(
          child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
        )
      else if (_devices.isEmpty)
        _messageCard(context.l10n.subscriptionNoDevices)
      else ...[
        Text(context.l10n.subscriptionDeviceLabel, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<Device>(
          value: _selectedDevice,
          isExpanded: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: _devices
              .map((device) => DropdownMenuItem(value: device, child: Text(device.name)))
              .toList(),
          onChanged: (device) => setState(() => _selectedDevice = device),
        ),
        const SizedBox(height: 18),
        Text(context.l10n.subscriptionCropLabel, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _cropName,
          maxLength: 100,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: context.l10n.subscriptionCropHint,
          ),
          onSubmitted: (_) => _createPayment(),
        ),
        Text(
          context.l10n.subscriptionPriceFromServer,
          style: const TextStyle(color: AppColors.mutedSage, fontSize: 13),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _creating ? null : _createPayment,
            icon: _creating
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.qr_code_2_outlined),
            label: Text(context.l10n.continueToPayment),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
      if (_error != null) ...[
        const SizedBox(height: 16),
        _messageCard(_error!, isError: true),
        if (!_loadingDevices)
          TextButton(onPressed: _loadDevices, child: Text(context.l10n.retry)),
      ],
    ],
  );

  Widget _paymentDetails() {
    final payment = _payment!;
    final subscription = payment.subscription;
    final expired = subscription.isPending && !subscription.paymentExpiresAt.isAfter(DateTime.now().toUtc());
    final status = subscription.isActive
        ? context.l10n.paymentSucceeded
        : expired
        ? context.l10n.paymentExpired
        : context.l10n.paymentPending;
    final qrUri = Uri.https(
      'img.vietqr.io',
      '/image/${payment.bankCode}-${payment.accountNumber}-compact2.png',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      errorBuilder: (_, __, ___) => _messageCard(
                        context.l10n.subscriptionQrLoadFailed,
                        isError: true,
                      ),
                    ),
                  ),
                if (!subscription.isActive && !expired) const SizedBox(height: 16),
                Text(_money(subscription.amountVnd), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.forestGreen)),
                const SizedBox(height: 16),
                _paymentRow(context.l10n.subscriptionBankLabel, payment.bankCode),
                _paymentRow(context.l10n.subscriptionAccountLabel, payment.accountNumber),
                _paymentRow(context.l10n.subscriptionAccountNameLabel, payment.accountName),
                _paymentRow(context.l10n.subscriptionTransferContentLabel, subscription.paymentCode),
                _paymentRow(context.l10n.subscriptionExpiryLabel, _dateTime(subscription.paymentExpiresAt)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(context.l10n.paymentInstructions, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.secondaryText)),
        const SizedBox(height: 16),
        if (!subscription.isActive && !expired)
          OutlinedButton.icon(
            onPressed: _refreshing ? null : _refreshStatus,
            icon: _refreshing
                ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
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
        Expanded(child: Text(label, style: const TextStyle(color: AppColors.secondaryText))),
        const SizedBox(width: 16),
        Flexible(child: SelectableText(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700))),
      ],
    ),
  );

  Widget _statusCard(String text, bool success, bool expired) => Card(
    color: AppColors.mintChip,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(success ? Icons.check_circle_outline : expired ? Icons.schedule_outlined : Icons.hourglass_top, color: AppColors.forestGreen),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    ),
  );

  Widget _messageCard(String message, {bool isError = false}) => Card(
    color: isError ? Theme.of(context).colorScheme.errorContainer : AppColors.surface,
    child: Padding(padding: const EdgeInsets.all(14), child: Text(message)),
  );

  String _money(int amount) => '${amount.toString().replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (_) => '.')} đ';

  String _dateTime(DateTime value) {
    final local = value.toLocal();
    return '${MaterialLocalizations.of(context).formatMediumDate(local)} ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
  }
}
