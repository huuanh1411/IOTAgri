import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/device.dart';
import '../../models/provisioning_code.dart';
import '../../services/api_service.dart';

class CupertinoProvisioningCodeScreen extends StatefulWidget {
  final Device device;
  final ApiService? apiService;

  const CupertinoProvisioningCodeScreen({
    super.key,
    required this.device,
    this.apiService,
  });

  @override
  State<CupertinoProvisioningCodeScreen> createState() =>
      _CupertinoProvisioningCodeScreenState();
}

class _CupertinoProvisioningCodeScreenState
    extends State<CupertinoProvisioningCodeScreen> {
  late final ApiService _apiService;
  ProvisioningCode? _provisioningCode;
  bool _isLoading = true;
  bool _isCopied = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _generateCode();
  }

  Future<void> _generateCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isCopied = false;
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
        _SetupStep(
          number: '1',
          text: 'Bật ESP32 và kết nối điện thoại với Wi-Fi IOTAgri-Setup.',
        ),
        _SetupStep(
          number: '2',
          text:
              'Mở trang cài đặt của thiết bị tại địa chỉ được in trong Serial Monitor (mặc định thường là 192.168.4.1).',
        ),
        _SetupStep(
          number: '3',
          text:
              'Nhập Wi-Fi của nông trại, Backend URL và mã thiết lập ở trên rồi nhấn Connect.',
        ),
        _SetupStep(
          number: '4',
          text:
              'Mã dùng một lần và hết hạn sau 15 phút. Sau khi ESP32 nhận mã, máy chủ cấp thông tin kết nối để thiết bị lên mạng.',
        ),
        const SizedBox(height: 12),
        Text(
          'Mã được nhập trên trang cài đặt ESP32, không nhập vào màn hình này.',
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
