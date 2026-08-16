import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import 'project_chat_screen.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

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
                  if (state.projects.isEmpty && !state.loading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'لا توجد مشاريع بعد.\nاضغط على "مشروع جديد" لإنشاء أول مشروع.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ...state.projects.map(
                    (project) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(project.name),
                        subtitle: Text(project.createdAt.toLocal().toString()),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProjectChatScreen(
                                projectId: project.id,
                                projectName: project.name,
                              ),
                            ),
                          );
                        },
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
                onPressed: () => _createProject(context, state),
                icon: const Icon(Icons.add),
                label: const Text('مشروع جديد'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createProject(BuildContext context, AppState state) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إنشاء مشروع جديد'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'اسم المشروع',
              hintText: 'مثال: Telegram Clone',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                Navigator.of(dialogContext).pop();
                await state.createProject(name);
              },
              child: const Text('إنشاء'),
            ),
          ],
        );
      },
    );
  }
}
