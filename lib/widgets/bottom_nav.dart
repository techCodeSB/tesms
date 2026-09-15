import 'package:flutter/material.dart';
import 'package:tesms/home.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: (value) {
        if (value == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        } else if (value == 1) {
          // Setting page Here.
        }
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}
