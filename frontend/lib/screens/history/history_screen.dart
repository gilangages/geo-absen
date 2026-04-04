import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'history_viewmodel.dart';
import 'leave_history_viewmodel.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryViewModel _viewModel = HistoryViewModel();
  final LeaveHistoryViewModel _leaveViewModel = LeaveHistoryViewModel();

  /// Nama bulan dalam Bahasa Indonesia.
  static const List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChange);
    _leaveViewModel.addListener(_onViewModelChange);
    _viewModel.fetchHistory();
    _leaveViewModel.fetchHistory();
  }

  @override
  void dispose() {
    _leaveViewModel.removeListener(_onViewModelChange);
    _leaveViewModel.dispose();
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & TabBar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riwayat',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TabBar(
                      labelColor: colorScheme.primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: colorScheme.primary,
                      tabs: const [
                        Tab(text: 'Absensi'),
                        Tab(text: 'Izin / Cuti'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // TabBar View Content
              Expanded(
                child: TabBarView(
                  children: [
                    _buildAttendanceHistoryTab(colorScheme),
                    _buildLeaveHistoryTab(colorScheme),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: 1, // Tab Riwayat aktif
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go('/dashboard');
                break;
              case 1:
                break; // Sudah di history
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
      ),
    );
  }

  Widget _buildAttendanceHistoryTab(ColorScheme colorScheme) {
    return Column(
      children: [
        // Month/Year Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              // Bulan
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _viewModel.selectedMonth,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.primary),
                      items: List.generate(12, (i) {
                        return DropdownMenuItem(
                          value: i + 1,
                          child: Text(_monthNames[i]),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) _viewModel.changeMonth(value);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Tahun
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7FC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _viewModel.selectedYear,
                    icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.primary),
                    items: List.generate(3, (i) {
                      final year = DateTime.now().year - i;
                      return DropdownMenuItem(
                        value: year,
                        child: Text('$year'),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) _viewModel.changeYear(value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Content
        Expanded(
          child: _viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _viewModel.attendances.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada riwayat absensi',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _viewModel.fetchHistory,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: _viewModel.attendances.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _viewModel.attendances[index];
                          return _AttendanceCard(item: item);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildLeaveHistoryTab(ColorScheme colorScheme) {
    if (_leaveViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_leaveViewModel.leaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_document, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat izin/cuti',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _leaveViewModel.fetchHistory,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        itemCount: _leaveViewModel.leaves.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _leaveViewModel.leaves[index];
          return _LeaveCard(item: item);
        },
      ),
    );
  }
}

/// Kartu untuk satu entri riwayat absensi.
class _AttendanceCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _AttendanceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final date = item['date'] ?? '-';
    final checkIn = item['check_in_time'] ?? '--:--';
    final checkOut = item['check_out_time'] ?? '--:--';
    final status = item['status'] ?? 'unknown';

    // Format tanggal
    String formattedDate = date;
    try {
      final parsed = DateTime.parse(date);
      formattedDate = DateFormat('EEEE, d MMM', 'id_ID').format(parsed);
    } catch (_) {}

    // Warna dan label status
    final (Color statusColor, String statusLabel) = switch (status) {
      'present' => (Colors.green, 'Hadir'),
      'late' => (Colors.orange, 'Terlambat'),
      'absent' => (Colors.red, 'Absen'),
      _ => (Colors.grey, status.toString()),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),

          // Tanggal + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Jam masuk & pulang
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login, size: 14, color: Colors.green.shade400),
                  const SizedBox(width: 4),
                  Text(
                    checkIn,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, size: 14, color: Colors.orange.shade400),
                  const SizedBox(width: 4),
                  Text(
                    checkOut,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: checkOut == '--:--' ? Colors.black38 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kartu untuk satu entri riwayat izin/cuti.
class _LeaveCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _LeaveCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final type = item['type'] ?? 'Izin';
    final typeCap = type.toString().replaceFirst(type.toString()[0], type.toString()[0].toUpperCase());
    final start = item['start_date'] ?? '-';
    final end = item['end_date'] ?? '-';
    final reason = item['reason'] ?? '-';
    final status = item['status'] ?? 'pending';
    final note = item['note_admin'];

    // Format tanggal
    String dateRange = start == end ? start : '$start s/d $end';
    try {
      final parsedStart = DateTime.parse(start);
      final parsedEnd = DateTime.parse(end);
      final formatter = DateFormat('d MMM', 'id_ID');
      dateRange = parsedStart == parsedEnd 
          ? formatter.format(parsedStart)
          : '${formatter.format(parsedStart)} - ${formatter.format(parsedEnd)}';
    } catch (_) {}

    final (Color statusColor, String statusLabel) = switch (status) {
      'approved' => (Colors.green, 'Disetujui'),
      'rejected' => (Colors.red, 'Ditolak'),
      _ => (Colors.orange, 'Menunggu'), // pending
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengajuan $typeCap',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(dateRange, style: TextStyle(color: Colors.grey.shade800, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(reason, style: TextStyle(color: Colors.grey.shade800, fontSize: 13)),
              ),
            ],
          ),
          if (status == 'rejected' && note != null && note.toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Catatan Admin: $note',
                style: TextStyle(color: Colors.red.shade800, fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
