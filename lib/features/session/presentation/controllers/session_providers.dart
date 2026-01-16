import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../note/presentation/controllers/note_providers.dart';
import '../../domain/entities/session_member.dart';
import '../../domain/entities/view_members_params.dart';
import 'session_controller.dart';

final sessionMembersStreamProvider = StreamProvider.autoDispose((ref) {
  final sessionController = ref.read(sessionControllerProvider.notifier);

  final stream = sessionController.fetchMembersOfSession();

  final subsription = stream.listen((members) async {
    if (members.isEmpty) {
      await sessionController.leaveSession();
      return;
    }
  });

  ref.onDispose(subsription.cancel);

  return stream;
});

final sessionMembersFamilyProfiles = FutureProvider
    .family<Map<String, ViewMembersParams>, List<SessionMember>>((
      ref,
      members,
    ) async {
      final userRepo = ref.read(userRepositoryProvider);
      final usersIds = members.map((e) => e.memberId).toList();
      final profilesMap = await userRepo.getProfiles(usersIds);
      final viewMembersMap = profilesMap.map((userId, profile) {
        return MapEntry(
          userId,
          ViewMembersParams(
            id: userId,
            member: members.firstWhere((e) => e.memberId == userId),
            profileEntity: profile,
          ),
        );
      });
      return viewMembersMap;
    });

final sessionProvider = Provider.autoDispose((ref) {
  return ref.watch(sessionControllerProvider).session;
});
