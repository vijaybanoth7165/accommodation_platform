import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const SettingsScreen({super.key, this.onLogout});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableResidentSelfService = false;
  bool _supervisorCanEditRent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings & Roles'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.person, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Vijay Banoth',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Property Owner (Full Admin)',
                        style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Tenant ID: AMP-BLR-01',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 1: Staff & Supervisor Access
          _buildSectionHeader('STAFF & SUPERVISOR ROLES'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined, color: AppColors.primary),
                  title: const Text('Manage Supervisors', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Add property supervisors & phone numbers', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Supervisor management: 2 supervisors assigned'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.border),
                SwitchListTile(
                  title: const Text('Allow Supervisors to Modify Rent', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Restricts supervisors to only record collections and check availability', style: TextStyle(fontSize: 12)),
                  value: _supervisorCanEditRent,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => _supervisorCanEditRent = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Resident Self-Service (Phase 2 Preview)
          _buildSectionHeader('RESIDENT PORTAL & GUEST ACCESS'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Resident Self-Service Portal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Allow residents to view their own fee receipts & pay via link', style: TextStyle(fontSize: 12)),
                  value: _enableResidentSelfService,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => _enableResidentSelfService = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val ? 'Resident portal enabled for Phase 2 rollout' : 'Resident portal disabled (Staff operations only)'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: const Icon(Icons.chat_outlined, color: Color(0xFF25D366)),
                  title: const Text('WhatsApp Receipt Templates', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Customize automated monthly payment receipts', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('WhatsApp receipt template configured with business name'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 3: App Information
          _buildSectionHeader('PLATFORM & MULTI-TENANT'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.apartment_rounded, color: AppColors.textSecondary),
                  title: const Text('Multi-Property Configuration', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('2 PG / Hostel properties connected', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: const Icon(Icons.security_rounded, color: AppColors.vacant),
                  title: const Text('Customer Data Isolation', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Row-level tenant boundary active', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Logout Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: AppColors.occupied),
              foregroundColor: AppColors.occupied,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              if (widget.onLogout != null) widget.onLogout!();
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Log Out of Property Portal', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
