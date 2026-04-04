import '../../core/network/api_client.dart';

class LeaveApi {
  final ApiClient _apiClient;

  LeaveApi(this._apiClient);

  /// Mengambil riwayat pengajuan izin/cuti
  Future<Map<String, dynamic>> getAll() async {
    return await _apiClient.get('/leaves');
  }

  /// Mengirim pengajuan izin/cuti baru berupa multipart form-data
  Future<Map<String, dynamic>> submitLeave({
    required String type,
    required String startDate,
    required String endDate,
    required String reason,
    required List<int> imageBytes,
    required String imageName,
  }) async {
    return await _apiClient.multipartPost(
      '/leaves',
      fields: {
        'type': type,
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
      },
      fileBytes: imageBytes,
      fileName: imageName,
      fileFieldName: 'image_proof',
    );
  }
}
