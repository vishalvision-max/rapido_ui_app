import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/colors.dart';

/// Payment controller
class PaymentController extends GetxController {
  late double fare;
  late String pickup;
  late String drop;
  final RxString selectedPaymentMethod = 'cash'.obs;
  final RxBool isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    fare = args['fare'] ?? 0.0;
    pickup = args['pickup'] ?? '';
    drop = args['drop'] ?? '';
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void completePayment() {
    isProcessing.value = true;

    Future.delayed(const Duration(seconds: 2), () {
      isProcessing.value = false;
      Get.offAllNamed('/home');
      Get.snackbar(
        'Success',
        'Payment completed successfully!',
        backgroundColor: AppColors.success,
        colorText: AppColors.textWhite,
        duration: const Duration(seconds: 3),
      );
    });
  }
}

/// Payment screen
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Trip Completed'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            size: 50,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Trip Completed!',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thank you for riding with us',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Trip details
                  Text(
                    'Trip Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                controller.pickup,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                controller.drop,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Fare breakdown
                  Text(
                    'Fare Breakdown',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Base Fare',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '₹${(controller.fare * 0.8).toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Distance Charge',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '₹${(controller.fare * 0.15).toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Service Fee',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '₹${(controller.fare * 0.05).toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(color: AppColors.divider),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '₹${controller.fare.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryYellow,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Payment method
                  Text(
                    'Payment Method',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Column(
                      children: [
                        _buildPaymentOption(
                          context: context,
                          controller: controller,
                          method: 'cash',
                          title: 'Cash',
                          icon: Icons.money,
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentOption(
                          context: context,
                          controller: controller,
                          method: 'wallet',
                          title: 'Wallet',
                          icon: Icons.account_balance_wallet,
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentOption(
                          context: context,
                          controller: controller,
                          method: 'card',
                          title: 'Credit/Debit Card',
                          icon: Icons.credit_card,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Complete payment button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: controller.isProcessing.value
                        ? null
                        : controller.completePayment,
                    child: controller.isProcessing.value
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryBlack,
                              ),
                            ),
                          )
                        : Text('Complete Payment'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required PaymentController controller,
    required String method,
    required String title,
    required IconData icon,
  }) {
    final isSelected = controller.selectedPaymentMethod.value == method;

    return GestureDetector(
      onTap: () => controller.selectPaymentMethod(method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryYellow : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryYellow
                    : AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryBlack
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primaryYellow),
          ],
        ),
      ),
    );
  }
}
