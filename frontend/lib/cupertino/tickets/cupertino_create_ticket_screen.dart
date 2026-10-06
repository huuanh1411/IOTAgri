import 'package:flutter/cupertino.dart';

import '../../services/api_service.dart';

class CupertinoCreateTicketScreen extends StatefulWidget {
  const CupertinoCreateTicketScreen({super.key});

  @override
  State<CupertinoCreateTicketScreen> createState() =>
      _CupertinoCreateTicketScreenState();
}

class _CupertinoCreateTicketScreenState
    extends State<CupertinoCreateTicketScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _apiService = ApiService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();
    if (subject.isEmpty || message.isEmpty) {
      _showMessage('Nhập tiêu đề và nội dung.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _apiService.createSupportTicket(subject, message);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Liên hệ hỗ trợ')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CupertinoTextField(
              controller: _subjectController,
              maxLength: 200,
              placeholder: 'Tiêu đề',
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: _messageController,
              maxLength: 4000,
              minLines: 6,
              maxLines: 10,
              placeholder: 'Mô tả vấn đề',
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                  : const Text('Gửi ticket'),
            ),
          ],
        ),
      ),
    );
  }
}
