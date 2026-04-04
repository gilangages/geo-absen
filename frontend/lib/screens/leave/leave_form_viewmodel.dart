import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/network/api_client.dart';
import '../../data/api/leave_api.dart';

class LeaveFormViewModel extends ChangeNotifier {
  final LeaveApi _leaveApi = LeaveApi(ApiClient());

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  String _selectedType = 'sakit';
  String get selectedType => _selectedType;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  XFile? _imageFile;
  XFile? get imageFile => _imageFile;

  void setType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (photo != null) {
      _imageFile = photo;
      notifyListeners();
    }
  }

  void clearImage() {
    _imageFile = null;
    notifyListeners();
  }

  Future<bool> submitLeave(String reason) async {
    if (_startDate == null || _endDate == null) {
      _errorMessage = 'Rentang tanggal wajib disetel.';
      notifyListeners();
      return false;
    }
    if (reason.trim().isEmpty) {
      _errorMessage = 'Alasan wajib diisi.';
      notifyListeners();
      return false;
    }
    if (_imageFile == null) {
      _errorMessage = 'File bukti wajib diunggah.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final dateFormatting = DateFormat('yyyy-MM-dd');
      final formattedStart = dateFormatting.format(_startDate!);
      final formattedEnd = dateFormatting.format(_endDate!);
      final bytes = await _imageFile!.readAsBytes();

      final response = await _leaveApi.submitLeave(
        type: _selectedType,
        startDate: formattedStart,
        endDate: formattedEnd,
        reason: reason,
        imageBytes: bytes,
        imageName: _imageFile!.name,
      );

      _isLoading = false;

      if (response['success'] == true) {
        _successMessage = response['message'] ?? 'Pengajuan berhasil dikirim.';
        notifyListeners();
        return true;
      } else {
        final errors = response['errors'];
        if (errors != null && errors is Map && errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          _errorMessage = errors[firstKey][0] as String;
        } else {
          _errorMessage = response['message'] ?? 'Gagal mengirim pengajuan.';
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan sistem.';
      notifyListeners();
      return false;
    }
  }
}
