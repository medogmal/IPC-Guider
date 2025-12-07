/// User profile model (offline-first, no authentication)
class UserProfile {
  final String? name; // e.g., "John Smith"
  final String? title; // e.g., "Dr.", "Mr.", "Ms.", "Nurse", "Prof."
  final String? profession; // e.g., "Infection Preventionist", "ICU Nurse"

  const UserProfile({
    this.name,
    this.title,
    this.profession,
  });

  factory UserProfile.empty() => const UserProfile();

  UserProfile copyWith({
    String? name,
    String? title,
    String? profession,
    bool clearName = false,
    bool clearTitle = false,
    bool clearProfession = false,
  }) {
    return UserProfile(
      name: clearName ? null : (name ?? this.name),
      title: clearTitle ? null : (title ?? this.title),
      profession: clearProfession ? null : (profession ?? this.profession),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'title': title,
        'profession': profession,
      };

  static UserProfile fromJson(Map<String, dynamic> m) => UserProfile(
        name: m['name']?.toString(),
        title: m['title']?.toString(),
        profession: m['profession']?.toString(),
      );

  bool get isEmpty => name == null && title == null && profession == null;
  bool get isNotEmpty => !isEmpty;
}

