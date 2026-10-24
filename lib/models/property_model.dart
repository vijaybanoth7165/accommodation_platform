enum BedStatus { vacant, occupied, reserved, maintenance }

class Bed {
  final String id;
  final String code; // e.g., 'Bed A', 'Bed B'
  final BedStatus status;
  final String? residentName;
  final String? residentPhone;
  final double? monthlyRent;
  final double? pendingBalance;
  final String? joiningDate;

  const Bed({
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
  final double rentPerBed;
  final bool hasAttachedWashroom;
  final bool hasAc;
  final List<Bed> beds;

  const Room({
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

class Property {
  final String id;
  final String name;
  final String address;
  final String type; // 'Men\'s PG', 'Women\'s PG', 'Co-Living'
  final List<Room> rooms;

  const Property({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.rooms,
  });

  int get totalBeds => rooms.fold(0, (sum, room) => sum + room.beds.length);
  int get occupiedBeds => rooms.fold(0, (sum, room) => sum + room.occupiedBedsCount);
  int get vacantBeds => rooms.fold(0, (sum, room) => sum + room.vacantBedsCount);
  double get occupancyRate => totalBeds > 0 ? (occupiedBeds / totalBeds) * 100 : 0.0;
}
