import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../data/api/attendance_api.dart';

class DashboardViewModel extends ChangeNotifier {
  final AttendanceApi _attendanceApi = AttendanceApi(ApiClient());

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _isCheckedIn = false;
  bool get isCheckedIn => _isCheckedIn;

  bool _isCheckedOut = false;
  bool get isCheckedOut => _isCheckedOut;

  String? _checkInTime;
  String? get checkInTime => _checkInTime;

  String? _checkOutTime;
  String? get checkOutTime => _checkOutTime;

  String? _workStart;
  String? get workStart => _workStart;

  String? _workEnd;
  String? get workEnd => _workEnd;

  bool _isOnLeave = false;
  bool get isOnLeave => _isOnLeave;

  Map<String, dynamic>? _leaveDetails;
  Map<String, dynamic>? get leaveDetails => _leaveDetails;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  bool _isOutOfRadiusError = false;
  bool get isOutOfRadiusError => _isOutOfRadiusError;

  /// Mengambil status absensi hari ini dari server.
  Future<void> fetchTodayStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _attendanceApi.getToday();

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      _isCheckedIn = data['is_checked_in'] ?? false;
      _isCheckedOut = data['is_checked_out'] ?? false;
      _checkInTime = data['check_in_time'];
      _checkOutTime = data['check_out_time'];
      _workStart = data['work_start'];
      _workEnd = data['work_end'];
      _isOnLeave = data['is_on_leave'] ?? false;
      _leaveDetails = data['leave_details'];
    } else if (response['status_code'] == 401) {
      _errorMessage = 'Sesi habis, silakan login kembali.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Kirim data absensi (check-in atau check-out).
  Future<bool> submitAttendance({
    required String type,
    required String latitude,
    required String longitude,
    required List<int> fotoBytes,
    String? fotoName,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    _isOutOfRadiusError = false;
    notifyListeners();

    final response = await _attendanceApi.submitAttendance(
      type: type,
      latitude: latitude,
      longitude: longitude,
      fotoBytes: fotoBytes,
      fotoName: fotoName,
    );

    _isSubmitting = false;

    if (response['success'] == true) {
      _successMessage = response['message'] ?? 'Absensi berhasil dicatat.';
      // Refresh status setelah berhasil submit
      await fetchTodayStatus();
      return true;
    } else {
      final errors = response['errors'];
      if (errors != null && errors is Map && errors.isNotEmpty) {
        final firstKey = errors.keys.first;
        final firstMessage = errors[firstKey][0] as String;
        _errorMessage = firstMessage;

        // Deteksi error geofencing (di luar radius kantor)
        if (firstMessage.toLowerCase().contains('radius')) {
          _isOutOfRadiusError = true;
        }
      } else {
        _errorMessage = response['message'] ?? 'Gagal melakukan absensi.';
      }
      notifyListeners();
      return false;
    }
  }
}
