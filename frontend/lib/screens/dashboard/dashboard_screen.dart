import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dashboard_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardViewModel _viewModel = DashboardViewModel();
  int _currentNavIndex = 0;
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChange);
    _viewModel.fetchTodayStatus();
    // Timer untuk jam hidup yang update setiap detik
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChange() {
    if (mounted) setState(() {});
  }

  /// Meminta izin lokasi dan mengambil koordinat GPS saat ini.
  Future<Position?> _getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Izin lokasi ditolak.', isError: true);
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Izin lokasi ditolak secara permanen.', isError: true);
      return null;
    }
    return await Geolocator.getCurrentPosition();
  }

  /// Membuka kamera untuk mengambil foto selfie.
  /// Catatan: di Web/Chrome, ini akan membuka file picker (limitasi browser).
  /// Di Android/iOS asli, ini akan membuka kamera depan.
  Future<XFile?> _takeSelfie() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    return photo;
  }

  /// Proses utama: ambil lokasi → ambil foto → kirim ke server.
  Future<void> _handleAttendance(String type) async {
    // 1. Ambil lokasi
    final position = await _getCurrentPosition();
    if (position == null) return;

    // 2. Ambil foto selfie
    final foto = await _takeSelfie();
    if (foto == null) {
      _showSnackBar('Foto selfie wajib diambil.', isError: true);
      return;
    }

    // 3. Baca bytes dari foto (kompatibel Web & Mobile)
    final fotoBytes = await foto.readAsBytes();

    // 4. Kirim ke server
    final success = await _viewModel.submitAttendance(
      type: type,
      latitude: position.latitude.toString(),
      longitude: position.longitude.toString(),
      fotoBytes: fotoBytes,
      fotoName: foto.name,
    );

    if (success && _viewModel.successMessage != null) {
      _showSnackBar(_viewModel.successMessage!);
    } else if (_viewModel.errorMessage != null) {
      // Tampilkan dialog khusus jika error karena di luar radius kantor
      if (_viewModel.isOutOfRadiusError) {
        _showOutOfRadiusDialog();
      } else {
        _showSnackBar(_viewModel.errorMessage!, isError: true);
      }
    }
  }

  /// Menampilkan bottom sheet informatif saat user di luar radius kantor.
  void _showOutOfRadiusDialog() {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Ikon peringatan
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                color: Colors.red.shade400,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),

            // Judul
            Text(
              'Di Luar Jangkauan Kantor',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Penjelasan
            Text(
              'Lokasi Anda saat ini berada di luar radius minimum absensi. '
              'Pastikan Anda berada dalam jarak maksimal 100 meter dari kantor '
              'untuk dapat melakukan absensi.',
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Info radius dalam badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.radar_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Radius absensi: 100 meter',
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol tutup
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Mengerti'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormatted = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_now);
    final timeFormatted = DateFormat('HH:mm:ss').format(_now);

    return Scaffold(
      body: SafeArea(
        child: _viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _viewModel.fetchTodayStatus,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo! 👋',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateFormatted,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                          Text(
                            timeFormatted,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Status Cards
                      Row(
                        children: [
                          Expanded(
                            child: _StatusCard(
                              icon: Icons.login_rounded,
                              label: 'Masuk',
                              time: _viewModel.checkInTime ?? '--:--',
                              isActive: _viewModel.isCheckedIn,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatusCard(
                              icon: Icons.logout_rounded,
                              label: 'Pulang',
                              time: _viewModel.checkOutTime ?? '--:--',
                              isActive: _viewModel.isCheckedOut,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // Tombol Raksasa Check In / Check Out
                      if (_viewModel.isOnLeave)
                        _buildLeaveBanner(colorScheme)
                      else ...[
                        Center(child: _buildAttendanceButton(colorScheme)),
                        const SizedBox(height: 16),
                        // Status text di bawah tombol
                        Center(
                          child: Text(
                            _getStatusLabel(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.black54),
                          ),
                        ),
                      ],

                      const SizedBox(height: 48),

                      // Tombol Pengajuan Izin
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/leave/form'),
                          icon: const Icon(Icons.edit_document),
                          label: const Text('Pengajuan Izin / Cuti'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (index) {
          setState(() => _currentNavIndex = index);
          switch (index) {
            case 0:
              break; // Sudah di dashboard
            case 1:
              context.go('/history');
              break;
            case 2:
              context.go('/profile');
              break;
          }
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE9E8F6),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  String _getStatusLabel() {
    if (!_viewModel.isCheckedIn) {
      return 'Kamu belum absen masuk hari ini';
    } else if (!_viewModel.isCheckedOut) {
      return 'Kamu sudah absen masuk, jangan lupa absen pulang!';
    } else {
      return 'Kamu sudah lengkap absen hari ini ✅';
    }
  }

  Widget _buildLeaveBanner(ColorScheme colorScheme) {
    final type = _viewModel.leaveDetails?['type'] ?? 'Izin/Cuti';
    final typeCapitalized = type.toString().replaceFirst(type.toString()[0], type.toString()[0].toUpperCase());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(Icons.event_available_rounded, size: 64, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Sedang $typeCapitalized',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Anda sedang dalam masa izin/cuti. Tombol absensi dinonaktifkan hari ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButton(ColorScheme colorScheme) {
    // Tentukan state tombol
    final bool allDone = _viewModel.isCheckedIn && _viewModel.isCheckedOut;
    final bool isCheckIn = !_viewModel.isCheckedIn;
    final String label = allDone
        ? 'Selesai'
        : isCheckIn
            ? 'Check In'
            : 'Check Out';
    final IconData icon = allDone
        ? Icons.check_circle_outline
        : isCheckIn
            ? Icons.fingerprint
            : Icons.exit_to_app;
    final Color bgColor = allDone
        ? Colors.grey.shade300
        : isCheckIn
            ? colorScheme.primary
            : Colors.orange.shade600;

    return GestureDetector(
      onTap: allDone || _viewModel.isSubmitting
          ? null
          : () => _handleAttendance(isCheckIn ? 'in' : 'out'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: allDone
              ? []
              : [
                  BoxShadow(
                    color: bgColor.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: _viewModel.isSubmitting
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 56, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Widget kartu status kecil  (Masuk / Pulang).
class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final bool isActive;
  final Color color;

  const _StatusCard({
    required this.icon,
    required this.label,
    required this.time,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isActive
            ? color.withOpacity(0.08)
            : const Color(0xFFF7F7FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isActive ? color : Colors.grey, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: isActive ? color : Colors.black38,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
