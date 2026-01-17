import 'package:flutter/material.dart';
import '../../constants/assets/app_assets.dart';
import '../../constants/colors/colors.dart';
import '../widgets/credits_widget.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 27, 29, 43), Color(0xFF151825)],
          ),
        ),
        child: Column(
          children: [
            const SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BackButton(),
                    Text('حول التطبيق'),
                    CreditsWidget(),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage(Assets.imagesAppLogo),
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Link Note',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: .4,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Version 2.0.0',
                        style: TextStyle(
                          fontSize: 13,
                          color: DarkColors.secondFont,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  /// ================= Info =================
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151825),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: DarkColors.primary.withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: DarkColors.primary.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: -15,
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        _InfoCard(
                          icon: Icons.person_outline,
                          title: 'المطوّر',
                          value: 'Mohammed Faisal',
                        ),
                        Divider(),
                        _InfoCard(
                          icon: Icons.update_rounded,
                          title: 'آخر تحديث',
                          value: 'يناير 2026',
                        ),
                        Divider(),
                        _InfoCard(
                          icon: Icons.phone_rounded,
                          title: 'الدعم',
                          value: '776 793 111',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  /// ================= Footer =================
                  const Directionality(
                    textDirection: TextDirection.ltr,
                    child: Column(
                      children: [
                        Text(
                          'BUILT WITH  💙',
                          style: TextStyle(
                            fontSize: 12,
                            color: DarkColors.secondFont,
                            letterSpacing: 2.5,
                          ),
                        ),
                        SizedBox(height: 10),

                        Text(
                          'by Mo.Bazohair',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,

                            color: Color(0xCD01B7C1),
                          ),
                        ),
                        SizedBox(height: 8),

                        Text(
                          '© 2026 ALL Rigts Reserved',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xDC3E4646),
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
    );
  }
}

/// ================= Info Card =================
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 17,
        backgroundColor: DarkColors.primary.withOpacity(.15),
        child: Icon(icon, color: DarkColors.primary, size: 20),
      ),
      titleTextStyle: const TextStyle(color: DarkColors.secondFont),
      subtitleTextStyle: const TextStyle(
        color: Color.fromARGB(185, 208, 242, 245),
        fontWeight: FontWeight.w600,
      ),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
