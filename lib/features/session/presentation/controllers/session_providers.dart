import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../../../note/presentation/controllers/note_providers.dart';
import '../../../user/domain/entities/profile.dart';
import '../../domain/entities/session_members_key.dart';
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

final sessionMembersFamilyProfiles = FutureProvider.autoDispose
    .family<Map<String, ViewMembersParams>, SessionMembersKey>((
      ref,
      key,
    ) async {
      if (key.memberIds.isEmpty) {
        return <String, ViewMembersParams>{};
      }

      if (key.memberIds.any((id) => id.isEmpty)) {
        return key.membersMap.map((id, m) {
          return MapEntry(id, ViewMembersParams.fake());
        });
      }

      try {
        final userRepo = ref.read(userRepositoryProvider);
        final profilesMap = await userRepo.getProfiles(key.memberIds);
        final viewMembersMap = <String, ViewMembersParams>{};

        // التأكد من إضافة جميع الأعضاء حتى لو لم يكن لديهم profile
        for (final userId in key.memberIds) {
          final member = key.membersMap[userId];
          if (member == null) continue;

          final profile = profilesMap[userId];

          // إذا لم يكن هناك profile، استخدم profile افتراضي
          final profileEntity =
              profile ??
              ProfileEntity(
                userId: userId,
                username: userId, // استخدام userId كاسم افتراضي
                updatedAt: DateTime.now().toUtc(),
                credits: 0
              );

          viewMembersMap[userId] = ViewMembersParams(
            id: userId,
            member: member,
            profileEntity: profileEntity,
          );
        }

        return viewMembersMap;
      } catch (e, stackTrace) {
        Logger.log(error: e, stackTrace: stackTrace);
        rethrow;
      }
    });

final sessionProvider = Provider.autoDispose((ref) {
  return ref.watch(sessionControllerProvider).session;
});
