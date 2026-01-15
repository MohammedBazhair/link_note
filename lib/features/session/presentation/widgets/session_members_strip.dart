import 'package:flutter/material.dart';

import '../../../user/presentation/widgets/user_avatar.dart';
import '../../domain/entities/session_member.dart';

class SessionMembersStrip extends StatelessWidget {
  const SessionMembersStrip({super.key, required this.members});

  final List<SessionMember> members;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final member = members[index];
          return SessionMemberItem(member: member);
        },
      ),
    );
  }
}

class SessionMemberItem extends StatelessWidget {
  const SessionMemberItem({super.key, required this.member});

  final SessionMember member;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PlaceholderAvatar(),
        const SizedBox(height: 10),
        Text(member.role.label,),
      ],
    );
  }
}
