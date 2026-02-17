import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/neumorphic_widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqItems = [
      {
        'question': 'Ninawezaje kununua hadithi?',
        'answer': 'Bonyeza kwenye hadithi unayotaka, kisha bofya kitufe cha "Nunua". Chagua njia ya malipo na kamilisha muamala.',
      },
      {
        'question': 'Je, ninaweza kusoma bila mtandao?',
        'answer': 'Ndio! Baada ya kununua hadithi, bonyeza kitufe cha kupakua ili uweze kusoma bila mtandao.',
      },
      {
        'question': 'Ninawezaje kuwa mwandishi?',
        'answer': 'Nenda kwenye ukurasa wa wasifu na bofya "Kuwa Mwandishi". Fuata hatua za usajili na uanze kupakia hadithi zako.',
      },
      {
        'question': 'Je, nina malipo ya kila mwezi?',
        'answer': 'Hapana! StoryZoo haina malipo ya kila mwezi. Ulipia tu hadithi unazotaka kununua.',
      },
      {
        'question': 'Ninawezaje kupata msaada wa ziada?',
        'answer': 'Wasiliana nasi kupitia barua pepe: support@storyzoo.co.tz au piga simu: +255 754 123 456',
      },
      {
        'question': 'Sera ya kurejesha pesa ni gani?',
        'answer': 'Unaweza kuomba kurejesha pesa ndani ya siku 7 baada ya kununua ikiwa hadithi haikufaa.',
      },
    ];

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
                            'Msaada',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Maswali yanayoulizwa mara kwa mara',
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
                    // Contact cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildContactCard(
                            context,
                            Icons.email,
                            'Barua Pepe',
                            AppColors.info,
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Inafungua programu ya barua pepe...')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildContactCard(
                            context,
                            Icons.phone,
                            'Piga Simu',
                            AppColors.success,
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Inafungua programu ya simu...')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // FAQ Section
                    const Text(
                      'Maswali Yanayoulizwa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...faqItems.map((faq) => _buildFaqItem(faq)).toList(),

                    const SizedBox(height: 32),

                    // Additional resources
                    const Text(
                      'Vyanzo Vya Ziada',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildResourceCard(
                      context,
                      'Miongozo ya Matumizi',
                      'Jifunze jinsi ya kutumia programu',
                      Icons.menu_book,
                      AppColors.sunsetOrange,
                    ),

                    const SizedBox(height: 12),

                    _buildResourceCard(
                      context,
                      'Ripoti Tatizo',
                      'Taarifa ya matatizo ya kiufundi',
                      Icons.bug_report,
                      AppColors.error,
                    ),

                    const SizedBox(height: 12),

                    _buildResourceCard(
                      context,
                      'Pendekeza Kipengele',
                      'Tuambie unachotaka kuona',
                      Icons.lightbulb,
                      AppColors.warning,
                    ),

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

  Widget _buildContactCard(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicCard(
        borderRadius: 20,
        color: AppColors.cardBackground,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
        ),
        child: NeumorphicCard(
          borderRadius: 20,
          color: AppColors.cardBackground,
          padding: EdgeInsets.zero,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.help_outline, color: AppColors.info, size: 20),
            ),
            title: Text(
              faq['question'],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              Text(
                faq['answer'],
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inafungua $title...')),
        );
      },
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
