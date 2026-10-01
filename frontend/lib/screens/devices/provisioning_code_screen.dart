import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      appBar: AppBar(
        title: const Text('Mã Thiết Lập Thiết Bị'),
      ),
      body: _buildBody(),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.qr_code_2,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          const Text(
            'Mã Thiết Lập Thiết Bị',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.device.name,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Code Display Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Mã thiết lập của bạn:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _provisioningCode!.code,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontFamily: 'Courier',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Hết hạn sau: ${_getExpirationTime()}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[700],
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
                    backgroundColor: _isCopied ? Colors.green : Colors.blue,
                    onPressed: _copyCode,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Instructions Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Hướng dẫn sử dụng:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
          
          const SizedBox(height: 24),
          
          // Warning Card
          Card(
            color: Colors.orange[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.orange[300]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mã thiết lập chỉ sử dụng được một lần. Hãy đảm bảo thiết bị của bạn đã sẵn sàng trước khi sử dụng.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          CustomElevatedButton(
            text: 'Tạo mã mới',
            icon: Icons.refresh,
            onPressed: _generateProvisioningCode,
            isFullWidth: true,
          ),
          
          const SizedBox(height: 16),
          
          CustomOutlinedButton(
            text: 'Quay lại',
            icon: Icons.arrow_back,
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
              color: Colors.green,
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