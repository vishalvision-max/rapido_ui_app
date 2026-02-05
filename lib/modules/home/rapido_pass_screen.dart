import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/colors.dart';

class RapidoPassScreen extends StatelessWidget {
  const RapidoPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Rapido Pass',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.darkGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'RAPIDO PASS',
                          style: TextStyle(
                            color: AppColors.primaryYellow,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Save up to ₹500/month',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Valid on Auto & Bike rides',
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              child: const Text(
                'Choose Your Plan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            _buildPassPlan(
              'Bronze',
              '₹49',
              '5 Rides',
              'Flat ₹20 OFF on all rides',
            ),
            _buildPassPlan(
              'Silver',
              '₹99',
              '15 Rides',
              'Flat ₹25 OFF on all rides',
              isPopular: true,
            ),
            _buildPassPlan(
              'Gold',
              '₹199',
              'Unlimited',
              'Flat ₹30 OFF on all rides',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassPlan(
    String name,
    String price,
    String limit,
    String benefit, {
    bool isPopular = false,
  }) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPopular
              ? AppColors.primaryYellow.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPopular ? AppColors.primaryYellow : Colors.grey[200]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (isPopular)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlack,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'BEST VALUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    benefit,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    limit,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const Text(
                  '/mo',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
