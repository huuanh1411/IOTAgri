import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../constants/api_constants.dart';
import '../../models/device.dart';
import '../../models/provisioning_code.dart';
import '../../services/api_error.dart';
import '../../services/api_service.dart';
import '../../services/esp_provisioning_service.dart';
import '../../utils/l10n.dart';
import 'cupertino_device_detail_screen.dart';

enum _SetupStage { prepare, connect, wifi, progress, success }

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
  late final EspProvisioningService _espService;
  final _ssid = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  ProvisioningCode? _code;
  List<EspWifiNetwork> _networks = const [];
  _SetupStage _stage = _SetupStage.prepare;
  bool _loading = true;
  bool _busy = false;
  bool _obscurePassword = true;
  bool _manualNetwork = false;
  bool _sensorDataReceived = false;
  int _progress = 0;
  String Function()? _fatalError;
  String Function()? _message;
  String? _hardwareId;
  Timer? _expiryTimer;
  int _pollGeneration = 0;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _espService = widget.espProvisioningService ?? EspProvisioningService();
    _generateCode();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _pollGeneration++;
    _password.clear();
    _ssid.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    _espService.close();
    super.dispose();
  }

  Future<bool> _generateCode({bool showLoading = true}) async {
    _expiryTimer?.cancel();
    if (showLoading) {
      setState(() {
        _loading = true;
        _fatalError = null;
      });
    }
    try {
      final json = await _apiService.createProvisioningCode(widget.device.id);
      if (!mounted) return false;
      final code = ProvisioningCode.fromJson(json);
      if (code.code.trim().isEmpty) {
        throw const ApiError(
          kind: ApiErrorKind.malformed,
          message: 'Provisioning response did not contain a code.',
        );
      }
      setState(() {
        _code = code;
        _loading = false;
        _fatalError = null;
      });
      _expiryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
      return true;
    } catch (error) {
      if (!mounted) return false;
      final apiError = ApiError.from(error);
      setState(() {
        _code = null;
        _loading = false;
        _fatalError = () => _apiErrorText(apiError);
      });
      return false;
    }
  }

  Future<void> _connectToEsp() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final status = await _espService.getStatus();
      final networks = await _espService.scanNetworks();
      if (!mounted) return;
      setState(() {
        _hardwareId = status.hardwareId;
        _networks = networks;
        _busy = false;
        _stage = _SetupStage.wifi;
        _message = networks.isEmpty
            ? () => context.l10n.espFoundNoNetworks
            : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = () => context.l10n.espNotFoundRecovery;
      });
    }
  }

  Future<void> _setUpDevice() async {
    if (_ssid.text.trim().isEmpty) {
      setState(() => _message = () => context.l10n.wifiSsidRequired);
      return;
    }
    if (_password.text.isEmpty) {
      setState(() => _message = () => context.l10n.wifiPasswordRequired);
      _passwordFocus.requestFocus();
      return;
    }
    if (_isExpired || _code == null) {
      setState(() {
        _busy = true;
        _message = () => context.l10n.expiredCodeRegenerating;
      });
      final generated = await _generateCode(showLoading: false);
      if (!mounted) return;
      setState(() {
        _busy = false;
        if (generated) _message = () => context.l10n.expiredCodeRegenerated;
      });
      if (!generated) return;
    }

    setState(() {
      _busy = true;
      _stage = _SetupStage.progress;
      _progress = 1;
      _message = null;
    });
    try {
      await _espService.provision(
        ssid: _ssid.text.trim(),
        password: _password.text,
        backendUrl: ApiConstants.deviceApiBaseUrl,
        claimCode: _code!.code,
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _progress = 3;
        _message = () => context.l10n.deviceSwitchingNetwork;
      });
      await _waitForBackendOnline();
    } on EspProvisioningException catch (error) {
      if (!mounted) return;
      if (error.failure == EspProvisioningFailure.networkUnavailable) {
        _returnToWifi(() => context.l10n.incompatibleWifiNetwork);
      } else if (error.failure == EspProvisioningFailure.wifiCredentials) {
        _returnToWifi(() => context.l10n.incorrectWifiPassword);
        _passwordFocus.requestFocus();
      } else if (error.failure == EspProvisioningFailure.claimRejected) {
        setState(() {
          _stage = _SetupStage.wifi;
          _busy = true;
          _message = () => context.l10n.expiredCodeRegenerating;
        });
        final generated = await _generateCode(showLoading: false);
        if (!mounted) return;
        setState(() {
          _busy = false;
          if (generated) _message = () => context.l10n.expiredCodeRegenerated;
        });
      } else if (error.failure == EspProvisioningFailure.persistence) {
        _returnToWifi(() => context.l10n.espCouldNotSaveConfiguration);
      } else {
        await _checkUncertainOutcome();
      }
    } catch (_) {
      if (mounted) await _checkUncertainOutcome();
    }
  }

  void _returnToWifi(String Function() message) => setState(() {
    _stage = _SetupStage.wifi;
    _busy = false;
    _message = message;
  });

  Future<void> _checkUncertainOutcome() async {
    setState(() {
      _busy = false;
      _progress = 2;
      _message = () => context.l10n.provisioningOutcomeChecking;
    });
    await _waitForBackendOnline();
  }

  Future<void> _waitForBackendOnline() async {
    final generation = ++_pollGeneration;
    for (var attempt = 0; attempt < 20; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 3));
      if (!mounted || generation != _pollGeneration) return;
      try {
        final response = await _apiService.getDevice(widget.device.id);
        if (response['isOnline'] == true) {
          final readings = await _apiService.getDeviceReadings(
            widget.device.id,
            limit: 1,
          );
          if (!mounted || generation != _pollGeneration) return;
          setState(() {
            _progress = 5;
            _sensorDataReceived = readings.isNotEmpty;
            _stage = _SetupStage.success;
            _message = null;
          });
          return;
        }
        if (attempt >= 2 && mounted) setState(() => _progress = 4);
      } catch (_) {
        // The ESP's local HTTP connection normally disappears during handoff.
      }
    }
    if (mounted && generation == _pollGeneration) {
      setState(() {
        _busy = false;
        _message = () => context.l10n.deviceWifiButNotOnline;
      });
    }
  }

  void _goBack() => setState(() {
    _message = null;
    if (_stage == _SetupStage.connect) _stage = _SetupStage.prepare;
    if (_stage == _SetupStage.wifi) _stage = _SetupStage.connect;
  });

  void _viewDevice() => Navigator.of(context).pushReplacement<void, void>(
    CupertinoPageRoute<void>(
      builder: (_) => CupertinoDeviceDetailScreen(
        device: widget.device,
        apiService: _apiService,
      ),
    ),
  );

  bool get _isExpired {
    final expiresAt = DateTime.tryParse(_code?.expiresAt ?? '');
    return expiresAt != null && !expiresAt.isAfter(DateTime.now().toUtc());
  }

  String _apiErrorText(ApiError error) => switch (error.kind) {
    ApiErrorKind.timeout || ApiErrorKind.network => context.l10n.networkError,
    ApiErrorKind.authentication => context.l10n.sessionExpired,
    ApiErrorKind.authorization => context.l10n.deviceActionForbidden,
    ApiErrorKind.rateLimited => context.l10n.tooManyRequests,
    ApiErrorKind.server => context.l10n.serverUnavailable,
    ApiErrorKind.malformed => context.l10n.malformedProvisioningResponse,
    _ => context.l10n.provisioningCodeRequestFailed,
  };

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
              child: _loading
                  ? const SizedBox(
                      height: 320,
                      child: Center(child: CupertinoActivityIndicator()),
                    )
                  : _fatalError != null
                  ? _ProvisioningError(
                      message: _fatalError!(),
                      onRetry: _generateCode,
                    )
                  : _buildWizard(),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildWizard() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _StepHeader(stage: _stage),
      const SizedBox(height: 24),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: KeyedSubtree(
          key: ValueKey(_stage),
          child: switch (_stage) {
            _SetupStage.prepare => _prepareStep(),
            _SetupStage.connect => _connectStep(),
            _SetupStage.wifi => _wifiStep(),
            _SetupStage.progress => _progressStep(),
            _SetupStage.success => _successStep(),
          },
        ),
      ),
    ],
  );

  Widget _prepareStep() => _StepCard(
    icon: CupertinoIcons.power,
    title: context.l10n.prepareDeviceTitle,
    children: [
      _Instruction(text: context.l10n.prepareDevicePower),
      _Instruction(text: context.l10n.prepareDeviceWaitForNetwork),
      _Instruction(text: context.l10n.noInternetIsNormal),
      const SizedBox(height: 16),
      CupertinoButton.filled(
        onPressed: () => setState(() => _stage = _SetupStage.connect),
        child: Text(context.l10n.deviceIsReady),
      ),
    ],
  );

  Widget _connectStep() => _StepCard(
    icon: CupertinoIcons.wifi,
    title: context.l10n.connectToEspTitle,
    children: [
      Text(
        context.l10n.webWifiSwitchInstructions,
        style: const TextStyle(height: 1.4),
      ),
      const SizedBox(height: 12),
      _InfoBanner(text: context.l10n.noInternetIsNormal),
      if (_message != null) ...[
        const SizedBox(height: 12),
        _MessageBanner(text: _message!()),
      ],
      const SizedBox(height: 18),
      CupertinoButton.filled(
        onPressed: _busy ? null : _connectToEsp,
        child: _busy
            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
            : Text(context.l10n.connectToEspAction),
      ),
      _BackButton(onPressed: _goBack),
    ],
  );

  Widget _wifiStep() => _StepCard(
    icon: CupertinoIcons.wifi,
    title: context.l10n.selectWifiTitle,
    children: [
      if (_hardwareId != null) ...[
        _FoundDevice(hardwareId: _hardwareId!),
        const SizedBox(height: 12),
      ],
      if (_networks.isNotEmpty && !_manualNetwork)
        ..._networks.map(
          (network) => _NetworkTile(
            network: network,
            selected: _ssid.text == network.ssid,
            onPressed: () => setState(() {
              _ssid.text = network.ssid;
              _message = null;
            }),
          ),
        ),
      CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 10),
        onPressed: () => setState(() => _manualNetwork = !_manualNetwork),
        child: Text(
          _manualNetwork
              ? context.l10n.chooseScannedNetwork
              : context.l10n.enterAnotherNetwork,
        ),
      ),
      if (_manualNetwork || _networks.isEmpty) ...[
        CupertinoTextField(
          controller: _ssid,
          enabled: !_busy,
          placeholder: context.l10n.wifiSsidHint,
          padding: const EdgeInsets.all(13),
        ),
        const SizedBox(height: 8),
        _InfoBanner(text: context.l10n.manualWifiCompatibilityWarning),
      ],
      const SizedBox(height: 12),
      CupertinoTextField(
        controller: _password,
        focusNode: _passwordFocus,
        enabled: !_busy,
        placeholder: context.l10n.wifiPasswordHint,
        obscureText: _obscurePassword,
        padding: const EdgeInsets.all(13),
        suffix: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: Size.zero,
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
            size: 20,
          ),
        ),
      ),
      if (_message != null) ...[
        const SizedBox(height: 12),
        _MessageBanner(text: _message!()),
      ],
      const SizedBox(height: 18),
      CupertinoButton.filled(
        onPressed: _busy ? null : _setUpDevice,
        child: _busy
            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
            : Text(context.l10n.setUpDeviceAction),
      ),
      _BackButton(onPressed: _goBack),
      const SizedBox(height: 8),
      _TechnicalInformation(code: _code, hardwareId: _hardwareId),
    ],
  );

  Widget _progressStep() => _StepCard(
    icon: CupertinoIcons.gear_alt_fill,
    title: context.l10n.settingUpDeviceTitle,
    children: [
      _ProgressRow(
        label: context.l10n.progressEspConnected,
        state: 0,
        current: _progress,
      ),
      _ProgressRow(
        label: context.l10n.progressCredentialsSent,
        state: 1,
        current: _progress,
      ),
      _ProgressRow(
        label: context.l10n.progressConnectingWifi(_ssid.text),
        state: 2,
        current: _progress,
      ),
      _ProgressRow(
        label: context.l10n.progressRegisteringServer,
        state: 3,
        current: _progress,
      ),
      _ProgressRow(
        label: context.l10n.progressConnectingMqtt,
        state: 4,
        current: _progress,
      ),
      if (_message != null) ...[
        const SizedBox(height: 18),
        _InfoBanner(text: _message!()),
      ],
    ],
  );

  Widget _successStep() => _StepCard(
    icon: CupertinoIcons.checkmark_circle_fill,
    iconColor: CupertinoColors.systemGreen,
    title: context.l10n.espConnectedSuccessfully,
    children: [
      _SummaryRow(label: context.l10n.wifiLabel, value: _ssid.text),
      _SummaryRow(
        label: context.l10n.statusLabel,
        value: context.l10n.onlineStatus,
      ),
      _SummaryRow(
        label: context.l10n.sensorDataLabel,
        value: _sensorDataReceived
            ? context.l10n.sensorDataReceivedStatus
            : context.l10n.sensorDataWaitingStatus,
      ),
      const SizedBox(height: 18),
      CupertinoButton.filled(
        onPressed: _viewDevice,
        child: Text(context.l10n.viewDeviceAction),
      ),
    ],
  );
}

