import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/colors/colors.dart';
import '../../../../core/presentation/widgets/conditional_builder.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../../../user/presentation/widgets/user_avatar.dart';
import '../../domain/entities/session_member.dart';
import '../../domain/entities/session_members_key.dart';
import '../../domain/entities/view_members_params.dart';
import '../controllers/session_providers.dart';

class SessionMembersStrip extends ConsumerStatefulWidget {
  const SessionMembersStrip({super.key, required this.members});

  final List<SessionMember> members;

  @override
  ConsumerState<SessionMembersStrip> createState() =>
      _SessionMembersStripState();
}

class _SessionMembersStripState extends ConsumerState<SessionMembersStrip> {
  SessionMembersKey _membersKey = const SessionMembersKey([], {});

  @override
  void initState() {
    super.initState();

    _updateMembersKey();
  }

  @override
  void didUpdateWidget(SessionMembersStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = oldWidget.members.map((e) => e.memberId).toList()..sort();
    final newIds = widget.members.map((e) => e.memberId).toList()..sort();
    if (oldIds.length != newIds.length || !_listEquals(oldIds, newIds)) {
      _updateMembersKey();
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _updateMembersKey() {
    final memberIds = toUserIds(widget.members)..sort();
    final membersMap = {for (final m in widget.members) m.memberId: m};

    _membersKey = SessionMembersKey(memberIds, membersMap);
  }

  List<String> toUserIds(List<SessionMember> membersList) {
    return membersList.map((e) => e.memberId).toList();
  }

  @override
  Widget build(BuildContext context) {
    // إذا كانت القائمة فارغة، لا نحتاج لتحميل أي شيء
    if (_membersKey.memberIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final asyncProfiles = ref.watch(sessionMembersFamilyProfiles(_membersKey));
    return asyncProfiles.when(
      data: (profiles) {
        return _SessionMembersList(members: profiles.values.toList());
      },
      loading: () {
        final fake = List.generate(5, (_) => ViewMembersParams.fake());
        return Skeletonizer(child: _SessionMembersList(members: fake));
      },
      error: (error, stackTrace) {
        debugPrint('Error in sessionMembersFamilyProfiles: $error');
        return const Center(child: Text('حدثت مشكلة في تحميل بيانات الأعضاء'));
      },
    );
  }
}

class _SessionMembersList extends StatelessWidget {
  const _SessionMembersList({required this.members});

  final List<ViewMembersParams> members;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              AvatarWidget(member.profileEntity),
              if (member.member.isHost)
                PositionedDirectional(
                  bottom: 0,
                  start: 0,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: const Icon(Icons.manage_accounts_rounded, size: 22),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            member.profileEntity.username,
            maxLines: 2,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: DarkColors.secondFont,
              height: 1.4,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),

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
      ),
    );
  }
}
