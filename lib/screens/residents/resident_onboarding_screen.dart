import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/mock_data.dart';
import '../../models/property_model.dart';
import '../../models/resident_model.dart';
import 'whatsapp_receipt_modal.dart';

class ResidentOnboardingScreen extends StatefulWidget {
  final Property? preselectedProperty;
  final Room? preselectedRoom;
  final Bed? preselectedBed;

  const ResidentOnboardingScreen({
    super.key,
    this.preselectedProperty,
    this.preselectedRoom,
    this.preselectedBed,
  });

  @override
  State<ResidentOnboardingScreen> createState() => _ResidentOnboardingScreenState();
}

class _ResidentOnboardingScreenState extends State<ResidentOnboardingScreen> {
  int _currentStep = 0;

  // Controllers - Step 1: Personal
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController(text: '12-08-2001');
  final _bloodGroupController = TextEditingController(text: 'B+');
  final _vehicleController = TextEditingController();

  // Controllers - Step 2: Guardian & Address
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  String _guardianRelation = 'Father';
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController(text: 'Karnataka');
  final _pincodeController = TextEditingController();

  // Controllers - Step 3: KYC
  String _idType = 'Aadhaar Card';
  final _idNumberController = TextEditingController();
  bool _photoUploaded = false;
  bool _idFrontUploaded = false;
  bool _idBackUploaded = false;

  // Controllers - Step 4: Allocation & Finances
  late Property _selectedProperty;
  Room? _selectedRoom;
  Bed? _selectedBed;

  final _rentController = TextEditingController();
  final _depositController = TextEditingController(text: '10000');
  final _initialPaidController = TextEditingController();
  PaymentMode _paymentMode = PaymentMode.upi;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedProperty = widget.preselectedProperty ?? MockData.properties.first;

    if (widget.preselectedRoom != null) {
      _selectedRoom = widget.preselectedRoom;
    } else {
      final availableRooms = _selectedProperty.rooms.where((r) => r.hasVacancy).toList();
      if (availableRooms.isNotEmpty) _selectedRoom = availableRooms.first;
    }

    if (widget.preselectedBed != null) {
      _selectedBed = widget.preselectedBed;
    } else if (_selectedRoom != null) {
      final vacantBeds = _selectedRoom!.beds.where((b) => b.isVacant).toList();
      if (vacantBeds.isNotEmpty) _selectedBed = vacantBeds.first;
    }

