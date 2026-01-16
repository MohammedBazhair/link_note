import '../../../user/domain/entities/profile.dart';
import 'session_member.dart';

class ViewMembersParams {
  ViewMembersParams({
    required this.id,
    required this.member,
    required this.profileEntity,
  });

  factory ViewMembersParams.fake() {
    return ViewMembersParams(
      id: '',
      member: SessionMember.empty(),
      profileEntity: ProfileEntity.guest(),
    );
  }

  final String id;
  final SessionMember member;
  final ProfileEntity profileEntity;
}
