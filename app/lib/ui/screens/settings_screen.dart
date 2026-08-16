import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_config.dart';
import '../../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.link),
                title: const Text('API Base URL'),
                subtitle: Text(
                  AppConfig.apiBaseUrl.isEmpty
                      ? 'غير مضبوط'
                      : AppConfig.apiBaseUrl,
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud_outlined),
                title: const Text('حالة Backend'),
                subtitle: Text(
                  state.isApiConfigured
                      ? 'مضبوط'
                      : 'غير مضبوط - وضع العرض التجريبي',
                ),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('ملاحظات مهمة'),
                subtitle: Text(
                  'لا تضع مفاتيح API داخل تطبيق Flutter مباشرة.\n'
                  'استخدم Backend آمن يخزن المفاتيح مشفرة.\n'
                  'يمكن ربط هذا التطبيق لاحقًا بـ FastAPI أو Node.js أو أي Backend آخر.',
                ),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.construction),
                title: Text('Endpoints المتوقعة من Backend'),
                subtitle: Text(
                  'GET /api/projects\n'
                  'POST /api/projects\n'
                  'GET /api/projects/:id/messages\n'
                  'POST /api/projects/:id/messages\n'
                  'GET /api/secrets\n'
                  'POST /api/secrets',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
