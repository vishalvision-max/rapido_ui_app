import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/colors.dart';

class ReferEarnScreen extends StatelessWidget {
  const ReferEarnScreen({super.key});

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
          'Refer & Earn',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    size: 120,
                    color: AppColors.primaryYellow,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Invite Friends, Get Rewards!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Share your referral code with friends and get ₹50 for every friend who completes their first ride.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 48),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RAPIDO50XYZ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.snackbar(
                        'Copied',
                        'Referral code copied to clipboard',
                      );
                    },
                    child: const Text('COPY'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  label: const Text('SHARE WITH FRIENDS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                    foregroundColor: AppColors.primaryYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
