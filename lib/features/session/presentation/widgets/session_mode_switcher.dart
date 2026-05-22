import 'package:flutter/material.dart';

import '../../../../core/constants/colors/colors.dart';
import '../../domain/entities/session_mode.dart';

class SessionModeSwitcher extends StatelessWidget {
  const SessionModeSwitcher({
    super.key,
    required this.mode,
    required this.onChanged,
  });
  final SessionMode mode;
  final ValueChanged<SessionMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        
        color: const Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        spacing: 5,
        children: SessionMode.values.map((m) {
          final selected = m == mode;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF151825)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  m == SessionMode.create ? 'إنشاء جلسة' : 'الانضمام',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : DarkColors.secondFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
