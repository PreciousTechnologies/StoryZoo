import 'package:flutter/material.dart';
import '../../shared/widgets/app_text.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/i18n/app_i18n.dart';
import '../../shared/widgets/micro_interactions.dart';
import '../../shared/widgets/neumorphic_widgets.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'M-Pesa',
      'icon': Icons.phone_android,
      'color': AppColors.success,
      'number': '+255 754 ***789',
      'isDefault': true,
    },
    {
      'name': 'Tigopesa',
      'icon': Icons.phone_iphone,
      'color': AppColors.info,
      'number': '+255 765 ***456',
      'isDefault': false,
    },
    {
      'name': 'Airtel Money',
      'icon': Icons.phone,
      'color': AppColors.error,
      'number': '+255 782 ***123',
      'isDefault': false,
    },
  ];

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Simba Mjanja',
      'amount': -2000,
      'date': 'Leo, 14:30',
      'status': 'Imekamilika',
    },
    {
      'title': 'Pembe ya Ndovu',
      'amount': -1500,
      'date': 'Jana, 10:15',
      'status': 'Imekamilika',
    },
    {
      'title': 'Twiga na Sungura',
      'amount': -1000,
      'date': 'Juzi, 16:45',
      'status': 'Imekamilika',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundTop = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final backgroundBottom = isDark ? const Color(0xFF2A1B12) : AppColors.warmBeige;
    final cardSurface = isDark ? const Color(0xFF2F2118) : AppColors.cardBackground;
    final secondaryText = isDark ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundTop,
              backgroundBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Row(
                  children: [
                    NeumorphicIconButton(
                      icon: Icons.arrow_back,
                      size: 50,
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Malipo',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          AppText(
                            'Njia za malipo',
                            style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
                                  color: secondaryText,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  children: [
                    StaggeredFadeSlide(
                      order: 0,
                      child: NeumorphicCard(
                        borderRadius: 22,
                        color: cardSurface,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.account_balance_wallet_rounded, color: AppColors.savannaGreen),
                              SizedBox(width: 8),
                              AppText(
                                'Wallet Summary',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          AppText(
                            'TSh 48,000',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 28,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            'Matumizi mwezi huu: TSh 8,500',
                            style: TextStyle(fontSize: 12, color: secondaryText),
                          ),
                        ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Payment methods section
                    AppText(
                      'Njia za Malipo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ..._paymentMethods.map((method) {
                      final index = _paymentMethods.indexOf(method);
                      return StaggeredFadeSlide(order: index + 1, child: _buildPaymentMethodCard(method));
                    }).toList(),

                    const SizedBox(height: 12),

                    // Add payment method button
                    NeumorphicButton(
                      onPressed: () {
                        _showAddPaymentMethodDialog();
                      },
                      color: AppColors.sunsetOrange,
                      height: 60,
                      borderRadius: 20,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, color: Colors.white),
                          SizedBox(width: 12),
                          AppText(
                            'Ongeza Njia ya Malipo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Transaction history
                    AppText(
                      'Historia ya Malipo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ..._transactions.map((transaction) {
                      final index = _transactions.indexOf(transaction);
                      return StaggeredFadeSlide(order: index + 4, child: _buildTransactionCard(transaction));
                    }).toList(),

                    const SizedBox(height: 120),

                    // Subscription CTA
                    NeumorphicCard(
                      borderRadius: 22,
                      color: cardSurface,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText(
                            'Story Zoo Premium',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          AppText(
                            'Lipa kwa Pesapal na fungua vipengele vya ziada.',
                            style: TextStyle(fontSize: 12, color: secondaryText),
                          ),
                          const SizedBox(height: 12),
                          NeumorphicButton(
                            onPressed: () {
                              context.push('/subscribe');
                            },
                            color: AppColors.sunsetOrange,
                            height: 52,
                            borderRadius: 18,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_outline, color: Colors.white),
                                SizedBox(width: 10),
                                AppText(
                                  'Lipa Premium',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: NeumorphicCard(
        borderRadius: 20,
        color: isDark ? const Color(0xFF2F2118) : AppColors.cardBackground,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: method['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(method['icon'], color: method['color'], size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppText(
                        method['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (method['isDefault'])
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AppText(
                            'Chaguo-msingi',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    method['number'],
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              icon: Icon(Icons.more_vert, color: isDark ? Colors.white60 : AppColors.textMuted),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) => [
                if (!method['isDefault'])
                  const PopupMenuItem(
                    value: 'default',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 20, color: AppColors.textPrimary),
                        SizedBox(width: 12),
                        AppText('Weka Chaguo-msingi'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20, color: AppColors.textPrimary),
                      SizedBox(width: 12),
                      AppText('Hariri'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                      SizedBox(width: 12),
                      AppText('Futa', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteDialog(method['name']);
                } else if (value == 'default') {
                  setState(() {
                    for (var m in _paymentMethods) {
                      m['isDefault'] = m['name'] == method['name'];
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: AppText('${method['name']} imewekwa kuwa chaguo-msingi')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isNegative = transaction['amount'] < 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NeumorphicCard(
        borderRadius: 16,
        color: isDark ? const Color(0xFF2F2118) : AppColors.cardBackground,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isNegative
                    ? AppColors.error.withOpacity(0.1)
                    : AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isNegative ? Icons.arrow_downward : Icons.arrow_upward,
                color: isNegative ? AppColors.error : AppColors.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    transaction['title'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    transaction['date'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText(
                  'TSh ${transaction['amount'].abs().toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isNegative ? AppColors.error : AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AppText(
                    transaction['status'],
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: AppText('Ongeza Njia ya Malipo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: context.tr('Namba ya Simu'),
                hintText: context.tr('+255 7XX XXX XXX'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: context.tr('Chagua Mtoa Huduma'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ['M-Pesa', 'Tigopesa', 'Airtel Money', 'Halopesa']
                  .map((provider) => DropdownMenuItem(
                        value: provider,
                        child: AppText(provider),
                      ))
                  .toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText('Ghairi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: AppText('Njia ya malipo imeongezwa')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sunsetOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: AppText('Ongeza'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String methodName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: AppText('Futa Njia ya Malipo'),
        content: AppText('Je, una uhakika unataka kufuta $methodName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText('Ghairi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: AppText('$methodName imefutwa')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: AppText('Futa'),
          ),
        ],
      ),
    );
  }
}

