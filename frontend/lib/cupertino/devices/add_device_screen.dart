import 'package:flutter/cupertino.dart';

import '../../models/device.dart';
import '../../services/api_error.dart';
import '../../services/api_service.dart';
import '../../utils/l10n.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key, this.apiService});
  final ApiService? apiService;

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  late final ApiService _apiService;
  final _nameController = TextEditingController();
  bool _isSubmitting = false;
  bool _outcomeUncertain = false;
  ApiError? _error;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _isSubmitting || _outcomeUncertain) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final device = Device.fromJson(await _apiService.createDevice(name));
      if (device.id.isEmpty) throw const FormatException('Missing device id');
      if (mounted) Navigator.of(context).pop(device);
    } catch (error) {
      final apiError = ApiError.from(error);
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = apiError;
        _outcomeUncertain = apiError.outcomeMayBeUnknown;
      });
    }
  }

  String _message(BuildContext context) {
    final error = _error;
    if (error == null) return '';
    if (_outcomeUncertain) return context.l10n.deviceCreateOutcomeUnknown;
    return switch (error.kind) {
      ApiErrorKind.authentication => context.l10n.sessionExpired,
      ApiErrorKind.authorization => context.l10n.deviceActionForbidden,
      ApiErrorKind.validation => context.l10n.requestValidationFailed,
      ApiErrorKind.rateLimited => context.l10n.tooManyRequests,
      ApiErrorKind.server => context.l10n.serverUnavailable,
      _ => context.l10n.deviceCreateFailed,
    };
  }

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(
      middle: Text(context.l10n.addDevice),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
        child: Text(context.l10n.cancel),
      ),
    ),
    child: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  CupertinoIcons.device_phone_portrait,
                  size: 56,
                  color: Color(0xFF248A4B),
                ),
                const SizedBox(height: 20),
                Text(
                  context.l10n.createDeviceTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.createDeviceExplanation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: CupertinoColors.secondaryLabel),
                ),
                const SizedBox(height: 28),
                CupertinoTextField(
                  controller: _nameController,
                  enabled: !_isSubmitting && !_outcomeUncertain,
                  placeholder: context.l10n.deviceName,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _create(),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(CupertinoIcons.tag),
                  ),
                  padding: const EdgeInsets.all(14),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _message(context),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: CupertinoColors.systemRed,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                CupertinoButton.filled(
                  onPressed: _isSubmitting || _outcomeUncertain
                      ? null
                      : _create,
                  child: _isSubmitting
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                        )
                      : Text(context.l10n.createAndContinue),
                ),
                if (_outcomeUncertain) ...[
                  const SizedBox(height: 10),
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.l10n.returnToDeviceList),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
