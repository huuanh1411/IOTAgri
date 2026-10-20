import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_vi.dart';

/// Short access to the generated Flutter localization class.
///
/// Keep all display text in ARB resources; this extension deliberately owns no
/// translations or locale state.
extension AppLocalizationsX on BuildContext {
  List<String> get localizedWeekdays => [
    l10n.sundayShort,
    l10n.mondayShort,
    l10n.tuesdayShort,
    l10n.wednesdayShort,
    l10n.thursdayShort,
    l10n.fridayShort,
    l10n.saturdayShort,
  ];

  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? AppLocalizationsVi();
}
