import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../data/api/leave_api.dart';

class LeaveHistoryViewModel extends ChangeNotifier {
  final LeaveApi _leaveApi = LeaveApi(ApiClient());

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _leaves = [];
  List<Map<String, dynamic>> get leaves => _leaves;

  Future<void> fetchHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _leaveApi.getAll();

    if (response['success'] == true && response['data'] != null) {
      _leaves = List<Map<String, dynamic>>.from(response['data']);
    } else if (response['status_code'] == 401) {
      _errorMessage = 'Sesi habis, silakan login kembali.';
    } else {
      _errorMessage = response['message'] ?? 'Gagal memuat riwayat izin.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
