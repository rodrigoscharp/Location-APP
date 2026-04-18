class Conversation {
  final String id;
  final String listingId;
  final String guestId;
  final String hostId;
  final String? listingTitle;
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? lastMessage;
  final DateTime createdAt;

  const Conversation({
    required this.id,
    required this.listingId,
    required this.guestId,
    required this.hostId,
    this.listingTitle,
    this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json, String currentUserId) {
    // Get the "other" person's profile
    final profiles = json['profiles'] as List<dynamic>? ?? [];
    final otherProfile = profiles.firstWhere(
      (p) => p['id'] != currentUserId,
      orElse: () => null,
    );

    final listingRaw = json['listings'];
    final listingTitle = listingRaw is Map ? listingRaw['title'] as String? : null;

    return Conversation(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      guestId: json['guest_id'] as String,
      hostId: json['host_id'] as String,
      listingTitle: listingTitle,
      otherUserName: otherProfile?['full_name'] as String?,
      otherUserAvatar: otherProfile?['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
