// Enum untuk mendefinisikan 4 role pengguna SiagaKita
enum UserRole {
  masyarakat, // Masyarakat umum
  relawan,    // Relawan terverifikasi
  instansi,   // Instansi penyelamat (Damkar, BPBD, Polisi, dll)
  admin,      // Administrator sistem
}

// Model data pengguna yang sedang login
class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  /// Label role dalam Bahasa Indonesia
  String get roleLabel {
    switch (role) {
      case UserRole.masyarakat:
        return 'Masyarakat Umum';
      case UserRole.relawan:
        return 'Relawan';
      case UserRole.instansi:
        return 'Instansi Penyelamat';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  /// Warna badge role
  String get roleColor {
    switch (role) {
      case UserRole.masyarakat:
        return '#18A3FF'; // Biru
      case UserRole.relawan:
        return '#22C55E'; // Hijau
      case UserRole.instansi:
        return '#FF7418'; // Oranye
      case UserRole.admin:
        return '#A855F7'; // Ungu
    }
  }

  /// Digunakan untuk simulasi — nanti diganti dengan response dari API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.masyarakat,
      ),
    );
  }
}
