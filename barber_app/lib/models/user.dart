class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? photoUrl;
  final List<String> favoriteBarbers;
  final List<String> appointmentHistory;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.photoUrl,
    this.favoriteBarbers = const [],
    this.appointmentHistory = const [],
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      photoUrl: map['photoUrl'],
      favoriteBarbers: List<String>.from(map['favoriteBarbers'] ?? []),
      appointmentHistory: List<String>.from(map['appointmentHistory'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'favoriteBarbers': favoriteBarbers,
      'appointmentHistory': appointmentHistory,
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    List<String>? favoriteBarbers,
    List<String>? appointmentHistory,
  }) {
    return User(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      favoriteBarbers: favoriteBarbers ?? this.favoriteBarbers,
      appointmentHistory: appointmentHistory ?? this.appointmentHistory,
    );
  }
}