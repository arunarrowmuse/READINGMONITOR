import 'package:flutter/material.dart';
import 'Drawer/drawer.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Container(
        child: Scaffold(
      body: Container(
        padding: const EdgeInsets.all(50.0),
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            // Navigator.pushNamed(context, 'HomePage');
          },
          child: ClipRRect(
            child: Image.asset(
              'assets/images/RmLogo.png',
              // height: 64,
              // width: 302,
            ),
          ),
        ),
      ),
    ));
  }
}
