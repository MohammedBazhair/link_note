import 'package:flutter/material.dart';
import 'package:link_note/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:link_note/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:link_note/features/note/presentation/screens/notes_list_screen.dart';
import 'package:link_note/features/user/presentation/widgets/user_profile.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  bool get isUserLogin => true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.only(top: 50),
        children: [
          if (isUserLogin) UserProfile() else ...[SignInTile(), SignUpTile()],
          SizedBox(height: 15),
          NotesTile(),
          if (isUserLogin) SignOutTile(),
        ],
      ),
    );
  }
}

class SignInTile extends StatelessWidget {
  const SignInTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.login),
      title: Text('Login In'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      },
    );
  }
}

class SignUpTile extends StatelessWidget {
  const SignUpTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.login_outlined),
      title: Text('Sign Up'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUpScreen()),
        );
      },
    );
  }
}

class SignOutTile extends StatelessWidget {
  const SignOutTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.login_outlined),
      title: Text('Sign Out'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignOutTile()),
        );
      },
    );
  }
}

class NotesTile extends StatelessWidget {
  const NotesTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.sticky_note_2_outlined),
      title: Text('Notes'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotesListScreen()),
        );
      },
    );
  }
}
