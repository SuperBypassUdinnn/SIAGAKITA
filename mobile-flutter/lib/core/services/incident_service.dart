import 'dart:convert';
import 'package:http/http.dart' as http;

/// IncidentService menangani API calls untuk SOS incidents.
class IncidentService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/v1';

  // ─── Trigger SOS ──────────────────────────────────────────────────────────

  static Future<TriggerSOSResult> triggerSOS({
    required String accessToken,
    required double latitude,
    required double longitude,
    String triggerMethod = 'user',
    String? incidentType,
    String? addressDetail,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/incidents/trigger'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'trigger_method': triggerMethod,
        'incident_type': incidentType,
        'address_detail': addressDetail,
      }),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw IncidentException(body['message'] as String? ?? 'Gagal mengirim SOS');
    }
    return TriggerSOSResult.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ─── Cancel SOS ───────────────────────────────────────────────────────────

  static Future<void> cancelSOS({
    required String accessToken,
    required int incidentId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/incidents/$incidentId/cancel'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw IncidentException(body['message'] as String? ?? 'Gagal membatalkan SOS');
    }
  }

  // ─── Update Location ──────────────────────────────────────────────────────

  static Future<void> updateLocation({
    required String accessToken,
    required int incidentId,
    required double latitude,
    required double longitude,
  }) async {
    await http.put(
      Uri.parse('$_baseUrl/incidents/$incidentId/location'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
    );
    // Gagal silent — lokasi akan diupdate di iterasi berikutnya
  }

  // ─── Get Active Incident ──────────────────────────────────────────────────

  static Future<ActiveIncident?> getActive({
    required String accessToken,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/incidents/active'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode != 200) return null;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'];
    if (data == null) return null;
    return ActiveIncident.fromJson(data as Map<String, dynamic>);
  }
}

// ─── Data classes ──────────────────────────────────────────────────────────────

class TriggerSOSResult {
  final int incidentId;
  final String status;
  final String message;

  const TriggerSOSResult({
    required this.incidentId,
    required this.status,
    required this.message,
  });

  factory TriggerSOSResult.fromJson(Map<String, dynamic> json) =>
      TriggerSOSResult(
        incidentId: (json['incident_id'] as num).toInt(),
        status: json['status'] as String,
        message: json['message'] as String? ?? '',
      );
}

class ActiveIncident {
  final int incidentId;
  final String status;
  final double latitude;
  final double longitude;
  final String createdAt;

  const ActiveIncident({
    required this.incidentId,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory ActiveIncident.fromJson(Map<String, dynamic> json) => ActiveIncident(
        incidentId: (json['incident_id'] as num).toInt(),
        status: json['status'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        createdAt: json['created_at'] as String,
      );
}

class IncidentException implements Exception {
  final String message;
  const IncidentException(this.message);
  @override
  String toString() => message;
}
