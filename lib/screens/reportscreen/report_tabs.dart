import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../routes/routes.dart';
import '../auth/adduser.dart';
import '../auth/login_screen.dart';
import '../auth/switchuser.dart';
import '../homescreen/switchscreen.dart';
import 'viewfluegas.dart';
import 'viewgeb.dart';
import 'viewmachines.dart';
import 'viewmanometer.dart';
import 'viewmiscellaneous.dart';
import 'viewstreamboiler.dart';
import 'viewsupplypump.dart';
import 'viewthermopack.dart';
import 'viewutility.dart';
import 'viewwaterquality.dart';

import 'package:http/http.dart' as http;

class ReportTabs extends StatefulWidget {
  int selectedPage;

  ReportTabs({Key? key, required this.selectedPage}) : super(key: key);

  @override
  State<ReportTabs> createState() => _ReportTabsState();
}

class _ReportTabsState extends State<ReportTabs> {
  bool isLoad = false;
  String UserName = '';

  void logoutUser() async {
    print("logout run");
    setState(() {
      isLoad = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenvalue = prefs.getString("token");
    print("tokenvalue");
    print(tokenvalue);
    final response = await http.post(
      Uri.parse("https://test.readingmonitor.co/api/logout"),
      // Uri.parse('${Constants.weblink}' + Routes.LOGOUT),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        'token': tokenvalue.toString(),
      }),
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      //----------------------------------------------------
      String Currentname = "";
      String Currentid = "";
      String Currenttoken = "";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Currentid = prefs.getInt('userid').toString();
      Currenttoken = prefs.getString('token')!;
      Currentname = prefs.getString("name")!;
      String? data = prefs.getString("UserList");
      List UserList = jsonDecode(data!);
      if (UserList.length == 0) {
        prefs.setInt('userid', 0);
        prefs.setString('token', "");
        prefs.setString("name", "");
        Constants.showtoast("Logged Out Successfully!");
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false);
      }
      for (int i = 0; i < UserList.length; i++) {
        if (UserList[i]['token'] == Currenttoken) {
          /// check if token matches
          UserList.remove(UserList[i]);

          /// delete if token matches
          prefs.setString("UserList", jsonEncode(UserList));

          /// save data
          String? data = prefs.getString("UserList");

          /// fetch data again
          UserList = jsonDecode(data!);

          /// store in a list
          /// RIGHT NOW LETS MAKE THE TOP USER ON THE LIST
          /// GIVE THE CURRENT USER POSITION AGAIN
          // UserList = jsonDecode(data);
          print("Look for the length of the data");
          print(UserList.length);
          print(UserList);
          if (UserList.length == 0) {
            prefs.setInt('userid', 0);
            prefs.setString('token', "");
            prefs.setString("name", "");
            Constants.showtoast("Logged Out Successfully!");
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false);
          } else {
            prefs.setInt('userid', int.parse(UserList[0]['UserID']));
            prefs.setString('token', UserList[0]['token']);
            prefs.setString('name', UserList[0]['name']);
            Constants.showtoast(
                "User Logged Out! \n User Changed to ${UserList[0]['name']}!");
            setState(() {
              isLoad = false;
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => Switcher(values: 0),
                  ),
                      (Route<dynamic> route) => false);
            });
          }
        } else {
          if (UserList.length == 0) {
            prefs.setInt('userid', 0);
            prefs.setString('token', "");
            prefs.setString("name", "");
            Constants.showtoast("Logged Out Successfully!");
            setState(() {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (Route<dynamic> route) => false);
            });
          } else {
            prefs.setInt('userid', int.parse(UserList[0]['UserID']));
            prefs.setString('token', UserList[0]['token']);
            prefs.setString('name', UserList[0]['name']);
            Constants.showtoast(
                "User Logged Out! \n User Changed to ${UserList[0]['name']}!");

            /// give back main to the previous user
            setState(() {
              isLoad = false;
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => Switcher(values: 0),
                  ),
                      (Route<dynamic> route) => false);
            });
          }
        }
      }
    } else {
      setState(() {
        isLoad = false;
      });
      print(response.statusCode);
      print(response.body);
      Constants.showtoast("Error while Logout!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.selectedPage,
      length: 10,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Image.asset(
              'assets/images/RmLogo.png',
              // height: 64,
              // width: 302,
            ),
          ),
          actions: <Widget>[
            PopupMenuButton(
              color: const Color(0xFF6EB7A1),
              // color: Constants.primaryColor,
              itemBuilder: (context) => [
                PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Icons.add_circle, color: Colors.white),
                        Text("  Add User",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins)),
                      ],
                    ),
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddUser(),
                        ),
                      );
                    }),
                PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Icons.switch_account, color: Colors.white),
                        Text("  Switch User",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins)),
                      ],
                    ),
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SwitchUser(),
                        ),
                      );
                    }),
                PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Icons.logout_outlined, color: Colors.white),
                        Text("  Log Out",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins)),
                      ],
                    ),
                    onTap: () async {
                      logoutUser();
                      // SharedPreferences prefs =
                      //     await SharedPreferences.getInstance();
                      // prefs.setInt('userid', 0);
                      // prefs.setString('token', "");
                      // prefs.setString("name", "");
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => const LoginScreen(),
                      //   ),
                      // );
                    }),
              ],
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: ClipRRect(
                  child: Image.asset(
                    'assets/images/user1.png',
                    height: 41.19,
                    width: 41.19,
                  ),
                ),
              ),
            ),
          ],
          elevation: 0,
          leading: Builder(builder: (context) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                // Scaffold.of(context).openDrawer();
                // print("object");
              },
              child: Container(
                height: double.infinity,
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/icons/Back.png",
                  width: 40,
                  fit: BoxFit.contain,
                ),
              ),
            );
          }),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 60,
              child: AppBar(
                backgroundColor: Colors.white,
                // backgroundColor: Color.fromRGBO(65, 102, 60, 1),
                bottom: TabBar(
                  indicatorColor: Colors.red,
                  isScrollable: true,
                  tabs: [
                    Tab(
                        child: Text("Utility",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                    Tab(
                        child: Text("Steam Boiler",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                    Tab(
                        child: Text("Thermopack",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                    Tab(
                        child: Text("Machines",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                    Tab(
                        child: Text("Water Quality",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                    Tab(
                        child: Text("Supply Pump & Input",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                    Tab(
                        child: Text("GEB",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                    Tab(
                        child: Text("Mano Meter",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                    Tab(
                        child: Text("Flue Gas",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                    Tab(
                        child: Text("Miscellaneous",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  ViewUtility(),
                  ViewSteamBoiler(),
                  ViewThermoPack(),
                  VIewMachines(),
                  ViewWaterQuality(),
                  ViewSupplyPump(),
                  ViewGEB(),
                  ViewManoMeter(),
                  ViewFlueGas(),
                  ViewMisc(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
