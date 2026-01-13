import 'package:flutter/material.dart';

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
      decoration: BoxDecoration(
        color: const Color(0xFF151825),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: SessionMode.values.map((m) {
          final selected = m == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF01B7C1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  m == SessionMode.create ? 'إنشاء جلسة' : 'الانضمام',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey,
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
