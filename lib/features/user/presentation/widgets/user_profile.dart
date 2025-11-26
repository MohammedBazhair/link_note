import 'package:flutter/material.dart';
import 'package:link_note/features/user/services/user_service.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserService().currentUser;
    return SizedBox(
      height: 100,
      child: ListTile(
        title: Text(user?.email ?? 'No email!'),
        subtitle: Text(user?.createdAt ?? '-'),
      ),
    );
  }
}
