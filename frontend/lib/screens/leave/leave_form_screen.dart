import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'leave_form_viewmodel.dart';

class LeaveFormScreen extends StatefulWidget {
  const LeaveFormScreen({super.key});

  @override
  State<LeaveFormScreen> createState() => _LeaveFormScreenState();
}

class _LeaveFormScreenState extends State<LeaveFormScreen> {
  final LeaveFormViewModel _viewModel = LeaveFormViewModel();
  final TextEditingController _reasonController = TextEditingController();

  final List<String> _leaveTypes = ['sakit', 'izin', 'cuti'];

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChange() {
    if (mounted) setState(() {});
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 7)), // bisa mundur sikit kalo telat lapor
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _viewModel.startDate != null && _viewModel.endDate != null
          ? DateTimeRange(start: _viewModel.startDate!, end: _viewModel.endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _viewModel.setDateRange(picked.start, picked.end);
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _viewModel.pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _viewModel.pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    // Tutup keyboard
    FocusScope.of(context).unfocus();

    final success = await _viewModel.submitLeave(_reasonController.text);
    
    if (!mounted) return;

    if (success && _viewModel.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.successMessage!),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Kembali ke dashboard jika berhasil
      context.pop();
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan Izin'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tipe Izin
                    Text('Tipe Izin', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _viewModel.selectedType,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: _leaveTypes.map((type) {
                            // Kapitalisasi huruf pertama
                            final label = type.replaceFirst(type[0], type[0].toUpperCase());
                            return DropdownMenuItem(
                              value: type,
                              child: Text(label),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) _viewModel.setType(val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Rentang Tanggal
                    Text('Tanggal Pelaksanaan', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDateRange,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month, color: colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _viewModel.startDate != null && _viewModel.endDate != null
                                    ? '${DateFormat('dd MMM yyyy').format(_viewModel.startDate!)}  -  ${DateFormat('dd MMM yyyy').format(_viewModel.endDate!)}'
                                    : 'Pilih Tanggal Mulai - Selesai',
                                style: TextStyle(
                                  color: _viewModel.startDate != null ? Colors.black87 : Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Alasan
                    Text('Alasan (Catatan)', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 4,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan alasan pengajuan Anda dengan jelas...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bukti Foto
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Foto Bukti (Surat)', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        if (_viewModel.imageFile != null)
                          TextButton.icon(
                            onPressed: _viewModel.clearImage,
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Hapus'),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                          )
                      ],
                    ),
                    const SizedBox(height: 8),
                    _viewModel.imageFile != null
                        ? Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: kIsWeb
                                ? Image.network(_viewModel.imageFile!.path, fit: BoxFit.cover)
                                : Image.file(File(_viewModel.imageFile!.path), fit: BoxFit.cover),
                          )
                        : InkWell(
                            onTap: _showImageSourceActionSheet,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.5), style: BorderStyle.solid),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.upload_file, size: 48, color: colorScheme.primary),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Pilih Foto atau Ambil Gambar',
                                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    
                    const SizedBox(height: 48),

                    // Tombol Submit Raksasa
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _handleSubmit,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Kirim Pengajuan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
