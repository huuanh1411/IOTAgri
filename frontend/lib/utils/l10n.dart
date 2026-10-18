import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// Short access to the generated Flutter localization class.
///
/// Keep all display text in ARB resources; this extension deliberately owns no
/// translations or locale state.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