class _StepHeader extends StatelessWidget {
  final _SetupStage stage;
  const _StepHeader({required this.stage});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        context.l10n.setupStepProgress(
          stage.index + 1,
          _SetupStage.values.length,
        ),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      Row(
        children: List.generate(
          _SetupStage.values.length,
          (index) => Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
              decoration: BoxDecoration(
                color: index <= stage.index
                    ? const Color(0xFF248A4B)
                    : CupertinoColors.systemGrey5.resolveFrom(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _StepCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;
  const _StepCard({
    required this.icon,
    this.iconColor = const Color(0xFF248A4B),
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(icon, color: iconColor, size: 42),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    ),
  );
}

class _Instruction extends StatelessWidget {
  final String text;
  const _Instruction({required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          CupertinoIcons.checkmark_circle,
          color: Color(0xFF248A4B),
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(height: 1.35))),
      ],
    ),
  );
}

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: CupertinoColors.systemBlue.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(text, style: const TextStyle(fontSize: 13, height: 1.35)),
  );
}

class _MessageBanner extends StatelessWidget {
  final String text;
  const _MessageBanner({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: CupertinoColors.systemOrange.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(text, style: const TextStyle(fontSize: 13, height: 1.35)),
  );
}

class _FoundDevice extends StatelessWidget {
  final String hardwareId;
  const _FoundDevice({required this.hardwareId});
  @override
  Widget build(BuildContext context) {
    final suffix = hardwareId.length > 4
        ? hardwareId.substring(hardwareId.length - 4)
        : hardwareId;
    return Text(
      context.l10n.deviceFoundHardware(suffix),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: CupertinoColors.systemGreen,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
    );
  }
}

class _NetworkTile extends StatelessWidget {
  final EspWifiNetwork network;
  final bool selected;
  final VoidCallback onPressed;
  const _NetworkTile({
    required this.network,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => CupertinoButton(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    onPressed: onPressed,
    child: Row(
      children: [
        Icon(
          selected
              ? CupertinoIcons.checkmark_circle_fill
              : CupertinoIcons.circle,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            network.ssid,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Icon(
          network.rssi < -75
              ? CupertinoIcons.wifi_exclamationmark
              : CupertinoIcons.wifi,
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
          size: 19,
        ),
      ],
    ),
  );
}

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _BackButton({required this.onPressed});
  @override
  Widget build(BuildContext context) => CupertinoButton(
    onPressed: onPressed,
    child: Text(context.l10n.backAction),
  );
}

class _TechnicalInformation extends StatelessWidget {
  final ProvisioningCode? code;
  final String? hardwareId;
  const _TechnicalInformation({required this.code, required this.hardwareId});

  @override
  Widget build(BuildContext context) => CupertinoButton(
    onPressed: () => showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) => CupertinoActionSheet(
        title: Text(context.l10n.technicalInformation),
        message: Text(
          '${context.l10n.setupCodeLabel}: ${code?.code ?? '-'}\n'
          '${context.l10n.hardwareIdLabel}: ${hardwareId ?? '-'}\n'
          '${context.l10n.backendUrlLabel}: ${ApiConstants.deviceApiBaseUrl}',
        ),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(popupContext),
          child: Text(context.l10n.dismiss),
        ),
      ),
    ),
    child: Text(context.l10n.technicalInformation),
  );
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int state;
  final int current;
  const _ProgressRow({
    required this.label,
    required this.state,
    required this.current,
  });
  @override
  Widget build(BuildContext context) {
    final complete = current > state;
    final active = current == state;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(
            complete
                ? CupertinoIcons.checkmark_circle_fill
                : active
                ? CupertinoIcons.circle_filled
                : CupertinoIcons.circle,
            color: complete
                ? CupertinoColors.systemGreen
                : active
                ? CupertinoColors.activeBlue
                : CupertinoColors.systemGrey,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: CupertinoColors.secondaryLabel),
          ),
        ),
        const SizedBox(width: 16),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _ProvisioningError extends StatelessWidget {
  final String message;
  final Future<bool> Function({bool showLoading}) onRetry;
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
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          CupertinoButton.filled(
            onPressed: () => onRetry(),
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    ),
  );
}
