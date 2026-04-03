import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../data/api/attendance_api.dart';

class HistoryViewModel extends ChangeNotifier {
  final AttendanceApi _attendanceApi = AttendanceApi(ApiClient());

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _attendances = [];
  List<Map<String, dynamic>> get attendances => _attendances;

  int _selectedMonth = DateTime.now().month;
  int get selectedMonth => _selectedMonth;

  int _selectedYear = DateTime.now().year;
  int get selectedYear => _selectedYear;

  /// Mengambil riwayat absensi sesuai bulan & tahun yang dipilih.
  Future<void> fetchHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final month = _selectedMonth.toString().padLeft(2, '0');
    final year = _selectedYear.toString();

    final response = await _attendanceApi.getHistory(
      month: month,
      year: year,
    );

    if (response['success'] == true && response['data'] != null) {
      _attendances = List<Map<String, dynamic>>.from(response['data']);
    } else if (response['status_code'] == 401) {
      _errorMessage = 'Sesi habis, silakan login kembali.';
    } else {
      _attendances = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Ganti bulan filter dan refresh data.
  void changeMonth(int month) {
    _selectedMonth = month;
    fetchHistory();
  }

  /// Ganti tahun filter dan refresh data.
  void changeYear(int year) {
    _selectedYear = year;
    fetchHistory();
  }
}
