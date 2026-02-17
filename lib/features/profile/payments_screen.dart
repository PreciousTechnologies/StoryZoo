import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundLight,
              AppColors.warmBeige,
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
                          Text(
                            'Malipo',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Njia za malipo',
                            style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
                                  color: AppColors.textSecondary,
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
                    // Payment methods section
                    const Text(
                      'Njia za Malipo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ..._paymentMethods.map((method) => _buildPaymentMethodCard(method)).toList(),

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
                          Text(
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
                    const Text(
                      'Historia ya Malipo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ..._transactions.map((transaction) => _buildTransactionCard(transaction)).toList(),

                    const SizedBox(height: 100),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: NeumorphicCard(
        borderRadius: 20,
        color: AppColors.cardBackground,
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
                      Text(
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
                          child: const Text(
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
                  Text(
                    method['number'],
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) => [
                if (!method['isDefault'])
                  const PopupMenuItem(
                    value: 'default',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 20, color: AppColors.textPrimary),
                        SizedBox(width: 12),
                        Text('Weka Chaguo-msingi'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20, color: AppColors.textPrimary),
                      SizedBox(width: 12),
                      Text('Hariri'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                      SizedBox(width: 12),
                      Text('Futa', style: TextStyle(color: AppColors.error)),
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
                    SnackBar(content: Text('${method['name']} imewekwa kuwa chaguo-msingi')),
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
    final isNegative = transaction['amount'] < 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NeumorphicCard(
        borderRadius: 16,
        color: AppColors.cardBackground,
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
                  Text(
                    transaction['title'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction['date'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
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
                  child: Text(
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
        title: const Text('Ongeza Njia ya Malipo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Namba ya Simu',
                hintText: '+255 7XX XXX XXX',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Chagua Mtoa Huduma',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ['M-Pesa', 'Tigopesa', 'Airtel Money', 'Halopesa']
                  .map((provider) => DropdownMenuItem(
                        value: provider,
                        child: Text(provider),
                      ))
                  .toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ghairi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Njia ya malipo imeongezwa')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sunsetOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ongeza'),
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
        title: const Text('Futa Njia ya Malipo'),
        content: Text('Je, una uhakika unataka kufuta $methodName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ghairi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$methodName imefutwa')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Futa'),
          ),
        ],
      ),
    );
  }
}
