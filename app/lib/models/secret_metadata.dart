class SecretMetadata {
  final int id;
  final String name;
  final String type;
  final String scope;
  final String maskedPreview;
  final DateTime createdAt;

  const SecretMetadata({
    required this.id,
    required this.name,
    required this.type,
    required this.scope,
    required this.maskedPreview,
    required this.createdAt,
  });

  factory SecretMetadata.fromJson(Map<String, dynamic> json) {
    return SecretMetadata(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      scope: json['scope']?.toString() ?? 'global',
      maskedPreview: json['masked_preview']?.toString() ?? '********',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'scope': scope,
      'masked_preview': maskedPreview,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
