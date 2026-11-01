import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../models/resident_model.dart';

class WhatsAppReceiptModal extends StatelessWidget {
  final Resident resident;
  final PaymentTransaction transaction;
  final VoidCallback onDone;

  const WhatsAppReceiptModal({
    super.key,
    required this.resident,
    required this.transaction,
    required this.onDone,
  });

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')} Nov ${dt.year}, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String get _whatsappMessageText {
    return '''
*🧾 FEE PAYMENT RECEIPT*
*${resident.propertyName}*
---------------------------------------
*Receipt No:* ${transaction.receiptNumber}
*Date:* ${_formatDate(transaction.date)}

*Resident Name:* ${resident.name}
*Room & Bed:* Room ${resident.roomNumber} (${resident.bedCode})
*Phone:* +91 ${resident.phone}

*PAYMENT BREAKDOWN:*
• Amount Paid: ₹${transaction.amount.toInt()}
• Mode: ${transaction.modeLabel}
• Security Deposit: ₹${resident.securityDeposit.toInt()} (Held Safe)
• Monthly Agreed Rent: ₹${resident.monthlyRent.toInt()}
• Pending Dues: ₹${resident.pendingBalance.toInt()}

---------------------------------------
${resident.pendingBalance == 0 ? "✅ Account Status: All Dues Cleared" : "⚠️ Outstanding Balance: ₹${resident.pendingBalance.toInt()}"}

Thank you for choosing ${resident.propertyName}!
Generated via Accommodation Management Platform.
'''
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
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

            // Success Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.vacantBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.vacant, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Onboarding & Payment Complete!',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Bed allocated & digital fee receipt generated',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // WhatsApp Style Receipt Preview Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEFEAE2), // WhatsApp chat wallpaper tint
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD1D7DB)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // WhatsApp Chat Bubble
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF25D366).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.chat_rounded, color: Color(0xFF128C7E), size: 13),
                                  SizedBox(width: 4),
                                  Text(
                                    'WhatsApp Digital Receipt',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF128C7E)),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              transaction.receiptNumber,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          resident.propertyName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const Divider(height: 16),
                        _receiptRow('Resident', resident.name),
                        _receiptRow('Room & Bed', 'Room ${resident.roomNumber} (${resident.bedCode})'),
                        _receiptRow('Mobile', '+91 ${resident.phone}'),
                        _receiptRow('Amount Paid', '₹${transaction.amount.toInt()}', isHighlight: true),
                        _receiptRow('Payment Mode', transaction.modeLabel),
                        _receiptRow('Security Deposit', '₹${resident.securityDeposit.toInt()} (Held)'),
                        _receiptRow(
                          'Outstanding Due',
                          resident.pendingBalance == 0 ? '₹0 (Fully Paid)' : '₹${resident.pendingBalance.toInt()}',
                          color: resident.pendingBalance > 0 ? AppColors.occupied : AppColors.vacant,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Actions: Send WhatsApp & Done
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _whatsappMessageText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('Receipt copied! Opening WhatsApp for +91 ${resident.phone}...'),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF128C7E),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_rounded),
              label: Text('Send via WhatsApp to +91 ${resident.phone}'),
            ),
            const SizedBox(height: 10),

            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
              ),
              onPressed: onDone,
              child: const Text('Back to Dashboard & Beds'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool isHighlight = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 14 : 12,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              color: color ?? (isHighlight ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
