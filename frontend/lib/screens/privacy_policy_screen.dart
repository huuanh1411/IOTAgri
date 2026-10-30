import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../utils/l10n.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicyTitle)),
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
                    l10n.privacyPolicyTitle,
                    style: AppText.heading(context, fontSize: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.privacyPolicyIntro,
                    style: AppText.body(
                      context,
                      fontSize: 15,
                    ).copyWith(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 28),
                  _Section(
                    title: l10n.privacyPolicyDataTitle,
                    body: l10n.privacyPolicyDataBody,
                  ),
                  _Section(
                    title: l10n.privacyPolicyUseTitle,
                    body: l10n.privacyPolicyUseBody,
                  ),
                  _Section(
                    title: l10n.privacyPolicySharingTitle,
                    body: l10n.privacyPolicySharingBody,
                  ),
                  _Section(
                    title: l10n.privacyPolicySecurityTitle,
                    body: l10n.privacyPolicySecurityBody,
                  ),
                  _Section(
                    title: l10n.privacyPolicyRetentionTitle,
                    body: l10n.privacyPolicyRetentionBody,
                  ),
                  _Section(
                    title: l10n.privacyPolicyRightsTitle,
                    body: l10n.privacyPolicyRightsBody,
                  ),
                  _Section(
                    title: l10n.privacyPolicyContactTitle,
                    body: l10n.privacyPolicyContactBody,
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
