import 'package:flutter/material.dart';
import '../../constants/assets/app_assets.dart';
import '../../constants/colors/colors.dart';
import '../widgets/tile_wrapper.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حول التطبيق'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          /// ================= Header =================
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  DarkColors.primary.withOpacity(.5),
                  DarkColors.primary.withOpacity(.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: DarkColors.primary.withOpacity(.35),
                  blurRadius: 11,

                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Image.asset(Assets.imagesAppLogo, width: 65),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Link Note',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: .4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Version 2.0.0',
                  style: TextStyle(fontSize: 13, color: DarkColors.secondFont),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          /// ================= Info =================
          const _InfoCard(
            icon: Icons.person_outline,
            title: 'المطوّر',
            value: 'Mohammed Faisal',
          ),
          const _InfoCard(
            icon: Icons.update_rounded,
            title: 'آخر تحديث',
            value: 'ديسمبر 2025',
          ),
          const _InfoCard(
            icon: Icons.phone_rounded,
            title: 'الدعم',
            value: '776 793 111',
          ),
          const SizedBox(height: 50),

          /// ================= Footer =================
          const Column(
            children: [
              Text(
                'Built with 💙',
                style: TextStyle(fontSize: 12, color: DarkColors.icon),
              ),
              SizedBox(height: 6),
              Text(
                'by Mo.Bazohair',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DarkColors.primary,
                ),
              ),
            ],
          ),
        ],
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
    return TileWrapper(
      child: ListTile(
        tileColor: const Color(0xFF0C7395),
        leading: CircleAvatar(
          radius: 17,
          backgroundColor: DarkColors.primary.withOpacity(.15),
          child: Icon(icon, color: DarkColors.primary, size: 20),
        ),
        title: Text(title),
        subtitle: Text(
          value,
        ),
      ),
    );
  }
}
