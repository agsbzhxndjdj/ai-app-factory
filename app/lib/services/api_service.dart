import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';
import '../models/project.dart';
import '../models/secret_metadata.dart';

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl;
  final http.Client _client = http.Client();

  ApiService({required this.baseUrl});

  bool get isConfigured => baseUrl.trim().isNotEmpty;

  String get _base =>
      baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Uri _uri(String path) => Uri.parse('$_base$path');

  Future<T> _handle<T>(
    Future<http.Response> responseFuture,
    T Function(dynamic data) parse,
  ) async {
    final response = await responseFuture.timeout(const Duration(seconds: 30));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = response.body.isEmpty ? '{}' : response.body;
      final dynamic data = jsonDecode(body);
      return parse(data);
    }

    throw ApiException('HTTP ${response.statusCode}: ${response.body}');
  }

  Future<List<Project>> fetchProjects() {
    return _handle(
      _client.get(_uri('/api/projects'), headers: _headers),
      (data) => (data as List)
          .map((item) => Project.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Project> createProject(String name) {
    return _handle(
      _client.post(
        _uri('/api/projects'),
        headers: _headers,
        body: jsonEncode({'name': name}),
      ),
      (data) => Project.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<ChatMessage>> fetchMessages(int projectId) {
    return _handle(
      _client.get(_uri('/api/projects/$projectId/messages'), headers: _headers),
      (data) => (data as List)
          .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ChatMessage> sendMessage(int projectId, String content) {
    return _handle(
      _client.post(
        _uri('/api/projects/$projectId/messages'),
        headers: _headers,
        body: jsonEncode({'content': content}),
      ),
      (data) => ChatMessage.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<SecretMetadata>> fetchSecrets() {
    return _handle(
      _client.get(_uri('/api/secrets'), headers: _headers),
      (data) => (data as List)
          .map((item) => SecretMetadata.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> createSecret({
    required String name,
    required String type,
    required String scope,
    required String rawValue,
  }) async {
    final response = await _client
        .post(
          _uri('/api/secrets'),
          headers: _headers,
          body: jsonEncode({
            'name': name,
            'type': type,
            'scope': scope,
            'value': rawValue,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
