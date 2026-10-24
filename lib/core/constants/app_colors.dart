import 'package:flutter/material.dart';

class AppColors {
  // Primary brand palette
  static const Color primary = Color(0xFF4F46E5);       // Indigo 600
  static const Color primaryDark = Color(0xFF3730A3);   // Indigo 800
  static const Color primaryLight = Color(0xFFEEF2FF);  // Indigo 50
  static const Color accent = Color(0xFF06B6D4);        // Cyan 500

  // Neutral palette
  static const Color background = Color(0xFFF8FAFC);    // Slate 50
  static const Color surface = Color(0xFFFFFFFF);       // White
  static const Color surfaceVariant = Color(0xFFF1F5F9);// Slate 100
  static const Color border = Color(0xFFE2E8F0);        // Slate 200
  
  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);   // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8);     // Slate 400

  // Status colors (crucial for bed availability & finance)
  static const Color vacant = Color(0xFF10B981);         // Emerald 500 (Available)
  static const Color vacantBg = Color(0xFFECFDF5);       // Emerald 50
  static const Color occupied = Color(0xFFEF4444);       // Red 500 (Occupied)
  static const Color occupiedBg = Color(0xFFFEF2F2);     // Red 50
  static const Color reserved = Color(0xFFF59E0B);       // Amber 500 (Reserved/Pending)
  static const Color reservedBg = Color(0xFFFFFBEB);     // Amber 50
  static const Color maintenance = Color(0xFF64748B);    // Slate 500
  static const Color maintenanceBg = Color(0xFFF8FAFC);  // Slate 50
}
