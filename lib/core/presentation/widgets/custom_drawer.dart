import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link_note/features/note/presentation/screens/notes_list_screen.dart';
import 'package:link_note/features/user/presentation/widgets/user_profile.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      
      child:ListView(
        children: [
          UserProfile(),
          ListTile(
            leading: Icon(Icons.sticky_note_2_outlined),
            title: Text('Notes'),
            onTap: () {
                            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotesListScreen(),
                ),
              );

            },
          ),
          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text('Sign Out'),
            onTap: () {
                            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotesListScreen(),
                ),
              );

            },
          ),
        ],
      ) ,
    );
  }
}