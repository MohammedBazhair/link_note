import 'package:flutter/material.dart';
import 'package:link_note/features/user/services/user_service.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserService().currentUser;

    return UserAccountsDrawerHeader(
      accountName: null,
      accountEmail: Text(user?.email ?? '-'),
      currentAccountPictureSize: Size.square(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
