// lib/screens/help_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/page_header.dart';
import '../core/widgets/section_chip.dart';
import '../utils/l10n.dart';

/// Help & Support screen – FAQ accordion and a placeholder chat button.
class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                chip: SectionChip(label: context.l10n.help),
                title: context.l10n.support,
                subtitle: '',
              ),
              const SizedBox(height: 24),
              const _FaqAccordion(),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Placeholder for future chat integration.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.chatNotAvailable)),
                    );
                  },
                  icon: const Icon(Icons.chat),
                  label: Text(context.l10n.chatWithUs),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple FAQ accordion using ExpansionPanelList.
class _FaqAccordion extends StatefulWidget {
  const _FaqAccordion();

  @override
  State<_FaqAccordion> createState() => _FaqAccordionState();
}

class _FaqAccordionState extends State<_FaqAccordion> {
  @override
  Widget build(BuildContext context) {
    final items = [
      _FaqItem(
        question: context.l10n.faqAddPlantQuestion,
        answer: context.l10n.faqAddPlantAnswer,
      ),
      _FaqItem(
        question: context.l10n.faqAlertsQuestion,
        answer: context.l10n.faqAlertsAnswer,
      ),
      _FaqItem(
        question: context.l10n.faqUnitsQuestion,
        answer: context.l10n.faqUnitsAnswer,
      ),
      _FaqItem(
        question: context.l10n.faqHarvestQuestion,
        answer: context.l10n.faqHarvestAnswer,
      ),
    ];
    return ExpansionPanelList.radio(
      expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 4),
      children: items.map<ExpansionPanelRadio>((_FaqItem item) {
        return ExpansionPanelRadio(
          value: item.question,
          headerBuilder: (context, isExpanded) => ListTile(
            title: Text(
              item.question,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(item.answer),
          ),
        );
      }).toList(),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  _FaqItem({required this.question, required this.answer});
}
