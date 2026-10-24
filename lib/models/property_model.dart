enum BedStatus { vacant, occupied, reserved, maintenance }

class Bed {
  final String id;
  final String code; // e.g., 'Bed A', 'Bed B'
  final BedStatus status;
  final String? residentName;
  final String? residentPhone;
  double? monthlyRent;
  final double? pendingBalance;
  final String? joiningDate;

  Bed({
    required this.id,
    required this.code,
    required this.status,
    this.residentName,
    this.residentPhone,
    this.monthlyRent,
    this.pendingBalance,
    this.joiningDate,
  });

  bool get isVacant => status == BedStatus.vacant;
  bool get isOccupied => status == BedStatus.occupied;
}

class Room {
  final String id;
  final String roomNumber;
  final int floorNumber;
  final int sharingCapacity; // 1, 2, 3, 4
  double rentPerBed;
  bool hasAttachedWashroom;
  bool hasAc;
  final List<Bed> beds;

  Room({
    required this.id,
    required this.roomNumber,
    required this.floorNumber,
    required this.sharingCapacity,
    required this.rentPerBed,
    this.hasAttachedWashroom = true,
    this.hasAc = false,
    required this.beds,
  });

  int get vacantBedsCount => beds.where((b) => b.isVacant).length;
  int get occupiedBedsCount => beds.where((b) => b.isOccupied).length;
  bool get isFullyOccupied => vacantBedsCount == 0;
  bool get hasVacancy => vacantBedsCount > 0;
}

class SharingPricing {
  final int sharingCapacity; // 1, 2, 3, 4
  double nonAcRent;
  double acRent;

  SharingPricing({
    required this.sharingCapacity,
    required this.nonAcRent,
    required this.acRent,
  });
}

class Property {
  final String id;
  final String name;
  final String address;
  final String type; // 'Men\'s PG', 'Women\'s PG', 'Co-Living'
  final List<Room> rooms;
  final List<SharingPricing> standardPricing;

  Property({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.rooms,
    required this.standardPricing,
  });

  int get totalBeds => rooms.fold(0, (sum, room) => sum + room.beds.length);
  int get occupiedBeds => rooms.fold(0, (sum, room) => sum + room.occupiedBedsCount);
  int get vacantBeds => rooms.fold(0, (sum, room) => sum + room.vacantBedsCount);
  double get occupancyRate => totalBeds > 0 ? (occupiedBeds / totalBeds) * 100 : 0.0;
}
