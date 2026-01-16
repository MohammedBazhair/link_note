import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/colors/colors.dart';
import '../../../../core/presentation/widgets/conditional_builder.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../../../user/presentation/widgets/user_avatar.dart';
import '../../domain/entities/session_member.dart';
import '../../domain/entities/view_members_params.dart';
import '../controllers/session_providers.dart';

class SessionMembersStrip extends ConsumerWidget {
  const SessionMembersStrip({super.key, required this.members});

  final List<SessionMember> members;

  List<String> get usersIds => members.map((e) => e.memberId).toList();

  @override
  Widget build(BuildContext context, ref) {
    final asyncProfiles = ref.watch(sessionMembersFamilyProfiles(members));

    return asyncProfiles.when(
      data: (profiles) {
        return _SessionMembersList(members: profiles.values.toList());
      },
      loading: () {
        final fake = List.generate(5, (_) => ViewMembersParams.fake());
        return Skeletonizer(child: _SessionMembersList(members: fake));
      },
      error: (error, stackTrace) =>
          const Center(child: Text('حدثت مشكلة في تحميل بيانات الأعضاء')),
    );
  }
}

class _SessionMembersList extends StatelessWidget {
  const _SessionMembersList({required this.members});

  final List<ViewMembersParams> members;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
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

  final ViewMembersParams member;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AvatarWidget(member.profileEntity),
        const SizedBox(height: 5),
        Text(
          member.member.role.label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: DarkColors.secondFont,
            fontSize: 13,
          ),
        ),
        Consumer(
          builder: (_, ref, __) {
            final userId = ref
                .watch(userControllerProvider.notifier)
                .currentUser
                ?.id;

            return ConditionalBuilder(
              condition: member.member.memberId == userId,
              builder: (_) =>
                  const Text('(أنت)', style: TextStyle(fontSize: 10)),
              fallback: (_) => const SizedBox.shrink(),
            );
          },
        ),
      ],
    );
  }
}
