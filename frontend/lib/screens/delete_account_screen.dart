import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_controller.dart';
import '../utils/l10n.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirmationController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (_confirmationController.text != 'DELETE' || _submitting) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    final deleted = await ref.read(authControllerProvider.notifier).deleteAccount();
    if (!mounted) return;

    if (deleted) {
      context.go('/auth');
      return;
    }

    setState(() {
      _submitting = false;
      _error = context.l10n.deleteAccountFailed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canDelete = _confirmationController.text == 'DELETE' && !_submitting;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deleteAccountTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 48),
            const SizedBox(height: 16),
            Text(
              l10n.deleteAccountWarningTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(l10n.deleteAccountWarningBody),
            const SizedBox(height: 24),
            Text(l10n.deleteAccountConfirmationInstruction),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmationController,
              onChanged: (_) => setState(() {}),
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.deleteAccountConfirmationLabel,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: canDelete ? _deleteAccount : null,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.deleteAccountAction),
            ),
          ],
        ),
      ),
    );
  }
}
