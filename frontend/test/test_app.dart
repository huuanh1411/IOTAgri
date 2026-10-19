import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iotagri_app/l10n/app_localizations.dart';

Widget buildLocalizedCupertinoApp({required Widget home}) => CupertinoApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('vi'),
  home: home,
);

Widget buildLocalizedMaterialApp({required Widget home}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('vi'),
  home: home,
);
