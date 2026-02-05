import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/colors.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferred Payments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentItem(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Rapido Wallet',
              subtitle: 'Balance: ₹45.00',
              color: Colors.blue,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const Text(
              'UPI',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentItem(
              imageUrl: 'https://img.icons8.com/color/48/000000/google-pay.png',
              title: 'Google Pay',
              subtitle: 'johndoe@okaxis',
              onTap: () {},
            ),
            _buildPaymentItem(
              imageUrl: 'https://img.icons8.com/color/48/000000/phone-pe.png',
              title: 'PhonePe',
              subtitle: '9876543210@ybl',
              onTap: () {},
            ),
            _buildPaymentItem(
              icon: Icons.add_circle_outline,
              title: 'Add New UPI ID',
              subtitle: 'Pay via any UPI app',
              color: AppColors.primaryYellow,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const Text(
              'Cards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentItem(
              icon: Icons.credit_card_rounded,
              title: 'HDFC Bank Credit Card',
              subtitle: '**** **** **** 4567',
              color: Colors.deepPurple,
              onTap: () {},
            ),
            _buildPaymentItem(
              icon: Icons.add_card_rounded,
              title: 'Add New Card',
              subtitle: 'Save cards for faster payments',
              color: AppColors.success,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const Text(
              'Other Methods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentItem(
              icon: Icons.money_rounded,
              title: 'Cash',
              subtitle: 'Pay at the end of the ride',
              color: AppColors.success,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItem({
    IconData? icon,
    String? imageUrl,
    required String title,
    required String subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (color ?? AppColors.primaryYellow).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: imageUrl != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    imageUrl,
                    errorBuilder: (c, e, s) => const Icon(Icons.payment),
                  ),
                )
              : Icon(icon, color: color ?? AppColors.primaryBlack),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
