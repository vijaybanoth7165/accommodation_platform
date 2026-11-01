import '../models/property_model.dart';
import '../models/resident_model.dart';

class MockData {
  static final List<Property> properties = [
    Property(
      id: 'prop-1',
      name: 'Sunrise Premium Co-Living',
      address: 'Plot 42, HSR Layout Sector 2, Bengaluru',
      type: 'Co-Living PG',
      standardPricing: [
        SharingPricing(sharingCapacity: 1, nonAcRent: 12000, acRent: 14500),
        SharingPricing(sharingCapacity: 2, nonAcRent: 7500, acRent: 9000),
        SharingPricing(sharingCapacity: 3, nonAcRent: 6000, acRent: 7500),
        SharingPricing(sharingCapacity: 4, nonAcRent: 4800, acRent: 6000),
      ],
      rooms: [
        // Floor 1
        Room(
          id: 'r-101',
          roomNumber: '101',
          floorNumber: 1,
          sharingCapacity: 2,
          rentPerBed: 9000,
          hasAc: true,
          beds: [
            Bed(
              id: 'b-101-a',
              code: 'Bed 101-A',
              status: BedStatus.occupied,
              residentName: 'Rahul Sharma',
              residentPhone: '+91 98765 11001',
              monthlyRent: 9000,
              pendingBalance: 0,
              joiningDate: '01 Oct 2026',
            ),
            Bed(
              id: 'b-101-b',
              code: 'Bed 101-B',
              status: BedStatus.vacant,
              monthlyRent: 9000,
            ),
          ],
        ),
        Room(
          id: 'r-102',
          roomNumber: '102',
          floorNumber: 1,
          sharingCapacity: 3,
          rentPerBed: 6000,
          hasAc: false,
          beds: [
            Bed(
              id: 'b-102-a',
              code: 'Bed 102-A',
              status: BedStatus.occupied,
              residentName: 'Amit Patel',
              residentPhone: '+91 98765 11002',
              monthlyRent: 6000,
              pendingBalance: 2500, // Partial payment
              joiningDate: '15 Sep 2026',
            ),
            Bed(
              id: 'b-102-b',
              code: 'Bed 102-B',
              status: BedStatus.occupied,
              residentName: 'Karthik Rao',
              residentPhone: '+91 98765 11003',
              monthlyRent: 6000,
              pendingBalance: 0,
              joiningDate: '05 Aug 2026',
            ),
            Bed(
              id: 'b-102-c',
              code: 'Bed 102-C',
              status: BedStatus.vacant,
              monthlyRent: 6000,
            ),
          ],
        ),
        Room(
          id: 'r-103',
          roomNumber: '103',
          floorNumber: 1,
          sharingCapacity: 1,
          rentPerBed: 14500,
          hasAc: true,
          beds: [
            Bed(
              id: 'b-103-a',
              code: 'Bed 103-A',
              status: BedStatus.occupied,
              residentName: 'Vikas Reddy',
              residentPhone: '+91 98765 11004',
              monthlyRent: 14500,
              pendingBalance: 0,
              joiningDate: '10 Jul 2026',
            ),
          ],
        ),

        // Floor 2
        Room(
          id: 'r-201',
          roomNumber: '201',
          floorNumber: 2,
          sharingCapacity: 4,
          rentPerBed: 4800,
          hasAc: false,
          beds: [
            Bed(
              id: 'b-201-a',
              code: 'Bed 201-A',
              status: BedStatus.occupied,
              residentName: 'Suresh Kumar',
              residentPhone: '+91 98765 11005',
              monthlyRent: 4800,
              pendingBalance: 4800, // Full balance overdue
              joiningDate: '01 Sep 2026',
            ),
            Bed(
              id: 'b-201-b',
              code: 'Bed 201-B',
              status: BedStatus.occupied,
              residentName: 'Deepak Verma',
              residentPhone: '+91 98765 11006',
              monthlyRent: 4800,
              pendingBalance: 0,
              joiningDate: '12 Sep 2026',
            ),
            Bed(
              id: 'b-201-c',
              code: 'Bed 201-C',
              status: BedStatus.vacant,
              monthlyRent: 4800,
            ),
            Bed(
              id: 'b-201-d',
              code: 'Bed 201-D',
              status: BedStatus.reserved,
              residentName: 'Rohan Joshi (Joining Nov 1)',
              monthlyRent: 4800,
            ),
          ],
        ),
        Room(
          id: 'r-202',
          roomNumber: '202',
          floorNumber: 2,
          sharingCapacity: 2,
          rentPerBed: 9000,
          hasAc: true,
          beds: [
            Bed(
              id: 'b-202-a',
              code: 'Bed 202-A',
              status: BedStatus.vacant,
              monthlyRent: 9000,
            ),
            Bed(
              id: 'b-202-b',
              code: 'Bed 202-B',
              status: BedStatus.vacant,
              monthlyRent: 9000,
            ),
          ],
        ),
      ],
    ),
    Property(
      id: 'prop-2',
      name: 'Grand Orchid Women’s Hostel',
      address: 'Lane 7, Koramangala 4th Block, Bengaluru',
      type: 'Women’s PG',
      standardPricing: [
        SharingPricing(sharingCapacity: 1, nonAcRent: 13000, acRent: 15500),
        SharingPricing(sharingCapacity: 2, nonAcRent: 8000, acRent: 9500),
        SharingPricing(sharingCapacity: 3, nonAcRent: 6500, acRent: 8000),
        SharingPricing(sharingCapacity: 4, nonAcRent: 5200, acRent: 6500),
      ],
      rooms: [
        Room(
          id: 'r-w101',
          roomNumber: 'W-101',
          floorNumber: 1,
          sharingCapacity: 2,
          rentPerBed: 9500,
          hasAc: true,
          beds: [
            Bed(
              id: 'bw-101-a',
              code: 'Bed W101-A',
              status: BedStatus.occupied,
              residentName: 'Priya Nair',
              residentPhone: '+91 98765 22001',
              monthlyRent: 9500,
              pendingBalance: 0,
              joiningDate: '01 Oct 2026',
            ),
            Bed(
              id: 'bw-101-b',
              code: 'Bed W101-B',
              status: BedStatus.vacant,
              monthlyRent: 9500,
            ),
          ],
        ),
      ],
    ),
  ];

