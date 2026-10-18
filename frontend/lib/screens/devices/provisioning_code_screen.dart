import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/section_chip.dart';
import '../../models/device.dart';
import '../../models/provisioning_code.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_indicators.dart';
import '../../widgets/custom_buttons.dart';

class ProvisioningCodeScreen extends StatefulWidget {
  final Device device;

  const ProvisioningCodeScreen({super.key, required this.device});

  @override
  State<ProvisioningCodeScreen> createState() => _ProvisioningCodeScreenState();
}

class _ProvisioningCodeScreenState extends State<ProvisioningCodeScreen> {
  final ApiService _apiService = ApiService();
  ProvisioningCode? _provisioningCode;
  bool _isLoading = true;
  bool _isCopied = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateProvisioningCode();
  }

  Future<void> _generateProvisioningCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final codeData = await _apiService.createProvisioningCode(widget.device.id);
      setState(() {
        _provisioningCode = ProvisioningCode.fromJson(codeData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _copyCode() async {
    if (_provisioningCode != null) {
      await Clipboard.setData(ClipboardData(text: _provisioningCode!.code));
      setState(() {
        _isCopied = true;
      });
      
      // Reset copied state after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isCopied = false;
          });
        }
      });
    }
  }



  String _getExpirationTime() {
    if (_provisioningCode == null) return '';
    
    try {
      final expiresAt = DateTime.parse(_provisioningCode!.expiresAt);
      final now = DateTime.now();
      final difference = expiresAt.difference(now);
      
      if (difference.isNegative) {
        return 'Đã hết hạn';
      }
      
      if (difference.inMinutes < 1) {
        return '${difference.inSeconds} giây';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes} phút';
      } else {
        return '${difference.inHours} giờ ${difference.inMinutes % 60} phút';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mã Thiết Lập Thiết Bị'),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingState(message: 'Đang tạo mã thiết lập...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        message: _errorMessage!,
        onRetry: _generateProvisioningCode,
      );
    }

    if (_provisioningCode == null) {
      return const ErrorState(
        message: 'Không thể tạo mã thiết lập',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            chip: const SectionChip(label: 'Thiết lập'),
            title: 'Mã thiết lập thiết bị',
            subtitle: widget.device.name,
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.mintChip,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.qr_code_2,
                size: 40,
                color: AppColors.forestGreen,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Code Display Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Mã thiết lập của bạn:',
                    style: AppText.body(
                      context,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.rowBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _provisioningCode!.code,
                          style: AppText.heading(
                            context,
                            fontSize: 28,
                          ).copyWith(letterSpacing: 2),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Hết hạn sau: ${_getExpirationTime()}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFB4690E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomElevatedButton(
                    text: _isCopied ? 'Đã sao chép!' : 'Sao chép mã',
                    icon: _isCopied ? Icons.check : Icons.copy,
                    backgroundColor: _isCopied
                        ? AppColors.mint
                        : AppColors.forestGreen,
                    onPressed: _copyCode,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Instructions Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.forestGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hướng dẫn sử dụng:',
                        style: AppText.heading(context, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionStep(
                    1,
                    'Mở ứng dụng thiết lập trên thiết bị ESP32',
                  ),
                  _buildInstructionStep(
                    2,
                    'Nhập mã thiết lập trên đây vào thiết bị',
                  ),
                  _buildInstructionStep(
                    3,
                    'Thiết bị sẽ tự động kết nối với hệ thống',
                  ),
                  _buildInstructionStep(
                    4,
                    'Mã chỉ có hiệu lực trong 15 phút',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Warning Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF1DD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEBCB94)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFB4690E)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mã thiết lập chỉ sử dụng được một lần. Hãy đảm bảo thiết bị của bạn đã sẵn sàng trước khi sử dụng.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7A4A0E),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          CustomElevatedButton(
            text: 'Tạo mã mới',
            icon: Icons.refresh,
            backgroundColor: AppColors.forestGreen,
            onPressed: _generateProvisioningCode,
            isFullWidth: true,
          ),

          const SizedBox(height: 12),

          CustomOutlinedButton(
            text: 'Quay lại',
            icon: Icons.arrow_back,
            borderColor: AppColors.forestGreen,
            textColor: AppColors.forestGreen,
            onPressed: () => Navigator.pop(context),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int step, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.forestGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}