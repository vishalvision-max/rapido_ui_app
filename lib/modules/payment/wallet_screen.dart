import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/colors.dart';

class WalletController extends GetxController {
  final RxDouble walletBalance = 250.0.obs;
  final TextEditingController amountController = TextEditingController();

  void addMoney(double amount) {
    walletBalance.value += amount;
    Get.snackbar(
      'Success',
      '₹$amount added to wallet',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Rapido Wallet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Balance Card
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: AppColors.darkGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        '₹${controller.walletBalance.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.primaryYellow,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _walletAction(Icons.add_rounded, 'Add Money'),
                        _walletAction(Icons.history_rounded, 'History'),
                        _walletAction(Icons.redeem_rounded, 'Offers'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Quick Add
            FadeInLeft(
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick Top-up',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _quickAdd(controller, 100),
                _quickAdd(controller, 500),
                _quickAdd(controller, 1000),
              ],
            ),
            const SizedBox(height: 40),

            // Transactions
            FadeInLeft(
              delay: const Duration(milliseconds: 200),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Transactions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _transactionItem('Ride – Whitefield', 'Today, 2:30 PM', -45, false),
            _transactionItem('Wallet Top-up', 'Yesterday, 11:00 AM', 500, true),
            _transactionItem(
              'Ride – Koramangala',
              '2 Feb, 8:15 PM',
              -120,
              false,
            ),
            _transactionItem('Cashback Received', '1 Feb, 10:00 AM', 20, true),
          ],
        ),
      ),
    );
  }

  Widget _walletAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _quickAdd(WalletController controller, double amount) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.addMoney(amount),
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Center(
            child: Text(
              '+ ₹$amount',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _transactionItem(
    String title,
    String subtitle,
    double amount,
    bool isCredit,
  ) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCredit ? Colors.green[50] : Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: isCredit ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '${isCredit ? '+' : ''}₹${amount.abs()}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: isCredit ? Colors.green : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
