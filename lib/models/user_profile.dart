class UserProfile {
  final String name;
  final String email;
  final List<String> interests;

  const UserProfile({
    required this.name,
    required this.email,
    required this.interests,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'interests': interests,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String,
        email: json['email'] as String,
        interests: List<String>.from(json['interests'] as List),
      );

  UserProfile copyWith({String? name, String? email, List<String>? interests}) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      interests: interests ?? this.interests,
    );
  }
}