  // Initial Seed Residents
  static final List<Resident> residents = [
    Resident(
      id: 'res-1',
      name: 'Rahul Sharma',
      phone: '9876511001',
      email: 'rahul.sharma@example.com',
      dateOfBirth: '14 May 1999',
      bloodGroup: 'B+',
      vehicleNumber: 'KA-01-EQ-4421',
      guardianName: 'Rajesh Sharma',
      guardianPhone: '9876500111',
      guardianRelation: 'Father',
      permanentAddress: 'House 12, Civil Lines, Jaipur, Rajasthan',
      city: 'Jaipur',
      state: 'Rajasthan',
      pincode: '302006',
      idProofType: 'Aadhaar Card',
      idProofNumber: 'XXXX-XXXX-4589',
      propertyId: 'prop-1',
      propertyName: 'Sunrise Premium Co-Living',
      roomNumber: '101',
      bedCode: 'Bed 101-A',
      joiningDate: '01 Oct 2026',
      monthlyRent: 9000,
      securityDeposit: 10000,
      pendingBalance: 0,
      status: ResidentStatus.active,
      transactions: [
        PaymentTransaction(
          id: 'tx-1',
          receiptNumber: 'REC-2026-101',
          date: DateTime(2026, 10, 1),
          amount: 19000,
          type: PaymentType.rent,
          mode: PaymentMode.upi,
          referenceNumber: 'UPI/629103847291',
          notes: 'Joining rent (₹9,000) + Security Deposit (₹10,000)',
        ),
      ],
    ),
    Resident(
      id: 'res-2',
      name: 'Amit Patel',
      phone: '9876511002',
      email: 'amit.patel@example.com',
      dateOfBirth: '22 Aug 2000',
      bloodGroup: 'O+',
      vehicleNumber: 'KA-03-MM-7890',
      guardianName: 'Dinesh Patel',
      guardianPhone: '9876500222',
      guardianRelation: 'Father',
      permanentAddress: 'B-402, Shivalik Parkview, Ahmedabad, Gujarat',
      city: 'Ahmedabad',
      state: 'Gujarat',
      pincode: '380015',
      idProofType: 'Aadhaar Card',
      idProofNumber: 'XXXX-XXXX-8912',
      propertyId: 'prop-1',
      propertyName: 'Sunrise Premium Co-Living',
      roomNumber: '102',
      bedCode: 'Bed 102-A',
      joiningDate: '15 Sep 2026',
      monthlyRent: 6000,
      securityDeposit: 8000,
      pendingBalance: 2500,
      status: ResidentStatus.active,
      transactions: [
        PaymentTransaction(
          id: 'tx-2',
          receiptNumber: 'REC-2026-102',
          date: DateTime(2026, 10, 5),
          amount: 3500,
          type: PaymentType.rent,
          mode: PaymentMode.upi,
          referenceNumber: 'UPI/629108492019',
          notes: 'Partial payment of October Rent (₹2,500 due)',
        ),
      ],
    ),
    Resident(
      id: 'res-3',
      name: 'Priya Nair',
      phone: '9876522001',
      email: 'priya.nair@example.com',
      dateOfBirth: '05 Jan 2001',
      bloodGroup: 'A+',
      vehicleNumber: '',
      guardianName: 'Mohan Nair',
      guardianPhone: '9876500333',
      guardianRelation: 'Father',
      permanentAddress: 'Green Valley, MG Road, Kochi, Kerala',
      city: 'Kochi',
      state: 'Kerala',
      pincode: '682016',
      idProofType: 'Aadhaar Card',
      idProofNumber: 'XXXX-XXXX-3341',
      propertyId: 'prop-2',
      propertyName: 'Grand Orchid Women’s Hostel',
      roomNumber: 'W-101',
      bedCode: 'Bed W101-A',
      joiningDate: '01 Oct 2026',
      monthlyRent: 9500,
      securityDeposit: 10000,
      pendingBalance: 0,
      status: ResidentStatus.active,
      transactions: [
        PaymentTransaction(
          id: 'tx-3',
          receiptNumber: 'REC-2026-103',
          date: DateTime(2026, 10, 1),
          amount: 19500,
          type: PaymentType.rent,
          mode: PaymentMode.upi,
          referenceNumber: 'UPI/992810481920',
          notes: 'Joining rent + Security Deposit',
        ),
      ],
    ),
  ];

