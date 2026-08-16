import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';

class SecretsScreen extends StatelessWidget {
  const SecretsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: state.loadInitialData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 96),
                children: [
                  if (!state.isApiConfigured)
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.warning_amber_rounded),
                        title: Text('لا يوجد Backend مضبوط'),
                        subtitle: Text(
                          'بدون Backend لن يتم حفظ قيم المفاتيح بأمان. هذا الوضع يعرض البيانات التجريبية فقط.',
                        ),
                      ),
                    ),
                  if (state.error != null)
                    Card(
                      color: Colors.red.shade900,
                      child: ListTile(
                        title: Text(
                          state.error!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  if (state.secrets.isEmpty && !state.loading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'لا توجد مفاتيح بعد.\nأضف مفتاح GitHub أو Firebase أو AWS.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ...state.secrets.map(
                    (secret) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.key_outlined),
                        title: Text(secret.name),
                        subtitle: Text('${secret.type} • ${secret.scope}'),
                        trailing: Text(secret.maskedPreview),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (state.loading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: () => _addSecret(context, state),
                icon: const Icon(Icons.add),
                label: const Text('إضافة مفتاح'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addSecret(BuildContext context, AppState state) async {
    final nameController = TextEditingController();
    final typeController = TextEditingController(text: 'api_key');
    final scopeController = TextEditingController(text: 'global');
    final valueController = TextEditingController();

    final apiConfigured = state.isApiConfigured;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إضافة مفتاح'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المفتاح',
                    hintText: 'مثال: Firebase Sandbox',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'النوع',
                    hintText: 'api_key / aws_credentials / firebase_service_account',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: scopeController,
                  decoration: const InputDecoration(
                    labelText: 'النطاق',
                    hintText: 'global أو project',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueController,
                  obscureText: true,
                  enabled: apiConfigured,
                  decoration: InputDecoration(
                    labelText: 'القيمة',
                    helperText: apiConfigured
                        ? 'سترسل إلى Backend فقط.'
                        : 'غير متاح لأن Backend غير مضبوط.',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final type = typeController.text.trim();
                final scope = scopeController.text.trim();

                if (name.isEmpty || type.isEmpty) return;

                Navigator.of(dialogContext).pop();

                await state.addSecret(
                  name: name,
                  type: type,
                  scope: scope.isEmpty ? 'global' : scope,
                  rawValue: valueController.text,
                );
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }
}
