import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/property_model.dart';

class BedAvailabilityScreen extends StatefulWidget {
  final Property property;
  final String? initialFilter;

  const BedAvailabilityScreen({
    super.key,
    required this.property,
    this.initialFilter,
  });

  @override
  State<BedAvailabilityScreen> createState() => _BedAvailabilityScreenState();
}

class _BedAvailabilityScreenState extends State<BedAvailabilityScreen> {
  late String _activeFilter;

  @override
  void initState() {
    super.initState();
    _activeFilter = widget.initialFilter ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final totalBeds = property.totalBeds;
    final vacantBeds = property.vacantBeds;
    final occupiedBeds = property.occupiedBeds;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Bed Availability Matrix'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showLegendDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Stats Counter Bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryPill(
                    label: 'Available',
                    count: '$vacantBeds',
                    color: AppColors.vacant,
                    bgColor: AppColors.vacantBg,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryPill(
                    label: 'Occupied',
                    count: '$occupiedBeds',
                    color: AppColors.occupied,
                    bgColor: AppColors.occupiedBg,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryPill(
                    label: 'Total Beds',
                    count: '$totalBeds',
                    color: AppColors.primary,
                    bgColor: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Filter Segmented Row
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Vacant Only', 'Occupied', 'With Pending Balance'].map((filter) {
                  final isSelected = _activeFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _activeFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Bed Matrix by Room
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: property.rooms.length,
              itemBuilder: (context, index) {
                final room = property.rooms[index];
                final matchingBeds = room.beds.where((b) {
                  if (_activeFilter == 'Vacant Only') return b.isVacant;
                  if (_activeFilter == 'Occupied') return b.isOccupied;
                  if (_activeFilter == 'With Pending Balance') {
                    return b.isOccupied && (b.pendingBalance != null && b.pendingBalance! > 0);
                  }
                  return true;
                }).toList();

                if (matchingBeds.isEmpty) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room Header Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Room ${room.roomNumber}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• Floor ${room.floorNumber} (${room.sharingCapacity}-Sharing)',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const Spacer(),
                            Text(
                              '₹${room.rentPerBed.toInt()}/mo',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bed Grid inside Room
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.45,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: matchingBeds.length,
                          itemBuilder: (context, bedIndex) {
                            final bed = matchingBeds[bedIndex];
                            return _buildBedTile(context, room, bed);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPill({
    required String label,
    required String count,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBedTile(BuildContext context, Room room, Bed bed) {
    Color borderColor;
    Color bgColor;
    Color statusColor;
    String statusText;

    if (bed.isVacant) {
      borderColor = AppColors.vacant.withOpacity(0.4);
      bgColor = AppColors.vacantBg;
      statusColor = AppColors.vacant;
      statusText = 'VACANT';
    } else if (bed.isOccupied) {
      final hasBalance = bed.pendingBalance != null && bed.pendingBalance! > 0;
      borderColor = hasBalance ? AppColors.occupied : AppColors.border;
      bgColor = AppColors.surface;
      statusColor = hasBalance ? AppColors.occupied : AppColors.textSecondary;
      statusText = hasBalance ? 'DUE ₹${bed.pendingBalance!.toInt()}' : 'OCCUPIED';
    } else {
      borderColor = AppColors.reserved;
      bgColor = AppColors.reservedBg;
      statusColor = AppColors.reserved;
      statusText = 'RESERVED';
    }

    return InkWell(
      onTap: () => _handleBedTap(context, room, bed),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bed.code,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            if (bed.isOccupied) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bed.residentName ?? 'Resident',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  Text(
                    bed.residentPhone ?? '',
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ] else if (bed.isVacant) ...[
              Row(
                children: const [
                  Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.vacant),
                  SizedBox(width: 4),
                  Text(
                    'Tap to Allocate',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.vacant),
                  ),
                ],
              ),
            ] else ...[
              Text(
                bed.residentName ?? 'Reserved',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.reserved),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleBedTap(BuildContext context, Room room, Bed bed) {
    if (bed.isVacant) {
      _showAllocateModal(context, room, bed);
    } else {
      _showResidentDetailsModal(context, room, bed);
    }
  }

  void _showAllocateModal(BuildContext context, Room room, Bed bed) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.vacantBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bed_rounded, color: AppColors.vacant),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Allocate ${bed.code}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Room ${room.roomNumber} • ${room.sharingCapacity}-Sharing (Floor ${room.floorNumber})',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Agreed Monthly Fee:', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('₹${room.rentPerBed.toInt()} / month', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening onboarding form for ${bed.code}...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Add Resident & KYC Details'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResidentDetailsModal(BuildContext context, Room room, Bed bed) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      bed.residentName != null ? bed.residentName![0] : 'R',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bed.residentName ?? 'Resident',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${bed.code} • Room ${room.roomNumber}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Phone:'),
                        Text(bed.residentPhone ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Joined:'),
                        Text(bed.joiningDate ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pending Balance:'),
                        Text(
                          '₹${(bed.pendingBalance ?? 0).toInt()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (bed.pendingBalance ?? 0) > 0 ? AppColors.occupied : AppColors.vacant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('WhatsApp payment reminder sent to ${bed.residentName}'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                      label: const Text('Reminder'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.occupied,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Vacating workflow initiated for ${bed.residentName}. Bed ${bed.code} will be released after deposit settlement.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.exit_to_app_rounded, size: 18),
                      label: const Text('Vacate Bed'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLegendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bed Status Legend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _legendItem(AppColors.vacant, 'Vacant', 'Ready for new resident allocation'),
            const SizedBox(height: 8),
            _legendItem(AppColors.occupied, 'Occupied with Due', 'Resident has pending monthly balance'),
            const SizedBox(height: 8),
            _legendItem(AppColors.textSecondary, 'Occupied (Cleared)', 'Monthly fee fully settled'),
            const SizedBox(height: 8),
            _legendItem(AppColors.reserved, 'Reserved', 'Token advance paid, joining soon'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String title, String desc) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
