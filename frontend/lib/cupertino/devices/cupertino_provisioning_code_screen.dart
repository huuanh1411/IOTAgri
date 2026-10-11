import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../constants/api_constants.dart';
import '../../models/device.dart';
import '../../models/provisioning_code.dart';
import '../../services/api_service.dart';
import '../../services/esp_provisioning_service.dart';

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
  String? _errorMessage;
  String? _espMessage;
  String? _espHardwareId;

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
    _ssidController.dispose();
    _passwordController.dispose();
    _espProvisioningService.close();
    super.dispose();
  }

  Future<void> _generateCode() async {
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
      setState(() {
        _provisioningCode = ProvisioningCode.fromJson(response);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
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
        _espMessage = networks.isEmpty
            ? 'Đã thấy ESP nhưng chưa tìm thấy mạng Wi-Fi 2.4 GHz.'
            : 'Đã kết nối ESP. Chọn mạng Wi-Fi bên dưới.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isCheckingEsp = false;
        _espMessage =
            'Không kết nối được ESP. Hãy nối thiết bị này vào Wi-Fi IOTAgri-Setup rồi thử lại. ($error)';
      });
    }
  }

  Future<void> _provisionEsp(String claimCode) async {
    final ssid = _ssidController.text.trim();
    if (ssid.isEmpty) {
      setState(
        () => _espMessage = 'Vui lòng nhập hoặc chọn tên Wi-Fi 2.4 GHz.',
      );
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _espMessage = 'Vui lòng nhập mật khẩu Wi-Fi.');
      return;
    }

    setState(() {
      _isProvisioning = true;
      _espMessage = 'Đang gửi cấu hình trực tiếp tới ESP...';
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
        _espMessage =
            'Thiết lập thành công. ESP đang khởi động lại; hãy kết nối lại Wi-Fi $ssid.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isProvisioning = false;
        _espMessage = error.toString();
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
        content: Text('$label đã sao chép.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  String _expirationLabel() {
    final expiresAt = DateTime.tryParse(_provisioningCode?.expiresAt ?? '');
    if (expiresAt == null) return 'Có hiệu lực trong 15 phút';
    final remaining = expiresAt.difference(DateTime.now().toUtc());
    if (remaining.isNegative) return 'Mã đã hết hạn';
    if (remaining.inMinutes == 0) return 'Còn ${remaining.inSeconds} giây';
    return 'Hết hạn lúc ${DateFormat('HH:mm').format(expiresAt.toLocal())}';
  }

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    navigationBar: const CupertinoNavigationBar(
      middle: Text('Thiết lập thiết bị'),
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
                      message: _errorMessage!,
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
        message: 'Máy chủ chưa trả về mã thiết lập.',
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
                  fontFamily: 'monospace',
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
                onPressed: () => _copy(code.code, 'Mã thiết lập'),
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
                    Text(_isCopied ? 'Sao chép lại mã' : 'Sao chép mã'),
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
          message: _espMessage,
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
        _SetupStep(
          number: '1',
          text:
              'Giữ laptop chạy backend và frontend trên Wi-Fi chính. Trên điện thoại, mở màn hình này trước.',
        ),
        _SetupStep(
          number: '2',
          text:
              'Kết nối điện thoại với Wi-Fi IOTAgri-Setup, quay lại màn hình này và nhấn Kiểm tra kết nối ESP.',
        ),
        _SetupStep(
          number: '3',
          text:
              'Chọn Wi-Fi 2.4 GHz, nhập mật khẩu rồi nhấn Kết nối ESP. Frontend tự gửi mã và địa chỉ backend.',
        ),
        _SetupStep(
          number: '4',
          text:
              'Khi báo thành công, kết nối điện thoại trở lại Wi-Fi chính và chờ thiết bị chuyển sang trạng thái online.',
        ),
        const SizedBox(height: 12),
        Text(
          'Backend dành cho ESP: ${ApiConstants.deviceApiBaseUrl}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 18),
        CupertinoButton(
          onPressed: _generateCode,
          child: const Text('Tạo mã mới (mã cũ sẽ hết hiệu lực)'),
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
          'Kết nối trực tiếp với ESP',
          style: TextStyle(
            color: CupertinoColors.label.resolveFrom(context),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Không cần mở Swagger hoặc trang cấu hình 192.168.4.1.',
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
              : const Text('Kiểm tra kết nối ESP'),
        ),
        if (hardwareId != null) ...[
          const SizedBox(height: 8),
          Text(
            'Đã thấy ESP: $hardwareId',
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
          const Text(
            'Wi-Fi 2.4 GHz ESP nhìn thấy:',
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
          placeholder: 'Tên Wi-Fi 2.4 GHz (SSID)',
          padding: const EdgeInsets.all(13),
        ),
        const SizedBox(height: 10),
        CupertinoTextField(
          controller: passwordController,
          enabled: !isProvisioning,
          placeholder: 'Mật khẩu Wi-Fi',
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
              : Text(provisioned ? 'Đã kết nối' : 'Kết nối ESP'),
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
          const Text('Không thể tạo mã thiết lập.'),
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
            child: const Text('Thử lại'),
          ),
        ],
      ),
    ),
  );
}
