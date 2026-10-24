import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/mock_data.dart';
import '../../models/property_model.dart';
import '../rooms/rooms_screen.dart';
import '../rooms/bed_availability_screen.dart';
import '../settings/settings_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const OwnerDashboardScreen({super.key, this.onLogout});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _selectedPropertyIndex = 0;

  Property get currentProperty => MockData.properties[_selectedPropertyIndex];

  @override
  Widget build(BuildContext context) {
    final property = currentProperty;
    final totalBeds = property.totalBeds;
    final occupiedBeds = property.occupiedBeds;
    final vacantBeds = property.vacantBeds;
    final occupancyPct = property.occupancyRate.toStringAsFixed(1);

    // Calculate pending dues in this property
    double totalDues = 0;
    for (var room in property.rooms) {
      for (var bed in room.beds) {
        if (bed.pendingBalance != null) {
          totalDues += bed.pendingBalance!;
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Owner Portal',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedPropertyIndex,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.textPrimary),
                isDense: true,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPropertyIndex = val);
                },
                items: MockData.properties.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(
                      entry.value.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Bed Availability',
            icon: const Icon(Icons.grid_view_rounded, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BedAvailabilityScreen(property: currentProperty),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Settings & Roles',
            icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(onLogout: widget.onLogout),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(milliseconds: 600)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Type & Address Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        property.type,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        property.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // KPI Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Occupancy Rate',
                      value: '$occupancyPct%',
                      subtext: '$occupiedBeds of $totalBeds beds filled',
                      icon: Icons.pie_chart_outline_rounded,
                      color: AppColors.primary,
                      bgColor: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Available Beds',
                      value: '$vacantBeds',
                      subtext: 'Ready for check-in',
                      icon: Icons.bed_outlined,
                      color: AppColors.vacant,
                      bgColor: AppColors.vacantBg,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BedAvailabilityScreen(
                              property: currentProperty,
                              initialFilter: 'Vacant Only',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Month Collection',
                      value: '₹58,500',
                      subtext: 'October 2026',
                      icon: Icons.payments_outlined,
                      color: const Color(0xFF059669),
                      bgColor: const Color(0xFFECFDF5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Pending Dues',
                      value: '₹${totalDues.toInt()}',
                      subtext: '2 Residents unpaid',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.occupied,
                      bgColor: AppColors.occupiedBg,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Action Buttons
              const Text(
                'Quick Operations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // Rooms Overview Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rooms & Floors',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomsScreen(property: currentProperty),
                        ),
                      );
                    },
                    icon: const Text('View All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    label: const Icon(Icons.arrow_forward_rounded, size: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Room Cards Preview
              ...property.rooms.take(3).map((room) => _buildRoomPreviewTile(context, room)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RoomsScreen(property: currentProperty)),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BedAvailabilityScreen(property: currentProperty)),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen(onLogout: widget.onLogout)),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.meeting_room_outlined), label: 'Rooms'),
          BottomNavigationBarItem(icon: Icon(Icons.hotel_outlined), label: 'Availability'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                if (onTap != null)
                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            Text(
              subtext,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'title': 'Bed Matrix',
        'subtitle': 'Check live vacant beds',
        'icon': Icons.bed_rounded,
        'color': AppColors.vacant,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BedAvailabilityScreen(property: currentProperty)),
            ),
      },
      {
        'title': 'New Resident',
        'subtitle': 'KYC & bed allocate',
        'icon': Icons.person_add_alt_1_rounded,
        'color': AppColors.primary,
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resident Onboarding & KYC flow is up next!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      },
      {
        'title': 'Collect Fee',
        'subtitle': 'Record rent & WhatsApp receipt',
        'icon': Icons.receipt_long_rounded,
        'color': const Color(0xFFD97706),
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fee collection & Digital receipt generator opened'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      },
      {
        'title': 'All Rooms',
        'subtitle': 'Floors & capacities',
        'icon': Icons.door_front_door_outlined,
        'color': const Color(0xFF7C3AED),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RoomsScreen(property: currentProperty)),
            ),
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.9,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: actions.map((item) {
        final color = item['color'] as Color;
        return InkWell(
          onTap: item['onTap'] as VoidCallback,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'] as IconData, size: 20, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['title'] as String,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      Text(
                        item['subtitle'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoomPreviewTile(BuildContext context, Room room) {
    final hasVacancy = room.hasVacancy;
    final badgeColor = hasVacancy ? AppColors.vacant : AppColors.occupied;
    final badgeBg = hasVacancy ? AppColors.vacantBg : AppColors.occupiedBg;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  'Room',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                ),
                Text(
                  room.roomNumber,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${room.sharingCapacity}-Sharing',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    if (room.hasAc)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('AC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0369A1))),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Floor ${room.floorNumber} • ₹${room.rentPerBed.toInt()}/month per bed',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              hasVacancy ? '${room.vacantBedsCount} Bed Available' : 'Full',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: badgeColor),
            ),
          ),
        ],
      ),
    );
  }
}
