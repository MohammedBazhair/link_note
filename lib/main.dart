
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/presentation/screens/main_app.dart';
import 'initialize_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeApp();
  runApp(const ProviderScope(child: MainApp()));
}
