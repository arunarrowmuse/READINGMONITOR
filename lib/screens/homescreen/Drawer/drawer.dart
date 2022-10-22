import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../reportscreen/report.dart';
import 'drawerBody.dart';


/// ABANDONED PAGE ONLY FOR ROUGH USE

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    return Drawer(
        backgroundColor: const Color(0xFF6EB7A1),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 120,
                child: DrawerHeader(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(),
                      SizedBox(
                          height: 160,
                          width: 160,
                          child: Image.asset(
                            "assets/images/RMLogowhite.png",
                            fit: BoxFit.fitWidth,
                          )),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.cancel,
                            size: 40,
                            color: Colors.white,
                          ))
                    ],
                  ),
                ),
              ),
              createDrawerBodyItem(
                  path: "assets/icons/menu/report.png",
                  text: "View Report",
                  onTap: () {
                    setState((){
                    });
                  }),
              createDrawerBodyItem(
                  path: "assets/icons/menu/upload.png",
                  text: 'Upload Report',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Report(
                              page: 1,
                            )));
                  }),
              createDrawerBodyItem(
                  path: "assets/icons/menu/machinecomp.png",
                  text: 'Machine Comparison',
                  onTap: () {}),
              createDrawerBodyItem(
                  path: "assets/icons/menu/charts.png",
                  text: 'Charts',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Report(
                              page: 2,
                            )));
                  }),
              createDrawerBodyItem(
                  path: "assets/icons/menu/machinelist.png",
                  text: 'Machine List',
                  onTap: () {}),
              createDrawerBodyItem(
                  path: "assets/icons/menu/users.png",
                  text: 'Manage Users',
                  onTap: () {}),
              createDrawerBodyItem(
                  path: "assets/icons/menu/meter.png",
                  text: 'Meter Reading',
                  onTap: () {}),
              createDrawerBodyItem(
                  path: "assets/icons/menu/profile.png",
                  text: 'Profile',
                  onTap: () {}),
              createDrawerBodyItem(
                  path: "assets/icons/menu/todo.png",
                  text: 'To Do List',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Report(
                              page: 3,
                            )));
                  }),
            ],
          ),
        ));
  }
}