    _updateRentFromSelection();
  }

  void _updateRentFromSelection() {
    if (_selectedRoom != null) {
      _rentController.text = _selectedRoom!.rentPerBed.toInt().toString();
      _calculateInitialTotals();
    }
  }

  void _calculateInitialTotals() {
    final rent = double.tryParse(_rentController.text.trim()) ?? 0;
    final deposit = double.tryParse(_depositController.text.trim()) ?? 0;
    // Default initial paid to rent + deposit
    _initialPaidController.text = (rent + deposit).toInt().toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _bloodGroupController.dispose();
    _vehicleController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _idNumberController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _initialPaidController.dispose();
    super.dispose();
  }

  void _fillSampleResidentData() {
    setState(() {
      _nameController.text = 'Kavya Sundaram';
      _phoneController.text = '9876543999';
      _emailController.text = 'kavya.s@gmail.com';
      _guardianNameController.text = 'Sundaram Raman';
      _guardianPhoneController.text = '9876500888';
      _addressController.text = '#104, 3rd Cross, Indiranagar';
      _cityController.text = 'Bengaluru';
      _pincodeController.text = '560038';
      _idNumberController.text = '4920-8812-7734';
      _photoUploaded = true;
      _idFrontUploaded = true;
      _idBackUploaded = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sample resident & KYC details pre-filled for quick testing!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _completeOnboarding() {
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill resident Name and Phone Number'),
          backgroundColor: AppColors.occupied,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedRoom == null || _selectedBed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an available Room and Bed'),
          backgroundColor: AppColors.occupied,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final monthlyRent = double.tryParse(_rentController.text.trim()) ?? _selectedRoom!.rentPerBed;
    final securityDeposit = double.tryParse(_depositController.text.trim()) ?? 10000;
    final initialPaid = double.tryParse(_initialPaidController.text.trim()) ?? (monthlyRent + securityDeposit);
    final totalDue = monthlyRent + securityDeposit;
    final pendingBalance = (totalDue > initialPaid) ? (totalDue - initialPaid) : 0.0;

    final receiptNumber = 'REC-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    final initialTransaction = PaymentTransaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      receiptNumber: receiptNumber,
      date: DateTime.now(),
      amount: initialPaid,
      type: PaymentType.rent,
      mode: _paymentMode,
      referenceNumber: _paymentMode == PaymentMode.upi ? 'UPI/${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}' : null,
      notes: 'Initial Onboarding: Rent (₹${monthlyRent.toInt()}) + Deposit (₹${securityDeposit.toInt()})',
    );

    final newResident = Resident(
      id: 'res-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      bloodGroup: _bloodGroupController.text.trim(),
      vehicleNumber: _vehicleController.text.trim(),
      guardianName: _guardianNameController.text.trim(),
      guardianPhone: _guardianPhoneController.text.trim(),
      guardianRelation: _guardianRelation,
      permanentAddress: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      idProofType: _idType,
      idProofNumber: _idNumberController.text.trim(),
      hasPhoto: _photoUploaded,
      hasIdProofDocument: _idFrontUploaded && _idBackUploaded,
      propertyId: _selectedProperty.id,
      propertyName: _selectedProperty.name,
      roomNumber: _selectedRoom!.roomNumber,
      bedCode: _selectedBed!.code,
      joiningDate: 'Today (${DateTime.now().day} Nov ${DateTime.now().year})',
      monthlyRent: monthlyRent,
      securityDeposit: securityDeposit,
      pendingBalance: pendingBalance,
      status: ResidentStatus.active,
      transactions: [initialTransaction],
    );

    // Save resident and occupy bed in MockData
    MockData.registerResident(newResident);

    // Show WhatsApp Receipt modal immediately
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WhatsAppReceiptModal(
        resident: newResident,
        transaction: initialTransaction,
        onDone: () {
          Navigator.pop(context); // close modal
          Navigator.pop(context, true); // return to caller with success flag
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Resident Onboarding & KYC'),
        actions: [
          TextButton.icon(
            onPressed: _fillSampleResidentData,
            icon: const Icon(Icons.flash_on_rounded, size: 16, color: AppColors.primary),
            label: const Text('Auto-Fill', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          elevation: 0,
          type: StepperType.horizontal,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: () {
            if (_currentStep < 3) {
              setState(() => _currentStep++);
            } else {
              _completeOnboarding();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
          controlsBuilder: (context, details) {
            final isLastStep = _currentStep == 3;
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(isLastStep ? 'Complete & Generate WhatsApp Receipt 🧾' : 'Next Step ➔'),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Personal'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildStep1Personal(),
            ),
            Step(
              title: const Text('Guardian'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildStep2Guardian(),
            ),
            Step(
              title: const Text('KYC Proof'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: _buildStep3Kyc(),
            ),
            Step(
              title: const Text('Bed & Fee'),
              isActive: _currentStep >= 3,
              state: _currentStep == 3 ? StepState.editing : StepState.indexed,
              content: _buildStep4Allocation(),
            ),
          ],
        ),
      ),
    );
  }

  // --- Step 1: Personal Details ---
  Widget _buildStep1Personal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Resident Personal Details', Icons.person_outline_rounded),
        const SizedBox(height: 14),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            hintText: 'e.g., Kavya Sundaram',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number *',
                  hintText: '98765 43210',
                  prefixText: '+91 ',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'name@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  hintText: 'DD-MM-YYYY',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _bloodGroupController,
                decoration: const InputDecoration(
                  labelText: 'Blood Group',
                  hintText: 'e.g., O+, B+, A+',
                  prefixIcon: Icon(Icons.bloodtype_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _vehicleController,
          decoration: const InputDecoration(
            labelText: 'Vehicle Number (Optional)',
            hintText: 'e.g., KA-05-MK-9912 (Bike / Car)',
            prefixIcon: Icon(Icons.two_wheeler_rounded),
          ),
        ),
      ],
    );
  }

  // --- Step 2: Guardian & Permanent Address ---
  Widget _buildStep2Guardian() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Parent / Guardian & Emergency Contact', Icons.family_restroom_rounded),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _guardianNameController,
                decoration: const InputDecoration(
                  labelText: 'Parent / Guardian Name *',
                  hintText: 'e.g., Sundaram Raman',
                  prefixIcon: Icon(Icons.person_search_rounded),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _guardianRelation,
                decoration: const InputDecoration(labelText: 'Relation'),
                items: ['Father', 'Mother', 'Spouse', 'Local Guardian', 'Sibling'].map((rel) {
                  return DropdownMenuItem(value: rel, child: Text(rel, style: const TextStyle(fontSize: 13)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _guardianRelation = val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _guardianPhoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Guardian Mobile Number *',
            hintText: '98765 00000',
            prefixText: '+91 ',
            prefixIcon: Icon(Icons.phone_in_talk_outlined),
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Permanent Address Proof', Icons.home_work_outlined),
        const SizedBox(height: 14),
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Permanent House / Street Address',
            hintText: 'House/Flat No, Landmark, Street',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City', hintText: 'e.g., Bengaluru'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State', hintText: 'Karnataka'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pincode', hintText: '560001'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Step 3: KYC & Photo Verification ---
  Widget _buildStep3Kyc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Government ID & Photo Verification', Icons.verified_user_outlined),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _idType,
          decoration: const InputDecoration(
            labelText: 'Select Government ID Type',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          items: ['Aadhaar Card', 'Driving License', 'Passport', 'Voter ID Card'].map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _idType = val);
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _idNumberController,
          decoration: InputDecoration(
            labelText: '$_idType Number',
            hintText: _idType == 'Aadhaar Card' ? 'XXXX-XXXX-XXXX' : 'Enter ID number',
            prefixIcon: const Icon(Icons.pin_outlined),
          ),
        ),
        const SizedBox(height: 20),

        // Photo & Document Upload Badges
        Row(
          children: [
            Expanded(
              child: _buildUploadCard(
                title: 'Resident Photo',
                isUploaded: _photoUploaded,
                icon: Icons.camera_alt_outlined,
                onTap: () {
                  setState(() => _photoUploaded = !_photoUploaded);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildUploadCard(
                title: 'ID Front',
                isUploaded: _idFrontUploaded,
                icon: Icons.document_scanner_outlined,
                onTap: () {
                  setState(() => _idFrontUploaded = !_idFrontUploaded);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildUploadCard(
                title: 'ID Back',
                isUploaded: _idBackUploaded,
                icon: Icons.document_scanner_outlined,
                onTap: () {
                  setState(() => _idBackUploaded = !_idBackUploaded);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          '💡 Tap any box to simulate uploading camera snapshot or gallery document.',
          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  // --- Step 4: Room, Bed & Financial Agreement ---
  Widget _buildStep4Allocation() {
    final availableRooms = _selectedProperty.rooms.where((r) => r.hasVacancy).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Bed Allocation & Sharing Arrangement', Icons.bed_outlined),
        const SizedBox(height: 14),

        // Property Display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.apartment_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedProperty.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(_selectedProperty.address, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Room & Bed Selector Row
        Row(
          children: [
            // Room Dropdown
            Expanded(
              child: DropdownButtonFormField<Room>(
                value: _selectedRoom,
                decoration: const InputDecoration(labelText: 'Room'),
                items: availableRooms.map((room) {
                  return DropdownMenuItem(
                    value: room,
                    child: Text(
                      'Room ${room.roomNumber} (${room.sharingCapacity}-Share ${room.hasAc ? "AC" : ""})',
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (room) {
                  if (room != null) {
                    setState(() {
                      _selectedRoom = room;
                      final vacant = room.beds.where((b) => b.isVacant).toList();
                      _selectedBed = vacant.isNotEmpty ? vacant.first : null;
                      _updateRentFromSelection();
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),

            // Bed Dropdown
            Expanded(
              child: DropdownButtonFormField<Bed>(
                value: _selectedBed,
                decoration: const InputDecoration(labelText: 'Bed'),
                items: (_selectedRoom != null
                        ? _selectedRoom!.beds.where((b) => b.isVacant).toList()
                        : <Bed>[])
                    .map((bed) {
                  return DropdownMenuItem(
                    value: bed,
                    child: Text(bed.code, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
                onChanged: (bed) {
                  if (bed != null) setState(() => _selectedBed = bed);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildSectionTitle('Financial Agreement (Rent & Security Deposit)', Icons.account_balance_wallet_outlined),
        const SizedBox(height: 14),

        // Agreed Monthly Rent & Security Deposit
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _rentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monthly Rent (₹)',
                  prefixText: '₹ ',
                ),
                onChanged: (_) => _calculateInitialTotals(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _depositController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Security Deposit (₹)',
                  prefixText: '₹ ',
                ),
                onChanged: (_) => _calculateInitialTotals(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Initial Collection & Payment Mode
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _initialPaidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Initial Amount Collected (₹)',
                  prefixText: '₹ ',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<PaymentMode>(
                value: _paymentMode,
                decoration: const InputDecoration(labelText: 'Payment Mode'),
                items: const [
                  DropdownMenuItem(value: PaymentMode.upi, child: Text('UPI / GPay')),
                  DropdownMenuItem(value: PaymentMode.cash, child: Text('Cash')),
                  DropdownMenuItem(value: PaymentMode.bankTransfer, child: Text('Bank Transfer')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _paymentMode = val);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required String title,
    required bool isUploaded,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.vacantBg : AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded ? AppColors.vacant : AppColors.border,
            width: isUploaded ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isUploaded ? Icons.check_circle_rounded : icon,
              size: 26,
              color: isUploaded ? AppColors.vacant : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isUploaded ? AppColors.vacant : AppColors.textPrimary,
              ),
            ),
            Text(
              isUploaded ? 'Uploaded ✓' : 'Tap to upload',
              style: TextStyle(
                fontSize: 9,
                color: isUploaded ? AppColors.vacant : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