  // Helper method to register a new resident and update bed availability
  static void registerResident(Resident resident) {
    residents.insert(0, resident);

    // Locate the property and bed to occupy
    for (var property in properties) {
      if (property.id == resident.propertyId) {
        for (var room in property.rooms) {
          if (room.roomNumber == resident.roomNumber) {
            for (int i = 0; i < room.beds.length; i++) {
              if (room.beds[i].code == resident.bedCode) {
                room.beds[i] = Bed(
                  id: room.beds[i].id,
                  code: room.beds[i].code,
                  status: BedStatus.occupied,
                  residentName: resident.name,
                  residentPhone: '+91 ${resident.phone}',
                  monthlyRent: resident.monthlyRent,
                  pendingBalance: resident.pendingBalance,
                  joiningDate: resident.joiningDate,
                );
                return;
              }
            }
          }
        }
      }
    }
  }

  // Vacate resident & release bed
  static void vacateResident(String residentId, {double deduction = 0, String reason = ''}) {
    final residentIndex = residents.indexWhere((r) => r.id == residentId);
    if (residentIndex == -1) return;

    final resident = residents[residentIndex];
    resident.status = ResidentStatus.vacated;

    // Release bed in the property
    for (var property in properties) {
      if (property.id == resident.propertyId) {
        for (var room in property.rooms) {
          if (room.roomNumber == resident.roomNumber) {
            for (int i = 0; i < room.beds.length; i++) {
              if (room.beds[i].code == resident.bedCode) {
                room.beds[i] = Bed(
                  id: room.beds[i].id,
                  code: room.beds[i].code,
                  status: BedStatus.vacant,
                  monthlyRent: room.rentPerBed,
                  pendingBalance: 0,
                );
                return;
              }
            }
          }
        }
      }
    }
  }
}
