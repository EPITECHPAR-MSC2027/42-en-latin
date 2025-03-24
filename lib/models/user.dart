class TrelloUser {
  TrelloUser({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.avatarUrl,
    this.bio,
  });

  factory TrelloUser.fromJson(Map<String, dynamic> json) {
    return TrelloUser(
      id: json['id'],
      fullName: json['fullName'],
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatarUrl'] ?? 'https://www.gravatar.com/avatar/${json['gravatarHash']}?s=200',
      bio: json['bio'],
    );
  }

  final String id;
  final String fullName;
  final String username;
  final String email;
  final String avatarUrl;
  final String? bio;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
    };
  }
}
