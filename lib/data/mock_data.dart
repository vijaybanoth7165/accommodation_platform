import '../models/property_model.dart';

class MockData {
  static final List<Property> properties = [
    Property(
      id: 'prop-1',
      name: 'Sunrise Premium Co-Living',
      address: 'Plot 42, HSR Layout Sector 2, Bengaluru',
      type: 'Co-Living PG',
      rooms: [
        // Floor 1
        Room(
          id: 'r-101',
          roomNumber: '101',
          floorNumber: 1,
          sharingCapacity: 2,
          rentPerBed: 9000,
          hasAc: true,
          beds: const [
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
          rentPerBed: 7500,
          hasAc: false,
          beds: const [
            Bed(
              id: 'b-102-a',
              code: 'Bed 102-A',
              status: BedStatus.occupied,
              residentName: 'Amit Patel',
              residentPhone: '+91 98765 11002',
              monthlyRent: 7500,
              pendingBalance: 2500, // Partial payment
              joiningDate: '15 Sep 2026',
            ),
            Bed(
              id: 'b-102-b',
              code: 'Bed 102-B',
              status: BedStatus.occupied,
              residentName: 'Karthik Rao',
              residentPhone: '+91 98765 11003',
              monthlyRent: 7500,
              pendingBalance: 0,
              joiningDate: '05 Aug 2026',
            ),
            Bed(
              id: 'b-102-c',
              code: 'Bed 102-C',
              status: BedStatus.vacant,
              monthlyRent: 7500,
            ),
          ],
        ),
        Room(
          id: 'r-103',
          roomNumber: '103',
          floorNumber: 1,
          sharingCapacity: 1,
          rentPerBed: 14000,
          hasAc: true,
          beds: const [
            Bed(
              id: 'b-103-a',
              code: 'Bed 103-A',
              status: BedStatus.occupied,
              residentName: 'Vikas Reddy',
              residentPhone: '+91 98765 11004',
              monthlyRent: 14000,
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
          rentPerBed: 6000,
          hasAc: false,
          beds: const [
            Bed(
              id: 'b-201-a',
              code: 'Bed 201-A',
              status: BedStatus.occupied,
              residentName: 'Suresh Kumar',
              residentPhone: '+91 98765 11005',
              monthlyRent: 6000,
              pendingBalance: 6000, // Full balance overdue
              joiningDate: '01 Sep 2026',
            ),
            Bed(
              id: 'b-201-b',
              code: 'Bed 201-B',
              status: BedStatus.occupied,
              residentName: 'Deepak Verma',
              residentPhone: '+91 98765 11006',
              monthlyRent: 6000,
              pendingBalance: 0,
              joiningDate: '12 Sep 2026',
            ),
            Bed(
              id: 'b-201-c',
              code: 'Bed 201-C',
              status: BedStatus.vacant,
              monthlyRent: 6000,
            ),
            Bed(
              id: 'b-201-d',
              code: 'Bed 201-D',
              status: BedStatus.reserved,
              residentName: 'Rohan Joshi (Joining Nov 1)',
              monthlyRent: 6000,
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
          beds: const [
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
      rooms: [
        Room(
          id: 'r-w101',
          roomNumber: 'W-101',
          floorNumber: 1,
          sharingCapacity: 2,
          rentPerBed: 9500,
          hasAc: true,
          beds: const [
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
}
