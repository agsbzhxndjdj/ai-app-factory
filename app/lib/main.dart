import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_config.dart';
import 'core/app_theme.dart';
import 'services/api_service.dart';
import 'state/app_state.dart';
import 'ui/screens/home_screen.dart';

void main() {
  runApp(const AiAppFactoryApp());
}

class AiAppFactoryApp extends StatelessWidget {
  const AiAppFactoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(
        api: ApiService(baseUrl: AppConfig.apiBaseUrl),
      ),
      child: MaterialApp(
        title: 'AI App Factory',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const HomeScreen(),
      ),
    );
  }
}
