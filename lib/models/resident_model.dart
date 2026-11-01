enum PaymentType { rent, securityDeposit, maintenance, refund }
enum PaymentMode { upi, cash, bankTransfer }

class PaymentTransaction {
  final String id;
  final String receiptNumber;
  final DateTime date;
  final double amount;
  final PaymentType type;
  final PaymentMode mode;
  final String? referenceNumber;
  final String notes;

  PaymentTransaction({
    required this.id,
    required this.receiptNumber,
    required this.date,
    required this.amount,
    required this.type,
    required this.mode,
    this.referenceNumber,
    this.notes = '',
  });

  String get typeLabel {
    switch (type) {
      case PaymentType.rent:
        return 'Monthly Rent';
      case PaymentType.securityDeposit:
        return 'Security Deposit';
      case PaymentType.maintenance:
        return 'Maintenance / Charges';
      case PaymentType.refund:
        return 'Deposit Refund';
    }
  }

  String get modeLabel {
    switch (mode) {
      case PaymentMode.upi:
        return 'UPI / GPay / PhonePe';
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.bankTransfer:
        return 'Net Banking / NEFT';
    }
  }
}

enum ResidentStatus { active, noticePeriod, vacated }

class Resident {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String dateOfBirth;
  final String bloodGroup;
  final String vehicleNumber;

  // Guardian & Emergency
  final String guardianName;
  final String guardianPhone;
  final String guardianRelation;
  final String permanentAddress;
  final String city;
  final String state;
  final String pincode;

  // KYC
  final String idProofType; // Aadhaar, Driving License, Passport
  final String idProofNumber;
  final bool hasPhoto;
  final bool hasIdProofDocument;

  // Allocation & Finances
  final String propertyId;
  final String propertyName;
  final String roomNumber;
  final String bedCode;
  final String joiningDate;
  double monthlyRent;
  double securityDeposit;
  double pendingBalance;
  ResidentStatus status;
  final List<PaymentTransaction> transactions;

  Resident({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.dateOfBirth = '',
    this.bloodGroup = '',
    this.vehicleNumber = '',
    required this.guardianName,
    required this.guardianPhone,
    this.guardianRelation = 'Parent',
    this.permanentAddress = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.idProofType = 'Aadhaar Card',
    this.idProofNumber = '',
    this.hasPhoto = true,
    this.hasIdProofDocument = true,
    required this.propertyId,
    required this.propertyName,
    required this.roomNumber,
    required this.bedCode,
    required this.joiningDate,
    required this.monthlyRent,
    required this.securityDeposit,
    this.pendingBalance = 0,
    this.status = ResidentStatus.active,
    List<PaymentTransaction>? transactions,
  }) : transactions = transactions ?? [];

  bool get isVacated => status == ResidentStatus.vacated;
  bool get hasPendingDues => pendingBalance > 0;
}
