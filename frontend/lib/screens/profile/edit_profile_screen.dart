import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_profile_viewmodel.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final EditProfileViewModel _viewModel = EditProfileViewModel();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel.init(widget.userData);
    _viewModel.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChange() {
    if (mounted) setState(() {});
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Unfocus keyboard
    FocusScope.of(context).unfocus();

    final success = await _viewModel.saveProfile();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.successMessage ?? 'Profil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop(true); // Return to profile with success flag
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Edit Profil'),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar Section
                  _buildAvatarPicker(colorScheme),
                  const SizedBox(height: 32),

                  // Name Input
                  TextFormField(
                    controller: _viewModel.nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),

                  // Email Input
                  TextFormField(
                    controller: _viewModel.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Position Input (Read-only)
                  TextFormField(
                    initialValue: widget.userData['position'] ?? '-',
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Jabatan (Hanya Admin)',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Change Password Section
                  _buildPasswordSection(colorScheme),
                  const SizedBox(height: 48),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _viewModel.hasChanges ? _handleSave : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Loading Overlay
        if (_viewModel.isSaving)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Menyimpan perubahan...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarPicker(ColorScheme colorScheme) {
    ImageProvider? imageProvider;
    if (_viewModel.newAvatar != null) {
      if (kIsWeb) {
        imageProvider = NetworkImage(_viewModel.newAvatar!.path);
      } else {
        imageProvider = FileImage(File(_viewModel.newAvatar!.path));
      }
    } else if (_viewModel.initialAvatarUrl != null) {
      imageProvider = NetworkImage(_viewModel.initialAvatarUrl!);
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Icon(Icons.person, size: 60, color: colorScheme.primary)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: colorScheme.primary,
              shape: const CircleBorder(),
              elevation: 4,
              child: IconButton(
                onPressed: () => _bottomSheetPick(context),
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: _viewModel.togglePasswordFields,
          icon: Icon(_viewModel.showPasswordFields ? Icons.close : Icons.lock_open),
          label: Text(
            _viewModel.showPasswordFields ? 'Batal Ganti Password' : 'Ingin ganti password?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        if (_viewModel.showPasswordFields) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _viewModel.passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password Baru',
              hintText: 'Minimal 8 karakter',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Isi password';
              if (value.length < 8) return 'Minimal 8 karakter';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _viewModel.passwordConfirmController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Konfirmasi Password',
              prefixIcon: const Icon(Icons.lock_reset),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value != _viewModel.passwordController.text) return 'Password tidak cocok';
              return null;
            },
          ),
        ],
      ],
    );
  }

  void _bottomSheetPick(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Ambil Foto'),
            onTap: () {
              Navigator.pop(ctx);
              _viewModel.pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Dari Galeri'),
            onTap: () {
              Navigator.pop(ctx);
              _viewModel.pickImage(ImageSource.gallery);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
