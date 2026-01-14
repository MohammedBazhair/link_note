import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/styles_consts.dart';
import '../../domain/entities/session_member.dart';
import '../controllers/session_providers.dart';
import 'session_members_strip.dart';

class SessionMembersList extends ConsumerWidget {
  const SessionMembersList({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final membersAsync = ref.watch(sessionMembersStreamProvider);

    return membersAsync.when(
      data: (members) {
        return SessionMembersStrip(members: members.toList());
      },
      loading: () {
        final fakeMembers = List.generate(8, (_) => SessionMember.empty());

        return Skeletonizer(
          effect: StylesConsts.shimmerEffect,
          child: SessionMembersStrip(members: fakeMembers),
        );
      },
      error: (error, stackTrace) {
        return const Center(child: Text('خطأ في تحميل الأعضاء'));
      },
    );
  }
}
