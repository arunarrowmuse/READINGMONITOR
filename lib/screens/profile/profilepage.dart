import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoad = false;
  var data;
  late SharedPreferences prefs;
  String? tokenvalue;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  void fetchProfile() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse('${Constants.weblink}GetProfileshow'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print("data------------------------------");
      // print(response.body);
      data = jsonDecode(response.body);
      print(data);
      setState(() {
        isLoad = false;
      });
    } else {
      print(response.statusCode);
      print(response.body);
      setState(() {
        isLoad = false;
      });
      Constants.showtoast("Error Fetching Data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18),
              child: Text(
                "PROFILE",
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: Constants.popinsbold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
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
                              children: const [
                                Text("User Name"),
                                Text("abc@gmail.com")
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.grey.shade300,
                            child: Center(
                              child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.share,
                                    color: Colors.grey,
                                    size: 12,
                                  )),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Divider(),
                    // const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "Personal",
                          style: TextStyle(
                              fontFamily: Constants.popins,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "First Name",
                              style: TextStyle(
                                  fontFamily: Constants.popins,
                                  color: Constants.textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ),
                            SizedBox(
                              height: 35,
                              width: w * 0.4,
                              child: TextField(
                                style: TextStyle(
                                  fontFamily: Constants.popins,
                                  color: Constants.textColor,
                                ),
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(
                                        bottom: 10.0, left: 10.0),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Constants.primaryColor,
                                          width: 2.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontFamily: Constants.popins,
                                    ),
                                    hintText: "first name",
                                    fillColor: Colors.white70),
                              ),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Surname",
                              style: TextStyle(
                                  fontFamily: Constants.popins,
                                  color: Constants.textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ),
                            SizedBox(
                              height: 35,
                              width: w * 0.4,
                              child: TextField(
                                style: TextStyle(
                                  fontFamily: Constants.popins,
                                  color: Constants.textColor,
                                ),
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(
                                        bottom: 10.0, left: 10.0),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Constants.primaryColor,
                                          width: 2.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontFamily: Constants.popins,
                                    ),
                                    hintText: "surname",
                                    fillColor: Colors.white70),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email",
                          style: TextStyle(
                              fontFamily: Constants.popins,
                              color: Constants.textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                        SizedBox(
                          height: 35,
                          width: w * 0.95,
                          child: TextField(
                            style: TextStyle(
                              fontFamily: Constants.popins,
                              color: Constants.textColor,
                            ),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    bottom: 10.0, left: 10.0),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Constants.primaryColor,
                                      width: 2.0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontFamily: Constants.popins,
                                ),
                                hintText: "enter email",
                                fillColor: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Phone Number",
                          style: TextStyle(
                              fontFamily: Constants.popins,
                              color: Constants.textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 35,
                              width: w * 0.12,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                              child: Center(
                                child: Text(
                                  "+91",
                                  style: TextStyle(
                                      fontFamily: Constants.popins,
                                      color: Colors.grey[700],
                                      fontSize: 16),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 35,
                              width: w * 0.70,
                              child: TextField(
                                style: TextStyle(
                                  fontFamily: Constants.popins,
                                  color: Constants.textColor,
                                ),
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(
                                        bottom: 10.0, left: 10.0),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Constants.primaryColor,
                                          width: 2.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontFamily: Constants.popins,
                                    ),
                                    hintText: "9000090000",
                                    fillColor: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Company Name:",
                          style: TextStyle(
                              fontFamily: Constants.popins,
                              color: Constants.textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                        SizedBox(
                          height: 35,
                          width: w * 0.95,
                          child: TextField(
                            style: TextStyle(
                              fontFamily: Constants.popins,
                              color: Constants.textColor,
                            ),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    bottom: 10.0, left: 10.0),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Constants.primaryColor,
                                      width: 2.0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontFamily: Constants.popins,
                                ),
                                hintText: "company name",
                                fillColor: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Address:",
                          style: TextStyle(
                              fontFamily: Constants.popins,
                              color: Constants.textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                        SizedBox(
                          height: 100,
                          width: w * 0.95,
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            style: TextStyle(
                              fontFamily: Constants.popins,
                              color: Constants.textColor,
                            ),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    bottom: 10.0, left: 10.0),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Constants.primaryColor,
                                      width: 2.0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontFamily: Constants.popins,
                                ),
                                hintText: "enter address",
                                fillColor: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Constants.primaryColor)),
                          child: const Text("       Save       "),
                        ),
                        // const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),
                        Text(
                          "CHANGE PASSWORD",
                          style: TextStyle(
                              fontFamily: Constants.popins,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
