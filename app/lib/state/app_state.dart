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
        await Future.delayed(const Duration(milliseconds: 200));
        projects = _demoProjects();
        secrets = _demoSecrets();
      }
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<void> createProject(String name) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      if (api.isConfigured) {
        final project = await api.createProject(name);
        projects.insert(0, project);
      } else {
        final project = Project(
          id: _newId(),
          name: name,
          createdAt: DateTime.now(),
        );
        projects.insert(0, project);
      }
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

    loading = true;
    error = null;
    notifyListeners();

    try {
      if (api.isConfigured) {
        _messages[projectId] = await api.fetchMessages(projectId);
      } else {
        _messages[projectId] = [
          ChatMessage(
            id: _newId(),
            projectId: projectId,
            role: 'assistant',
            content:
                'هذا وضع العرض التجريبي. اربط التطبيق بـ Backend حتى يستطيع تنفيذ أوامر GitHub وAWS وFirebase فعليًا.',
            createdAt: DateTime.now(),
          ),
        ];
      }
    } catch (e) {
      _messages[projectId] = [
        ChatMessage(
          id: _newId(),
          projectId: projectId,
          role: 'system',
          content: e.toString(),
          createdAt: DateTime.now(),
        ),
      ];
    }

    loading = false;
    notifyListeners();
  }

  Future<void> sendMessage(int projectId, String text) async {
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
      if (api.isConfigured) {
        final reply = await api.sendMessage(projectId, text);
        _messages[projectId]!.add(reply);
      } else {
        await Future.delayed(const Duration(milliseconds: 300));
        _messages[projectId]!.add(
          ChatMessage(
            id: _newId(),
            projectId: projectId,
            role: 'assistant',
            content:
                'تم استلام الأمر في وضع العرض فقط. للبناء الحقيقي اربط Backend آمن مع مفاتيح GitHub وAWS وFirebase.',
            createdAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      _messages[projectId]!.add(
        ChatMessage(
          id: _newId(),
          projectId: projectId,
          role: 'system',
          content: e.toString(),
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
    loading = true;
    error = null;
    notifyListeners();

    try {
      if (api.isConfigured) {
        await api.createSecret(
          name: name,
          type: type,
          scope: scope,
          rawValue: rawValue,
        );
        secrets = await api.fetchSecrets();
      } else {
        secrets.insert(
          0,
          SecretMetadata(
            id: _newId(),
            name: name,
            type: type,
            scope: scope,
            maskedPreview: '********',
            createdAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  List<Project> _demoProjects() {
    return [
      Project(
        id: 1,
        name: 'مشروع تجريبي',
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<SecretMetadata> _demoSecrets() {
    return [
      SecretMetadata(
        id: 1,
        name: 'Firebase Sandbox',
        type: 'firebase_service_account',
        scope: 'global',
        maskedPreview: '********',
        createdAt: DateTime.now(),
      ),
      SecretMetadata(
        id: 2,
        name: 'AWS Sandbox',
        type: 'aws_credentials',
        scope: 'global',
        maskedPreview: '********',
        createdAt: DateTime.now(),
      ),
    ];
  }
}
