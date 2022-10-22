import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class SwitchUser extends StatefulWidget {
  const SwitchUser({Key? key}) : super(key: key);

  @override
  State<SwitchUser> createState() => _SwitchUserState();
}

class _SwitchUserState extends State<SwitchUser> {
  var UserList;
  bool isload = false;
  String Currentname = "";
  String Currentid = "";
  String Currenttoken = "";
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    getUserList();
  }

  void getUserList() async {
    setState(() {
      isload = true;
    });
    prefs = await SharedPreferences.getInstance();
    // prefs.getString("UserList");
    String? data = prefs.getString("UserList");
    UserList = jsonDecode(data!);
    print(UserList);
    print(UserList.length);
    Currentid = prefs.getInt('userid').toString();
    Currenttoken = prefs.getString('token')!;
    Currentname = prefs.getString("name")!;
    print("Current Profile is");
    print(Currentid);
    print(Currentname);
    print(Currenttoken);
    setState(() {
      isload = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
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
            color: Colors.white,
            // color: Constants.primaryColor,
            itemBuilder: (context) => [],
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
              // Scaffold.of(context).openDrawer();
              Navigator.pop(context);
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18),
                child: Text(
                  "Switch User",
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: Constants.popinsbold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset("assets/images/user1.png"),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Current User : ",
                                style: TextStyle(
                                    // color: Colors.white,
                                    fontSize: 10,
                                    // fontWeight: FontWeight.w700,
                                    fontFamily: Constants.popins),
                              ),
                              Text(
                                Currentname,
                                style: TextStyle(
                                    // color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: Constants.popins),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Divider(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Switch to",
                  style: TextStyle(
                    // color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: Constants.popinsbold,
                  ),
                ),
              ),
              (isload == true)
                  ? SizedBox(
                      height: 500,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Constants.primaryColor,
                        ),
                      ),
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: ListView.builder(
                          itemCount: UserList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return (UserList[index]['token'] != Currenttoken)
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0, right: 30.0),
                                    child: Card(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                    height: 50,
                                                    child: Image.asset(
                                                        "assets/images/user1.png")),
                                              ),
                                              Text(
                                                UserList[index]['name'],
                                                style: TextStyle(
                                                    // color: Colors.white,
                                                    fontSize: 16,
                                                    fontFamily:
                                                        Constants.popins),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                              color: Constants.primaryColor,
                                              onPressed: () {
                                                ChangerUser(
                                                    context,
                                                    UserList[index]['UserID'],
                                                    UserList[index]['name'],
                                                    UserList[index]['token']);
                                                // prefs = await SharedPreferences.getInstance();
                                                // prefs.setInt('userid', userid);
                                                // prefs.setString('token', token);
                                                // prefs.setString('name', name);
                                              },
                                              icon: Icon(Icons.swap_calls))
                                        ],
                                      ),
                                    ),
                                  )
                                : Container();
                          }),
                    )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> ChangerUser(
      BuildContext context, String useridd, String namee, String tokenn) async {
    final w = MediaQuery.of(context).size.width;
    final GlobalKey<FormState> _key = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            title: Text(
              "Are you sure to Switch ?",
              style: TextStyle(
                // color: Colors.white,
                fontSize: 20,
                fontFamily: Constants.popins,
              ),
            ),
            actions: <Widget>[
              Container(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                  style: ButtonStyle(
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                        fontSize: 16,
                        fontFamily: Constants.popins,
                      )),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white)),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontFamily: Constants.popins,
                    ),
                  ),
                ),
              ),
              Container(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // deleteMachine(id);
                      Navigator.pop(context);
                      prefs.setInt('userid', int.parse(useridd));
                      prefs.setString('token', tokenn);
                      prefs.setString('name', namee);
                      getUserList();
                      Constants.showtoast("User Changed to $namee!");
                    });
                  },
                  style: ButtonStyle(
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                        fontSize: 16,
                        fontFamily: Constants.popins,
                      )),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Constants.primaryColor)),
                  child: Text(
                    "Switch",
                    style: TextStyle(
                      // color: Colors.white,
                      fontSize: 16,
                      fontFamily: Constants.popins,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
