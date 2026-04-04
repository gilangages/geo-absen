import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/network/api_client.dart';
import '../../data/api/user_api.dart';

class EditProfileViewModel extends ChangeNotifier {
  final UserApi _userApi = UserApi(ApiClient());
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();

  // Initial Data for checking changes
  String _initialName = '';
  String _initialEmail = '';
  String? _initialAvatarUrl;
  String? get initialAvatarUrl => _initialAvatarUrl;

  // New Avatar
  XFile? _newAvatar;
  XFile? get newAvatar => _newAvatar;

  // Password Toggle
  bool _showPasswordFields = false;
  bool get showPasswordFields => _showPasswordFields;

  void togglePasswordFields() {
    _showPasswordFields = !_showPasswordFields;
    if (!_showPasswordFields) {
      passwordController.clear();
      passwordConfirmController.clear();
    }
    notifyListeners();
  }

  /// Initialize with current data
  void init(Map<String, dynamic> user) {
    _initialName = user['name'] ?? '';
    _initialEmail = user['email'] ?? '';
    _initialAvatarUrl = user['avatar_url'];
    
    nameController.text = _initialName;
    emailController.text = _initialEmail;
    
    // Listen to changes to update UI (Simpan button)
    nameController.addListener(_onFieldChanged);
    emailController.addListener(_onFieldChanged);
    passwordController.addListener(_onFieldChanged);
    passwordConfirmController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    notifyListeners();
  }

  /// Check if there are any changes
  bool get hasChanges {
    bool nameChanged = nameController.text != _initialName;
    bool emailChanged = emailController.text != _initialEmail;
    bool avatarChanged = _newAvatar != null;
    bool passwordFilled = _showPasswordFields && passwordController.text.isNotEmpty;

    return nameChanged || emailChanged || avatarChanged || passwordFilled;
  }

  /// Pick image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        _newAvatar = pickedFile;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Gagal mengambil gambar: $e';
      notifyListeners();
    }
  }

  /// Save changes to server
  Future<bool> saveProfile() async {
    if (!hasChanges) return false;

    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      List<int>? avatarBytes;
      if (_newAvatar != null) {
        avatarBytes = await _newAvatar!.readAsBytes();
      }

      final response = await _userApi.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: _showPasswordFields ? passwordController.text : null,
        passwordConfirmation: _showPasswordFields ? passwordConfirmController.text : null,
        avatarBytes: avatarBytes,
        avatarName: _newAvatar?.name,
      );

      if (response['success'] == true) {
        _successMessage = response['message'] ?? 'Profil berhasil diperbarui.';
        _isSaving = false;
        notifyListeners();
        return true;
      } else {
        final errors = response['errors'];
        if (errors != null && errors is Map && errors.isNotEmpty) {
          _errorMessage = errors.values.first[0];
        } else {
          _errorMessage = response['message'] ?? 'Gagal memperbarui profil.';
        }
        _isSaving = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nameController.removeListener(_onFieldChanged);
    emailController.removeListener(_onFieldChanged);
    passwordController.removeListener(_onFieldChanged);
    passwordConfirmController.removeListener(_onFieldChanged);
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }
}
