class AppUser {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String email;
  final String? phone;
  final bool isHost;

  const AppUser({
    required this.id,
    this.fullName,
    this.avatarUrl,
    required this.email,
    this.phone,
    this.isHost = false,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      isHost: json['is_host'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'phone': phone,
        'is_host': isHost,
      };

  String get displayName => fullName ?? email.split('@').first;

  String get initials {
    if (fullName == null || fullName!.isEmpty) return '?';
    final parts = fullName!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}
