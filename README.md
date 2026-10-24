# Accommodation Management Platform (AMP) 🏢🛏️

A multi-tenant SaaS-based Accommodation Management Platform built with Flutter to digitize and automate the day-to-day operations of PGs, Hostels, Co-living spaces, and Hotels.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue)](#)
[![Multi-Tenant](https://img.shields.io/badge/Architecture-Multi--Tenant%20SaaS-green)](#)
[![License](https://img.shields.io/badge/License-Proprietary-orange)](#)

---

## 📌 Executive Summary & Problem Solved

Small and mid-sized PG/hostel operators frequently rely on physical registers, manual fee receipts, unorganized WhatsApp messages, and mental notes to track bed occupancy and dues.

**Accommodation Management Platform** acts as the digital operating system for property owners and supervisors to instantly answer:
- **Which beds are vacant right now?** (Bed-level granularity, e.g., 1 vacant bed in a 3-sharing room)
- **Who is staying in which room and bed?**
- **Who has paid, who made partial payments, and who has an outstanding balance?**
- **Who needs a fee reminder?** (Automated WhatsApp & SMS reminders)
- **What is the property's monthly collection and occupancy rate?**

---

## 🗺️ Product Roadmap & Phases

- **Phase 1 (Current): PG / Hostel / Co-Living Management**
  - Multi-property setup under a single owner account.
  - Property $\rightarrow$ Floor $\rightarrow$ Room $\rightarrow$ Sharing $\rightarrow$ Bed structure.
  - 1-sharing, 2-sharing, 3-sharing, 4-sharing support with individual pricing.
  - Resident onboarding & KYC (photo, government ID, guardian info).
  - Bed allocation and room shifts.
  - Advance & security deposit tracking separated from monthly rent.
  - Partial payments, pending dues, and digital WhatsApp fee receipts.
  - Vacating workflow with security deposit settlement.

- **Phase 2: Hotel Management**
  - Hotel property configuration and room-type inventory.
  - Booking, reservation calendar, and advance deposits.
  - Guest check-in, stay management, room service billing, and check-out.

---

## 🏗️ Domain Hierarchy & Data Model

```
Tenant (Customer / PG Business)
  └── Property (e.g., "Sunrise Luxury PG")
       └── Floor (e.g., "Floor 1", "Floor 2")
            └── Room (e.g., "Room 102" - 3 Sharing, AC)
                 └── Bed (Bed A, Bed B, Bed C)
                      └── Resident (Occupant)
                           ├── KYC / Documents & Photo
                           ├── Financial Ledger (Monthly Rent, Deposit, Dues)
                           └── Lifecycle (Active, Transferred, Vacated)
```

---

## 📱 Mobile Screens Implemented (Phase 1)

### 1. Multi-Persona Login Screen (`lib/screens/auth/login_screen.dart`)
- **Persona Selector**: Fast toggle between **Owner**, **Supervisor**, and **Resident**.
- **Authentication Modes**:
  - Mobile Number + OTP (WhatsApp / SMS).
  - Email & Password / Tenant Workspace ID.
- **One-Click Demo Fill**: Pre-fills credentials for instant local testing.
- **Multi-Tenant Security Badge**: Communicates strict customer-data isolation.

### 2. Owner Dashboard (`lib/screens/owner/owner_dashboard_screen.dart`)
- **Multi-Property Switcher**: Switch between multiple properties via top bar dropdown.
- **Live KPI Grid**:
  - *Occupancy Rate %* (e.g., 75% occupied).
  - *Live Available Beds Count* (One-tap direct navigation to vacant beds).
  - *Month-to-Date Collections (₹)*.
  - *Pending Balances / Overdue Dues (₹)* with resident count flags.
- **Quick Operational Shortcuts**: *Bed Matrix*, *Add Resident & KYC*, *Collect Rent*, *Room Config*.
- **Recent Room Status Preview**: At-a-glance floor/room list with occupancy pills.

### 3. Rooms & Sharing Configuration (`lib/screens/rooms/rooms_screen.dart`)
- **Interactive Floor Filters**: Filter by Floor (*Floor 1, Floor 2, All Floors*).
- **Sharing Capacity Filters**: Filter by Sharing (*1-Share, 2-Share, 3-Share, 4-Share*).
- **Room Cards**: Details AC/Non-AC status, rent per bed, and vacancy status.
- **Inline Bed Badges**: See which resident occupies which bed right inside each room card.

### 4. Live Bed Availability Matrix (`lib/screens/rooms/bed_availability_screen.dart`)
- **Summary Counter**: Real-time *Available Beds*, *Occupied Beds*, and *Total Capacity*.
- **Interactive Filter Chips**: *All*, *Vacant Only*, *Occupied*, *With Pending Balance*.
- **Visual Bed Grid by Room**:
  - 🟢 **VACANT**: Tap opens the *Allocate Bed & Resident Onboarding* modal.
  - 🔴 **OCCUPIED**: Displays resident name, phone, joining date, and balance due. Tap opens action sheet with:
    - *Send WhatsApp Reminder*
    - *Vacate Bed & Settle Deposit*
    - *Resident Profile & Documents*
  - 🟡 **RESERVED**: Shows upcoming joiners with token advances.
- **Color-Coded Status Legend**: Complete clarity on bed lifecycle states.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.13+)
- Dart SDK (bundled with Flutter)
- Android Studio / VS Code with Flutter extension
- An Android/iOS device or emulator, or Chrome browser

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/vijaybanoth7165/accommodation_platform.git
   cd accommodation_platform
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

---

## 📂 Project Directory Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart         # Status colors (Vacant, Occupied, Reserved, Dues)
│   └── theme/
│       └── app_theme.dart          # Material 3 custom theme & typography
├── data/
│   └── mock_data.dart              # Multi-property realistic seed data
├── models/
│   └── property_model.dart         # Property, Room, Bed, and Resident models
├── screens/
│   ├── auth/
│   │   └── login_screen.dart       # Multi-role authentication & OTP
│   ├── owner/
│   │   └── owner_dashboard_screen.dart # KPI dashboard & operational actions
│   └── rooms/
│       ├── rooms_screen.dart       # Floors & sharing configurations
│       └── bed_availability_screen.dart # Bed-level interactive matrix
└── main.dart                       # App entry point & state routing
```

---

## 📄 License & Attribution
Designed and developed as a multi-tenant Accommodation Management SaaS platform.
