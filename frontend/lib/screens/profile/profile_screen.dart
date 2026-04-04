import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileViewModel _viewModel = ProfileViewModel();
  bool _imageLoadFailed = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChange);
    _viewModel.fetchProfile();
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

  Future<void> _handleLogout() async {
    // Konfirmasi dulu sebelum logout
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _viewModel.logout();
      if (success && mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final userData = {
                'name': _viewModel.name,
                'email': _viewModel.email,
                'position': _viewModel.position,
                'avatar_url': _viewModel.avatarUrl,
              };
              final updated = await context.push('/profile/edit', extra: userData);
              if (updated == true) {
                _viewModel.fetchProfile();
              }
            },
            tooltip: 'Edit Profil',
          ),
        ],
      ),
      body: SafeArea(
        child: _viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Builder(
                builder: (context) {
                  final colorScheme = Theme.of(context).colorScheme;
                  return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Avatar dengan error handler untuk CORS di web
                    _buildAvatar(colorScheme),
                    const SizedBox(height: 20),

                    // Nama
                    Text(
                      _viewModel.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),

                    // Jabatan
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _viewModel.position,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Info items
                    _ProfileInfoTile(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: _viewModel.email,
                    ),
                    const SizedBox(height: 12),
                    _ProfileInfoTile(
                      icon: Icons.badge_outlined,
                      label: 'Jabatan',
                      value: _viewModel.position,
                    ),
                    const SizedBox(height: 40),

                    // Tombol Logout
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed:
                            _viewModel.isLoggingOut ? null : _handleLogout,
                        icon: _viewModel.isLoggingOut
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Icon(Icons.logout, color: Colors.red),
                        label: Text(
                          _viewModel.isLoggingOut ? 'Logging out...' : 'Logout',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2, // Tab Profil aktif
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/history');
              break;
            case 2:
              break; // Sudah di profile
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

  /// Membangun widget avatar dengan error handling (untuk CORS di web).
  Widget _buildAvatar(ColorScheme colorScheme) {
    final showImage = _viewModel.avatarUrl != null && !_imageLoadFailed;

    return CircleAvatar(
      radius: 56,
      backgroundColor: const Color(0xFFE9E8F6),
      child: showImage
          ? ClipOval(
              child: Image.network(
                _viewModel.avatarUrl!,
                width: 112,
                height: 112,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Jika gambar gagal (CORS, 404, dsb), fallback ke inisial
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && !_imageLoadFailed) {
                      setState(() => _imageLoadFailed = true);
                    }
                  });
                  return _buildInitials(colorScheme);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    width: 112,
                    height: 112,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            )
          : _buildInitials(colorScheme),
    );
  }

  Widget _buildInitials(ColorScheme colorScheme) {
    return Text(
      _getInitials(_viewModel.name),
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
      ),
    );
  }

  /// Mengambil inisial dari nama (misal: "Budi Santoso" → "BS").
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

/// Tile informasi profil (email, jabatan).
class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
