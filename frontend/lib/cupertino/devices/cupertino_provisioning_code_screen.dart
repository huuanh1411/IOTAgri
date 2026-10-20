import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../constants/api_constants.dart';
import '../../models/device.dart';
import '../../models/provisioning_code.dart';
import '../../services/api_service.dart';
import '../../services/api_error.dart';
import '../../services/esp_provisioning_service.dart';
import '../../utils/l10n.dart';

class CupertinoProvisioningCodeScreen extends StatefulWidget {
  final Device device;
  final ApiService? apiService;
  final EspProvisioningService? espProvisioningService;

  const CupertinoProvisioningCodeScreen({
    super.key,
    required this.device,
    this.apiService,
    this.espProvisioningService,
  });

  @override
  State<CupertinoProvisioningCodeScreen> createState() =>
      _CupertinoProvisioningCodeScreenState();
}

class _CupertinoProvisioningCodeScreenState
    extends State<CupertinoProvisioningCodeScreen> {
  late final ApiService _apiService;
  late final EspProvisioningService _espProvisioningService;
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  ProvisioningCode? _provisioningCode;
  List<EspWifiNetwork> _networks = const [];
  bool _isLoading = true;
  bool _isCopied = false;
  bool _isCheckingEsp = false;
  bool _isProvisioning = false;
  bool _provisioned = false;
  String Function()? _errorMessage;
  String Function()? _espMessage;
  String? _espHardwareId;
  Timer? _expiryTimer;
  int _onlineCheckGeneration = 0;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _espProvisioningService =
        widget.espProvisioningService ?? EspProvisioningService();
    _generateCode();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _onlineCheckGeneration++;
    _provisioningCode = null;
    _passwordController.clear();
    _ssidController.dispose();
    _passwordController.dispose();
    _espProvisioningService.close();
    super.dispose();
  }

  Future<void> _generateCode() async {
    if (_isLoading && _provisioningCode != null) return;
    _expiryTimer?.cancel();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isCopied = false;
      _provisioned = false;
    });
    try {
      final response = await _apiService.createProvisioningCode(
        widget.device.id,
      );
      if (!mounted) return;
      final provisioningCode = ProvisioningCode.fromJson(response);
      if (provisioningCode.code.trim().isEmpty) {
        throw const ApiError(
          kind: ApiErrorKind.malformed,
          message: 'Provisioning response did not contain a code.',
        );
      }
      setState(() {
        _provisioningCode = provisioningCode;
        _isLoading = false;
      });
      _expiryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } catch (error) {
      if (!mounted) return;
      final apiError = ApiError.from(error);
      setState(() {
        _provisioningCode = null;
        _errorMessage = () => _apiErrorMessage(apiError);
        _isLoading = false;
      });
    }
  }

  Future<void> _checkEsp() async {
    setState(() {
      _isCheckingEsp = true;
      _espMessage = null;
    });
    try {
      final status = await _espProvisioningService.getStatus();
      final networks = await _espProvisioningService.scanNetworks();
      if (!mounted) return;
      setState(() {
        _espHardwareId = status.hardwareId;
        _networks = networks;
        _isCheckingEsp = false;
        _espMessage = () => networks.isEmpty
            ? context.l10n.espFoundNoNetworks
            : context.l10n.espConnectedChooseNetwork;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isCheckingEsp = false;
        _espMessage = () => context.l10n.espConnectionFailed;
      });
    }
  }

  Future<void> _provisionEsp(String claimCode) async {
    if (_isExpired) {
      setState(() => _espMessage = () => context.l10n.provisioningCodeExpired);
      return;
    }
    final ssid = _ssidController.text.trim();
    if (ssid.isEmpty) {
      setState(() => _espMessage = () => context.l10n.wifiSsidRequired);
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _espMessage = () => context.l10n.wifiPasswordRequired);
      return;
    }

    setState(() {
      _isProvisioning = true;
      _espMessage = () => context.l10n.espSendingConfiguration;
    });
    try {
      await _espProvisioningService.provision(
        ssid: ssid,
        password: _passwordController.text,
        backendUrl: ApiConstants.deviceApiBaseUrl,
        claimCode: claimCode,
      );
      if (!mounted) return;
      setState(() {
        _isProvisioning = false;
        _provisioned = true;
        _espMessage = () => context.l10n.provisioningAcceptedWaiting;
      });
      await _waitForBackendOnline();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isProvisioning = false;
        _provisioningCode = null;
        _espMessage = () => context.l10n.provisioningOutcomeUnknown;
      });
    }
  }

  Future<void> _copy(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    setState(() => _isCopied = true);
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        content: Text(context.l10n.copiedLabel(label)),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.dismiss),
          ),
        ],
      ),
    );
  }

  String _expirationLabel() {
    final expiresAt = DateTime.tryParse(_provisioningCode?.expiresAt ?? '');
    if (expiresAt == null) return context.l10n.setupCodeValidity;
    final remaining = expiresAt.difference(DateTime.now().toUtc());
    if (remaining.isNegative) return context.l10n.setupCodeExpired;
    if (remaining.inMinutes == 0) {
      return context.l10n.setupCodeSecondsRemaining(
        (remaining.inSeconds).toString(),
      );
    }
    return context.l10n.setupCodeExpiresAt(
      (DateFormat('HH:mm').format(expiresAt.toLocal())).toString(),
    );
  }

  bool get _isExpired {
    final expiresAt = DateTime.tryParse(_provisioningCode?.expiresAt ?? '');
    return expiresAt != null && !expiresAt.isAfter(DateTime.now().toUtc());
  }

  String _apiErrorMessage(ApiError error) => switch (error.kind) {
    ApiErrorKind.timeout || ApiErrorKind.network => context.l10n.networkError,
    ApiErrorKind.authentication => context.l10n.sessionExpired,
    ApiErrorKind.authorization => context.l10n.deviceActionForbidden,
    ApiErrorKind.rateLimited => context.l10n.tooManyRequests,
    ApiErrorKind.server => context.l10n.serverUnavailable,
    ApiErrorKind.malformed => context.l10n.malformedProvisioningResponse,
    _ => context.l10n.provisioningCodeRequestFailed,
  };

  Future<void> _waitForBackendOnline() async {
    final generation = ++_onlineCheckGeneration;
    for (var attempt = 0; attempt < 10; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 3));
      if (!mounted || generation != _onlineCheckGeneration) return;
      try {
        final response = await _apiService.getDevice(widget.device.id);
        if (response['isOnline'] == true) {
          setState(
            () => _espMessage = () => context.l10n.deviceOnlineConfirmed,
          );
          return;
        }
      } catch (_) {
        // A transient status read must not change the claim outcome.
      }
    }
    if (mounted && generation == _onlineCheckGeneration) {
      setState(() => _espMessage = () => context.l10n.deviceOnlineNotConfirmed);
    }
  }

  Future<void> _confirmRegenerate() async {
    final regenerate = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(context.l10n.regenerateCodeTitle),
        content: Text(context.l10n.regenerateCodeWarning),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.generateNewCode),
          ),
        ],
      ),
    );
    if (regenerate == true && mounted) await _generateCode();
  }

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(
      middle: Text(context.l10n.deviceSetup),
    ),
    child: SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth > 600 ? 480 : double.infinity,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 320,
                      child: Center(
                        child: CupertinoActivityIndicator(radius: 14),
                      ),
                    )
                  : _errorMessage != null
                  ? _ProvisioningError(
                      message: _errorMessage!(),
                      onRetry: _generateCode,
                    )
                  : _buildCodeContent(context),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildCodeContent(BuildContext context) {
    final code = _provisioningCode;
    if (code == null) {
      return _ProvisioningError(
        message: context.l10n.setupCodeMissing,
        onRetry: _generateCode,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(CupertinoIcons.qrcode, color: Color(0xFF248A4B), size: 48),
        const SizedBox(height: 14),
        Text(
          widget.device.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CupertinoColors.label.resolveFrom(context),
            fontSize: 23,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Device ID: ${widget.device.id}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: CupertinoColors.secondarySystemBackground.resolveFrom(
              context,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Text(
                code.code,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CupertinoColors.label.resolveFrom(context),
                  fontFamily: 'Inter',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _expirationLabel(),
                style: const TextStyle(
                  color: CupertinoColors.systemOrange,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: () => _copy(code.code, context.l10n.setupCodeLabel),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCopied
                          ? CupertinoIcons.checkmark
                          : CupertinoIcons.doc_on_doc,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isCopied
                          ? context.l10n.copyCodeAgain
                          : context.l10n.copySetupCode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _DirectEspSetupPanel(
          ssidController: _ssidController,
          passwordController: _passwordController,
          networks: _networks,
          hardwareId: _espHardwareId,
          message: _espMessage?.call(),
          isChecking: _isCheckingEsp,
          isProvisioning: _isProvisioning,
          provisioned: _provisioned,
          onCheckEsp: _checkEsp,
          onProvision: () => _provisionEsp(code.code),
          onNetworkSelected: (ssid) => setState(() {
            _ssidController.text = ssid;
          }),
        ),
        const SizedBox(height: 20),
        _SetupStep(number: '1', text: context.l10n.espSetupStepOne),
        _SetupStep(number: '2', text: context.l10n.espSetupStepTwo),
        _SetupStep(number: '3', text: context.l10n.espSetupStepThree),
        _SetupStep(number: '4', text: context.l10n.espSetupStepFour),
        const SizedBox(height: 12),
        Text(
          context.l10n.espBackendAddress(
            (ApiConstants.deviceApiBaseUrl).toString(),
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 18),
        CupertinoButton(
          onPressed: _confirmRegenerate,
          child: Text(context.l10n.regenerateSetupCode),
        ),
      ],
    );
  }
}

class _DirectEspSetupPanel extends StatelessWidget {
  final TextEditingController ssidController;
  final TextEditingController passwordController;
  final List<EspWifiNetwork> networks;
  final String? hardwareId;
  final String? message;
  final bool isChecking;
  final bool isProvisioning;
  final bool provisioned;
  final VoidCallback onCheckEsp;
  final VoidCallback onProvision;
  final ValueChanged<String> onNetworkSelected;

  const _DirectEspSetupPanel({
    required this.ssidController,
    required this.passwordController,
    required this.networks,
    required this.hardwareId,
    required this.message,
    required this.isChecking,
    required this.isProvisioning,
    required this.provisioned,
    required this.onCheckEsp,
    required this.onProvision,
    required this.onNetworkSelected,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.directEspSetup,
          style: TextStyle(
            color: CupertinoColors.label.resolveFrom(context),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.directEspSetupHint,
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 14),
        CupertinoButton(
          color: CupertinoColors.activeBlue,
          onPressed: isChecking || isProvisioning ? null : onCheckEsp,
          child: isChecking
              ? const CupertinoActivityIndicator(
                  color: CupertinoColors.white,
                  radius: 10,
                )
              : Text(context.l10n.checkEspConnection),
        ),
        if (hardwareId != null) ...[
          const SizedBox(height: 8),
          Text(
            context.l10n.espDetected((hardwareId).toString()),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CupertinoColors.systemGreen,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (networks.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            context.l10n.espAvailableNetworks,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: networks
                .map(
                  (network) => CupertinoButton(
                    minimumSize: const Size(30, 30),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    color: ssidController.text == network.ssid
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey5.resolveFrom(context),
                    onPressed: () => onNetworkSelected(network.ssid),
                    child: Text(
                      '${network.ssid} (${network.rssi} dBm)',
                      style: TextStyle(
                        color: ssidController.text == network.ssid
                            ? CupertinoColors.white
                            : CupertinoColors.label.resolveFrom(context),
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 14),
        CupertinoTextField(
          controller: ssidController,
          enabled: !isProvisioning,
          placeholder: context.l10n.wifiSsidHint,
          padding: const EdgeInsets.all(13),
        ),
        const SizedBox(height: 10),
        CupertinoTextField(
          controller: passwordController,
          enabled: !isProvisioning,
          placeholder: context.l10n.wifiPasswordHint,
          obscureText: true,
          padding: const EdgeInsets.all(13),
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: provisioned
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemOrange,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 14),
        CupertinoButton.filled(
          onPressed: isChecking || isProvisioning || provisioned
              ? null
              : onProvision,
          child: isProvisioning
              ? const CupertinoActivityIndicator(
                  color: CupertinoColors.white,
                  radius: 10,
                )
              : Text(
                  provisioned
                      ? context.l10n.connectedStatus
                      : context.l10n.connectEsp,
                ),
        ),
      ],
    ),
  );
}

class _SetupStep extends StatelessWidget {
  final String number;
  final String text;

  const _SetupStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 25,
          height: 25,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF248A4B),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ProvisioningError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ProvisioningError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 320,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            color: CupertinoColors.systemOrange,
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(context.l10n.provisioningCodeRequestFailed),
          const SizedBox(height: 6),
          Text(
            message,
            maxLines: 3,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: CupertinoColors.secondaryLabel,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          CupertinoButton.filled(
            onPressed: onRetry,
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    ),
  );
}
