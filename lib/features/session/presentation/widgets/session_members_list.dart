import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/styles_consts.dart';
import '../../../user/presentation/widgets/user_avatar.dart';
import '../../domain/entities/session_member.dart';

class SessionMembersList extends StatelessWidget {
  const SessionMembersList({super.key, required this.membersStream});

  final Stream<Set<SessionMember>> membersStream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: membersStream,
      builder: (context, snapshot) {
        final members = snapshot.data ??{};
        final fakeMembers = List.generate(8, (_) => SessionMember.empty());
        final enabledFake = snapshot.connectionState == ConnectionState.waiting;

        final displayMembers = enabledFake ? fakeMembers : members.toList();

        return SizedBox(
          height: 130,
          child: Skeletonizer(
            effect: StylesConsts.shimmerEffect,
            enabled: enabledFake,
            child: ListView.separated(
              itemCount: displayMembers.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final member = displayMembers[index];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PlaceholderAvatar(),
                    const SizedBox(height: 10),
                    Text(member.role.name),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
