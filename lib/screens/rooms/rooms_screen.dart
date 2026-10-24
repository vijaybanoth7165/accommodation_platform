import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/property_model.dart';
import 'bed_availability_screen.dart';

class RoomsScreen extends StatefulWidget {
  final Property property;

  const RoomsScreen({super.key, required this.property});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  int? _selectedFloorFilter; // null = all floors
  int? _selectedSharingFilter; // null = all sharings

  List<Room> get filteredRooms {
    return widget.property.rooms.where((room) {
      final matchesFloor = _selectedFloorFilter == null || room.floorNumber == _selectedFloorFilter;
      final matchesSharing = _selectedSharingFilter == null || room.sharingCapacity == _selectedSharingFilter;
      return matchesFloor && matchesSharing;
    }).toList();
  }

  // Extract distinct floors in this property
  List<int> get floors {
    final floorSet = widget.property.rooms.map((r) => r.floorNumber).toSet().toList();
    floorSet.sort();
    return floorSet;
  }

  @override
  Widget build(BuildContext context) {
    final rooms = filteredRooms;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rooms & Sharing Config'),
            Text(
              widget.property.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            tooltip: 'Add New Room',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Room creation form will allow setting floor, sharing capacity, & rent'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips (Floors & Sharing)
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Floors'),
                    selected: _selectedFloorFilter == null,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFloorFilter = null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ...floors.map((fl) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('Floor $fl'),
                          selected: _selectedFloorFilter == fl,
                          onSelected: (selected) {
                            setState(() => _selectedFloorFilter = selected ? fl : null);
                          },
                        ),
                      )),
                  const SizedBox(width: 8),
                  // Sharing filters
                  ...[1, 2, 3, 4].map((sharing) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('$sharing-Share'),
                          selected: _selectedSharingFilter == sharing,
                          onSelected: (selected) {
                            setState(() => _selectedSharingFilter = selected ? sharing : null);
                          },
                        ),
                      )),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Room List
          Expanded(
            child: rooms.isEmpty
                ? const Center(
                    child: Text('No rooms match the selected filters'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return _buildRoomCard(room);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BedAvailabilityScreen(property: widget.property),
            ),
          );
        },
        icon: const Icon(Icons.hotel_rounded, color: Colors.white),
        label: const Text('View Bed Matrix', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      room.roomNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
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
                            '${room.sharingCapacity}-Sharing Room',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (room.hasAc)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('AC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Floor ${room.floorNumber} • ₹${room.rentPerBed.toInt()} / bed / month',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: room.hasVacancy ? AppColors.vacantBg : AppColors.occupiedBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    room.hasVacancy ? '${room.vacantBedsCount} Bed Available' : 'Full',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: room.hasVacancy ? AppColors.vacant : AppColors.occupied,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Bed Status Indicators inside this Room
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: room.beds.map((bed) {
                Color chipColor;
                Color chipBg;
                IconData chipIcon;

                switch (bed.status) {
                  case BedStatus.vacant:
                    chipColor = AppColors.vacant;
                    chipBg = AppColors.vacantBg;
                    chipIcon = Icons.check_circle_outline_rounded;
                    break;
                  case BedStatus.occupied:
                    chipColor = AppColors.occupied;
                    chipBg = AppColors.occupiedBg;
                    chipIcon = Icons.person_rounded;
                    break;
                  case BedStatus.reserved:
                    chipColor = AppColors.reserved;
                    chipBg = AppColors.reservedBg;
                    chipIcon = Icons.access_time_rounded;
                    break;
                  case BedStatus.maintenance:
                    chipColor = AppColors.maintenance;
                    chipBg = AppColors.maintenanceBg;
                    chipIcon = Icons.handyman_outlined;
                    break;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: chipColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(chipIcon, size: 14, color: chipColor),
                      const SizedBox(width: 6),
                      Text(
                        bed.code,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: chipColor,
                        ),
                      ),
                      if (bed.isOccupied && bed.residentName != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${bed.residentName!.split(' ').first})',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
