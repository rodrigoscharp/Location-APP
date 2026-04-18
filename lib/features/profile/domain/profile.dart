class Profile {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? phone;
  final bool isHost;
  final DateTime createdAt;

  const Profile({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.isHost = false,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      isHost: json['is_host'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get displayName => fullName ?? 'Viajante';

  String get initials {
    if (fullName == null || fullName!.isEmpty) return '?';
    final parts = fullName!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}
