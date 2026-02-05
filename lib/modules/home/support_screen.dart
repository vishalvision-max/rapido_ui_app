import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

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
          'Support',
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
              'How can we help you?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildSupportTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Chat with Us',
              subtitle: 'Our AI assistant is here to help',
              onTap: () {},
            ),
            _buildSupportTile(
              icon: Icons.history_rounded,
              title: 'Issues with a Recent Ride',
              subtitle: 'Report problems with your last trip',
              onTap: () {},
            ),
            _buildSupportTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Payment & Wallet Issues',
              subtitle: 'Refunds, transactions, and more',
              onTap: () {},
            ),
            _buildSupportTile(
              icon: Icons.security_rounded,
              title: 'Safety Concerns',
              subtitle: 'Report an incident or safety issue',
              onTap: () {},
            ),
            const SizedBox(height: 32),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildFaqItem('How do I book a ride?'),
            _buildFaqItem('What are the payment options?'),
            _buildFaqItem('How do I apply a coupon?'),
            _buildFaqItem('How can I become a Captain?'),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        leading: Icon(icon, color: AppColors.primaryYellow, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildFaqItem(String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        children: const [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'You can easily book a ride by selecting your destination on the home screen and choosing your preferred vehicle type.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
