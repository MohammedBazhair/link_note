import 'package:link_note/features/user/domain/entities/profile.dart';

sealed class UserState {
  final ProfileEntity profile;

  UserState(this.profile);
}

class UserInitialState extends UserState {
  UserInitialState() : super(ProfileEntity.guest());
}

class UserUpdateProfileState extends UserState {
  UserUpdateProfileState(super.profile);
}

class UserLoadProfileState extends UserState {
  UserLoadProfileState(super.profile);
}

class UserErrorState extends UserState {
  final String message;
  UserErrorState(super.profile, this.message);
}
