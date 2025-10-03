class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? address;
  final String? profileImageUrl;  // <-- INI FIELD BARU
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.address,
    this.profileImageUrl,  // <-- TAMBAHKAN INI
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'] ?? '',
      fullName: json['full_name'],
      phone: json['phone'],
      address: json['address'],
      profileImageUrl: json['profile_image_url'],  // <-- TAMBAHKAN INI
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'profile_image_url': profileImageUrl,  // <-- TAMBAHKAN INI
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? address,
    String? profileImageUrl,  // <-- TAMBAHKAN INI
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,  // <-- TAMBAHKAN INI
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isComplete {
    return fullName != null && 
           phone != null && 
           address != null &&
           fullName!.isNotEmpty &&
           phone!.isNotEmpty &&
           address!.isNotEmpty;
  }
}