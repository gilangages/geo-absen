import '../../core/network/api_client.dart';

class AttendanceApi {
  final ApiClient _apiClient;

  AttendanceApi(this._apiClient);

  /// Mengambil status absensi hari ini (sudah check-in / check-out?).
  Future<Map<String, dynamic>> getToday() async {
    return await _apiClient.get('/attendances/today');
  }

  /// Mengambil riwayat absensi (default bulan ini).
  Future<Map<String, dynamic>> getHistory({String? month, String? year}) async {
    String query = '';
    if (month != null || year != null) {
      final params = <String>[];
      if (month != null) params.add('month=$month');
      if (year != null) params.add('year=$year');
      query = '?${params.join('&')}';
    }
    return await _apiClient.get('/attendances$query');
  }

  /// Kirim data absensi (check-in / check-out) dengan foto selfie.
  Future<Map<String, dynamic>> submitAttendance({
    required String type,
    required String latitude,
    required String longitude,
    required List<int> fotoBytes,
    String? fotoName,
  }) async {
    return await _apiClient.multipartPost(
      '/attendances',
      fields: {
        'type': type,
        'latitude': latitude,
        'longitude': longitude,
      },
      fileBytes: fotoBytes,
      fileName: fotoName ?? 'selfie.jpg',
      fileFieldName: 'foto_selfie',
    );
  }
}
