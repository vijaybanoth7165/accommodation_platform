import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/mock_data.dart';
import '../../models/property_model.dart';
import '../../models/resident_model.dart';
import 'resident_onboarding_screen.dart';

class ResidentsListScreen extends StatefulWidget {
  final Property? property;

  const ResidentsListScreen({super.key, this.property});

  @override
  State<ResidentsListScreen> createState() => _ResidentsListScreenState();
}

class _ResidentsListScreenState extends State<ResidentsListScreen> {
  String _searchQuery = '';
  String _filter = 'All Active'; // 'All Active', 'With Dues', 'Vacated'

  List<Resident> get filteredResidents {
    return MockData.residents.where((r) {
      // Property filter if provided
      if (widget.property != null && r.propertyId != widget.property!.id) {
        return false;
      }

      // Status filter
      if (_filter == 'All Active' && r.isVacated) return false;
      if (_filter == 'With Dues' && (!r.hasPendingDues || r.isVacated)) return false;
      if (_filter == 'Vacated' && !r.isVacated) return false;

      // Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = r.name.toLowerCase().contains(q);
        final matchPhone = r.phone.contains(q);
        final matchRoom = r.roomNumber.toLowerCase().contains(q);
        return matchName || matchPhone || matchRoom;
      }

      return true;
    }).toList();
  }

  void _showResidentProfileModal(Resident resident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Avatar & Name Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            resident.name.isNotEmpty ? resident.name[0] : 'R',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resident.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Room ${resident.roomNumber} (${resident.bedCode}) • ${resident.propertyName}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: resident.isVacated ? AppColors.maintenanceBg : AppColors.vacantBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  resident.isVacated ? 'Vacated Alumni' : 'Active Resident',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: resident.isVacated ? AppColors.maintenance : AppColors.vacant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Financial Summary Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Monthly Rent:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text('₹${resident.monthlyRent.toInt()} / month', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Security Deposit:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text('₹${resident.securityDeposit.toInt()} (Held Safe)', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Outstanding Dues:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text(
                                '₹${resident.pendingBalance.toInt()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: resident.pendingBalance > 0 ? AppColors.occupied : AppColors.vacant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contact & Emergency Information
                    _buildInfoTile(Icons.phone_outlined, 'Mobile Number', '+91 ${resident.phone}'),
                    _buildInfoTile(Icons.email_outlined, 'Email', resident.email.isNotEmpty ? resident.email : 'N/A'),
                    _buildInfoTile(Icons.family_restroom_rounded, 'Emergency Contact', '${resident.guardianName} (${resident.guardianRelation}) • +91 ${resident.guardianPhone}'),
                    _buildInfoTile(Icons.home_outlined, 'Permanent Address', resident.permanentAddress.isNotEmpty ? resident.permanentAddress : 'N/A'),
                    _buildInfoTile(Icons.badge_outlined, 'KYC ID Proof', '${resident.idProofType} (${resident.idProofNumber})'),

                    const SizedBox(height: 20),

                    // Action Buttons Row
                    if (!resident.isVacated) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _sendWhatsAppReminder(resident);
                              },
                              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                              label: const Text('Send Reminder'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _showCollectFeeModal(resident);
                              },
                              icon: const Icon(Icons.payments_outlined, size: 16),
                              label: const Text('Collect Fee'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.occupied,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showVacateConfirmation(resident);
                        },
                        icon: const Icon(Icons.exit_to_app_rounded, size: 16),
                        label: const Text('Vacate Bed & Settle Deposit'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendWhatsAppReminder(Resident resident) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('WhatsApp payment reminder sent to ${resident.name} (+91 ${resident.phone})'),
        backgroundColor: const Color(0xFF128C7E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCollectFeeModal(Resident resident) {
    final amountController = TextEditingController(
      text: resident.pendingBalance > 0
          ? resident.pendingBalance.toInt().toString()
          : resident.monthlyRent.toInt().toString(),
    );
    PaymentMode selectedMode = PaymentMode.upi;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Collect Fee from ${resident.name}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  Text('Room ${resident.roomNumber} • Pending Dues: ₹${resident.pendingBalance.toInt()}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Collection Amount (₹)',
                      prefixText: '₹ ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PaymentMode>(
                    value: selectedMode,
                    decoration: const InputDecoration(labelText: 'Payment Mode'),
                    items: const [
                      DropdownMenuItem(value: PaymentMode.upi, child: Text('UPI / GPay / PhonePe')),
                      DropdownMenuItem(value: PaymentMode.cash, child: Text('Cash')),
                      DropdownMenuItem(value: PaymentMode.bankTransfer, child: Text('Bank Transfer / NEFT')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedMode = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final collected = double.tryParse(amountController.text.trim()) ?? 0;
                      setState(() {
                        if (collected >= resident.pendingBalance) {
                          resident.pendingBalance = 0;
                        } else {
                          resident.pendingBalance -= collected;
                        }

                        final tx = PaymentTransaction(
                          id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
                          receiptNumber: 'REC-FEE-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                          date: DateTime.now(),
                          amount: collected,
                          type: PaymentType.rent,
                          mode: selectedMode,
                          notes: 'Monthly fee payment collected',
                        );
                        resident.transactions.insert(0, tx);
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Recorded ₹${collected.toInt()} collection for ${resident.name}'),
                          backgroundColor: AppColors.vacant,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Confirm Payment & Generate Receipt'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showVacateConfirmation(Resident resident) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Vacate Bed ${resident.bedCode}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to mark ${resident.name} as vacated?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Security Deposit:'),
                        Text('₹${resident.securityDeposit.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pending Dues:'),
                        Text('-₹${resident.pendingBalance.toInt()}', style: const TextStyle(color: AppColors.occupied)),
                      ],
                    ),
                    const Divider(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Net Refund:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('₹${(resident.securityDeposit - resident.pendingBalance).toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This will release Bed ${resident.bedCode} back to 🟢 Available while keeping resident records in history.',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.occupied),
              onPressed: () {
                setState(() {
                  MockData.vacateResident(resident.id);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${resident.name} vacated. Bed ${resident.bedCode} is now Available!'),
                    backgroundColor: AppColors.vacant,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Confirm Vacate'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final residents = filteredResidents;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Residents Directory & KYC'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: AppColors.primary),
            tooltip: 'Add Resident',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResidentOnboardingScreen(preselectedProperty: widget.property),
                ),
              );
              if (result == true) setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, room number, or phone...',
                prefixIcon: const Icon(Icons.search_rounded),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: ['All Active', 'With Dues', 'Vacated'].map((filter) {
                final isSelected = _filter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _filter = filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Residents List
          Expanded(
            child: residents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_off_outlined, size: 48, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text('No residents found matching criteria', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: residents.length,
                    itemBuilder: (context, index) {
                      final resident = residents[index];
                      return _buildResidentCard(resident);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResidentOnboardingScreen(preselectedProperty: widget.property),
            ),
          );
          if (result == true) setState(() {});
        },
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add Resident', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildResidentCard(Resident resident) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => _showResidentProfileModal(resident),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: resident.isVacated ? AppColors.maintenanceBg : AppColors.primaryLight,
          child: Text(
            resident.name.isNotEmpty ? resident.name[0] : 'R',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: resident.isVacated ? AppColors.maintenance : AppColors.primary,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                resident.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            if (resident.hasPendingDues)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.occupiedBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Due ₹${resident.pendingBalance.toInt()}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.occupied),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              'Room ${resident.roomNumber} (${resident.bedCode}) • +91 ${resident.phone}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              'Joined: ${resident.joiningDate} • Rent: ₹${resident.monthlyRent.toInt()}/mo',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      ),
    );
  }
}
