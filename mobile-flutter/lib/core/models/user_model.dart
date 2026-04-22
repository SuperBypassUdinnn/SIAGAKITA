import 'package:flutter/foundation.dart';

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
  
  // New properties for profile & volunteer features
  final String? phoneNumber;
  final String? bio;
  final String? volunteerStatus; // 'none', 'pending', 'approved'
  final Map<String, dynamic>? medicalData;
  final List<Map<String, dynamic>>? emergencyContacts;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.bio,
    this.volunteerStatus,
    this.medicalData,
    this.emergencyContacts,
  });

  // Global Mock User State (while backend is not ready)
  static final ValueNotifier<UserModel> currentUser = ValueNotifier(
    const UserModel(
      id: 'SK-2983-4412',
      name: 'Budi Santoso',
      email: 'budi@email.com',
      role: UserRole.masyarakat,
      phoneNumber: '081234567890',
      bio: 'Pemerhati keamanan bencana dan warga aktif dalam sosialisasi tanggap darurat lingkungan.',
      volunteerStatus: 'none',
      medicalData: {
        'blood_type': 'O+',
        'weight_height': '70kg / 175cm',
        'allergies': 'Penisilin, Kacang',
        'medical_history': 'Asma Ringan',
        'address': 'Jl. Cut Nyak Dhien No. 44, Peukan Bada, Kabupaten Aceh Besar, Aceh 23351',
      },
      emergencyContacts: [
        {
          'name': 'Siti Aminah',
          'relation': 'Ibu / Wali',
          'phone': '081234567891',
        }
      ],
    ),
  );

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? phoneNumber,
    String? bio,
    String? volunteerStatus,
    Map<String, dynamic>? medicalData,
    List<Map<String, dynamic>>? emergencyContacts,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      volunteerStatus: volunteerStatus ?? this.volunteerStatus,
      medicalData: medicalData ?? this.medicalData,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }

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

  /// Digunakan untuk sinkronisasi — parsing dari API backend Supabase/Laravel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.masyarakat,
      ),
      phoneNumber: json['phone_number'],
      bio: json['bio'],
      volunteerStatus: json['volunteer_status'],
      medicalData: json['medical_data'] != null ? Map<String, dynamic>.from(json['medical_data']) : null,
      emergencyContacts: json['emergency_contacts'] != null
          ? List<Map<String, dynamic>>.from(json['emergency_contacts'])
          : null,
    );
  }

  /// Sinkronisasi Data JSON untuk dikirim ke Backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'phone_number': phoneNumber,
      'bio': bio,
      'volunteer_status': volunteerStatus,
      'medical_data': medicalData,
      'emergency_contacts': emergencyContacts,
    };
  }
}
