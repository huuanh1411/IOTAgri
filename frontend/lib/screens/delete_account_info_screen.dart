import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../utils/l10n.dart';

class DeleteAccountInfoScreen extends StatelessWidget {
  const DeleteAccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.deleteAccountTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.deleteAccountTitle,
                    style: AppText.heading(context, fontSize: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.deleteAccountInfoIntro,
                    style: AppText.body(
                      context,
                      fontSize: 15,
                    ).copyWith(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 28),
                  _Section(
                    title: l10n.deleteAccountInfoStepsTitle,
                    body: l10n.deleteAccountInfoStepsBody,
                  ),
                  _Section(
                    title: l10n.deleteAccountInfoDataTitle,
                    body: l10n.deleteAccountInfoDataBody,
                  ),
                  _Section(
                    title: l10n.deleteAccountInfoRetentionTitle,
                    body: l10n.deleteAccountInfoRetentionBody,
                  ),
                  _Section(
                    title: l10n.deleteAccountInfoContactTitle,
                    body: l10n.deleteAccountInfoContactBody,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.heading(context, fontSize: 18)),
        const SizedBox(height: 8),
        Text(body, style: AppText.body(context, fontSize: 15)),
      ],
    ),
  );
}
