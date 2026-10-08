import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../main.dart' as app;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const app.AerogreenApp());
}
