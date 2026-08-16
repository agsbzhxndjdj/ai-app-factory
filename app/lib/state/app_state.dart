import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../models/project.dart';
import '../models/secret_metadata.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  final ApiService api;

  bool loading = false;
  String? error;

  List<Project> projects = [];
  List<SecretMetadata> secrets = [];

  final Map<int, List<ChatMessage>> _messages = {};

  int _idCounter = 1000;

  AppState({required this.api});

  bool get isApiConfigured => api.isConfigured;

  List<ChatMessage> messagesFor(int projectId) {
    return _messages[projectId] ?? const [];
  }

  int _newId() => ++_idCounter;

  Future<void> loadInitialData() async {
    if (loading) return;

    loading = true;
    error = null;
    notifyListeners();

    try {
      if (api.isConfigured) {
        projects = await api.fetchProjects();
        secrets = await api.fetchSecrets();
      } else {
        projects = [];
        secrets = [];
        error = 'Backend غير متصل. تأكد من إضافة API_BASE_URL.';
      }
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<void> createProject(String name) async {
    if (!api.isConfigured) {
      error = 'لا يمكن إنشاء مشروع بدون الاتصال بالـ Backend.';
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      final project = await api.createProject(name);
      projects.insert(0, project);
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<void> loadMessages(int projectId) async {
    if (_messages.containsKey(projectId)) {
      notifyListeners();
      return;
    }

    if (!api.isConfigured) {
      _messages[projectId] = [];
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      _messages[projectId] = await api.fetchMessages(projectId);
    } catch (e) {
      _messages[projectId] = [];
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<void> sendMessage(int projectId, String text) async {
    if (!api.isConfigured) {
      error = 'Backend غير متصل.';
      notifyListeners();
      return;
    }

    final userMessage = ChatMessage(
      id: _newId(),
      projectId: projectId,
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );

    _messages.putIfAbsent(projectId, () => []).add(userMessage);
    notifyListeners();

    try {
      final reply = await api.sendMessage(projectId, text);
      _messages[projectId]!.add(reply);
    } catch (e) {
      _messages[projectId]!.add(
        ChatMessage(
          id: _newId(),
          projectId: projectId,
          role: 'system',
          content: 'فشل الاتصال بالـ Backend: $e',
          createdAt: DateTime.now(),
        ),
      );
    }

    notifyListeners();
  }

  Future<void> addSecret({
    required String name,
    required String type,
    required String scope,
    required String rawValue,
  }) async {
    if (!api.isConfigured) {
      error = 'لا يمكن حفظ المفاتيح بدون الاتصال بالـ Backend.';
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      await api.createSecret(
        name: name,
        type: type,
        scope: scope,
        rawValue: rawValue,
      );
      secrets = await api.fetchSecrets();
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }
}
