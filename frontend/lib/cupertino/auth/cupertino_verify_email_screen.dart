import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'cupertino_login_screen.dart';
import 'cupertino_register_screen.dart';

class CupertinoVerifyEmailScreen extends StatefulWidget {
  const CupertinoVerifyEmailScreen({required this.email, super.key});

  final String email;

  @override
  State<CupertinoVerifyEmailScreen> createState() =>
      _CupertinoVerifyEmailScreenState();
}

class _CupertinoVerifyEmailScreenState
    extends State<CupertinoVerifyEmailScreen> {
  final _codeController = TextEditingController();
  String? _codeError;
  String? _message;
  bool _messageIsError = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final authProvider = context.read<AuthProvider>();
    final code = _codeController.text;
    if (authProvider.isLoading) return;

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() {
        _codeError = 'Vui lòng nhập mã xác minh gồm 6 chữ số.';
        _message = null;
      });
      return;
    }

    setState(() {
      _codeError = null;
      _message = null;
    });
    final success = await authProvider.verifyEmail(widget.email, code);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute<void>(builder: (_) => const CupertinoLoginScreen()),
        (_) => false,
      );
      return;
    }

    setState(() {
      _message =
          authProvider.errorMessage ??
          'Không thể xác minh email. Vui lòng thử lại.';
      _messageIsError = true;
    });
  }

  Future<void> _resendCode() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoading) return;

    setState(() => _message = null);
    final success = await authProvider.resendVerificationCode(widget.email);
    if (!mounted) return;

    setState(() {
      _message = success
          ? 'Đã gửi lại mã xác minh.'
          : authProvider.errorMessage ??
                'Không thể gửi lại mã xác minh. Vui lòng thử lại.';
      _messageIsError = !success;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Xác minh email'),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 520 ? 420 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      CupertinoIcons.mail_solid,
                      size: 64,
                      color: Color(0xFF34C759),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Xác minh email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CupertinoColors.label.resolveFrom(context),
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nhập mã gồm 6 chữ số đã gửi đến\n${widget.email}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel.resolveFrom(
                          context,
                        ),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 7),
                      child: Text(
                        'Mã xác minh',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    CupertinoTextField(
                      controller: _codeController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CupertinoColors.label.resolveFrom(context),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 8,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onSubmitted: (_) => _verify(),
                      onChanged: (_) {
                        if (_codeError != null || _message != null) {
                          setState(() {
                            _codeError = null;
                            _message = null;
                          });
                        }
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.secondarySystemBackground
                            .resolveFrom(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _codeError == null
                              ? CupertinoColors.separator.resolveFrom(context)
                              : CupertinoColors.systemRed.resolveFrom(context),
                        ),
                      ),
                    ),
                    if (_codeError != null) _FeedbackMessage(_codeError!),
                    if (_message != null)
                      _FeedbackMessage(_message!, isError: _messageIsError),
                    const SizedBox(height: 24),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) =>
                          CupertinoButton.filled(
                            minimumSize: const Size(52, 52),
                            borderRadius: BorderRadius.circular(16),
                            onPressed: authProvider.isLoading ? null : _verify,
                            child: authProvider.isLoading
                                ? const CupertinoActivityIndicator(
                                    color: CupertinoColors.white,
                                  )
                                : const Text(
                                    'Xác minh',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                    ),
                    const SizedBox(height: 14),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) => CupertinoButton(
                        onPressed: authProvider.isLoading ? null : _resendCode,
                        child: const Text('Gửi lại mã'),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        CupertinoPageRoute<void>(
                          builder: (_) => const CupertinoRegisterScreen(),
                        ),
                      ),
                      child: const Text('Quay lại đăng ký'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackMessage extends StatelessWidget {
  const _FeedbackMessage(this.message, {this.isError = true});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 8, top: 8),
    child: Row(
      children: [
        Icon(
          isError
              ? CupertinoIcons.xmark_circle_fill
              : CupertinoIcons.check_mark_circled_solid,
          size: 16,
          color: isError
              ? CupertinoColors.systemRed
              : CupertinoColors.systemGreen,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: isError
                  ? CupertinoColors.systemRed
                  : CupertinoColors.systemGreen,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}
