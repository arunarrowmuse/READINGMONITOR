import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Constants {
  static Color primaryColor = const Color(0xFF52C0A5);
  static Color secondaryColor = const Color(0xFF716259);
  static Color textColor = const Color(0xFF083A50);
  static String popins = "Popins";
  static String popinsbold = "PopinsBold";

  // static String weblink =
  //     "https://50ce-2405-201-2009-f070-eccc-33bb-13c1-67b2.in.ngrok.io/api/";
  static String weblink = "https://test.readingmonitor.co/api/";
  static const double padding = 20;
  static const double avatarRadius = 45;

  static showtoast(msg) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: Colors.grey,
      // backgroundColor: Colors.white,
      // textColor: Colors.grey.shade900,
    );
  }
}

class Routes {
  static const String LOGIN = "login";
  static const String LOGOUT = "logout";
}

class Utils {
  late BuildContext context;

  Utils(this.context);

  // this is where you would do your fullscreen loading
  Future<void> startLoading() async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const SimpleDialog(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          // can change this to your prefered color
          children: <Widget>[
            Center(
              child: CircularProgressIndicator(),
            )
          ],
        );
      },
    );
  }

  Future<void> stopLoading() async {
    Navigator.of(context).pop();
  }

  Future<void> showError() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        backgroundColor: Colors.red,
        content: Text("Error"),
      ),
    );
  }

  Future<void> Youareoffline(BuildContext context) async {
    final w = MediaQuery.of(context).size.width;
    final GlobalKey<FormState> _key = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            title: Text(
              "You are Offline!",
              style: TextStyle(
                // color: Colors.white,
                fontSize: 20,
                fontFamily: Constants.popins,
              ),
            ),
            content: Text(
              "Please Submit the machines separately.",
              style: TextStyle(
                // color: Colors.white,
                fontSize: 16,
                fontFamily: Constants.popins,
              ),
            ),
            actions: <Widget>[
              Container(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    // setState(() {
                      Navigator.pop(context);
                    // });
                  },
                  style: ButtonStyle(
                    textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                      fontSize: 16,
                      fontFamily: Constants.popins,
                    )),
                    // backgroundColor:
                    // MaterialStateProperty.all<Color>(Colors.red)
                  ),
                  child: Text(
                    "OK",
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

  late SharedPreferences prefs;
  String? tokenvalue = "";
  bool alldone = false;

  backuptoserver(String tokenn, String dataa) async {
    // tokenvalue = prefs.getString("token");
    // String? data = prefs.getString("backuplinklist");
    tokenvalue = tokenn;
    String? data = dataa;
    List DecodeUser = jsonDecode(data);

    /// call the standard function here!
    for (int i = 0; i < DecodeUser.length; i++) {
      print("2");
      print(DecodeUser[i]['backuplink']);
      print("link providedis ");
      final response = await http.post(
        // Uri.parse(DecodeUser[i]['backuplink']),
        Uri.parse(DecodeUser[i]['backuplink']),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $tokenvalue',
        },
        body: jsonEncode(DecodeUser[i]['backupbody']),
      );
      print("3 backup $i");
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("data converted");
        print("data converted");
        print(response.body);
        if (i == DecodeUser.length - 1) {
          alldone = true;
        }

        /// all perfect till here
        /// now remove data from the shared preferences
        /// when the data response is 200
        // DecodeUser.remove(DecodeUser[i]);
      } else {
        print(response.body);
      }
    }
    DecodeUser.clear();
    if (alldone == true) {
      Constants.showtoast("All data have been synced to the server."
          "\nKindly Refresh your Page!");
    }
  }
}
