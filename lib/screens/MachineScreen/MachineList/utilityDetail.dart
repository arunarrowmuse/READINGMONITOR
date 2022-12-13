import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../constants.dart';
import '../../auth/adduser.dart';
import '../../auth/login_screen.dart';
import '../../auth/switchuser.dart';

class UtilityDetail extends StatefulWidget {
  String id = "";
  String name = "";

  UtilityDetail({Key? key, required this.id, required this.name})
      : super(key: key);

  @override
  State<UtilityDetail> createState() => _UtilityDetailState();
}

class _UtilityDetailState extends State<UtilityDetail> {
  TextEditingController name = TextEditingController();
  TextEditingController avg = TextEditingController();
  TextEditingController dev = TextEditingController();
  TextEditingController mf = TextEditingController();
  bool isLoad = false;
  var data;
  List filterdata = [];
  late SharedPreferences prefs;
  String? tokenvalue;

  @override
  void initState() {

    super.initState();
    FetchSubMachineList();
  }

  void FetchSubMachineList() async {
    filterdata.clear();
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse('${Constants.weblink}GetUtiltiSubCategoriesList/${DateTime.now().toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      for (int i = 0; i < data.length; i++) {
        if (widget.id.toString() ==
            data[i]['uitility_categories_id'].toString()) {
          filterdata.add(data[i]);
        }
      }
      print("filterdata");
      print(filterdata);
      setState(() {
        isLoad = false;
      });
    } else {
      setState(() {
        isLoad = false;
      });
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void AddSubMachineList() async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}UtiltiSubCategoriesAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "uitility_categories_id": widget.id,
        "uilitysubc_name": name.text,
        "average": avg.text,
        "deviation": dev.text,
        "mf" : mf.text,
      }),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      Constants.showtoast("Machine Added!");
      name.clear();
      avg.clear();
      dev.clear();
      mf.clear();
      FetchSubMachineList();
    } else {
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void UpdateSubMachineList(String id) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}UtiltiSubCategoriesUpdate/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        '_method': "PUT",
        "uilitysubc_name": name.text,
        "average": avg.text,
        "deviation": dev.text,
        "mf" : mf.text,
        // "uitility_categories_id": id,
      }),
    );
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      Constants.showtoast("Machine Updated!");
      name.clear();
      avg.clear();
      dev.clear();
      mf.clear();
      FetchSubMachineList();
    } else {
      Constants.showtoast("Error Updating Data.");
    }
  }

  void deleteMachine(int id) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}UtiltiSubCategoriesDelete/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{'_method': 'DELETE'}),
    );
    if (response.statusCode == 200) {
      Constants.showtoast("Machine Deleted!");
      FetchSubMachineList();
    } else {
      Constants.showtoast("Error Fetching Data.");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setInt('userid', 0);
                      prefs.setString('token', "");
                      prefs.setString("name", "");
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "     " + widget.name.toString(),
                    style: TextStyle(
                      // color: Colors.white,
                      fontSize: 25,
                      fontFamily: Constants.popinsbold,
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 40,
                        // width: 100,
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              name.clear();
                              avg.clear();
                              dev.clear();
                              mf.clear();
                              _displayTextInputDialog(context);
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Constants.primaryColor)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(),
                                const Text("Add        ",
                                    style: TextStyle(color: Colors.white)),
                                const Icon(
                                  Icons.add_circle,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                ],
              ),
              Divider(),
              const SizedBox(
                height: 5,
              ),
              (isLoad == true)
                  ? Container(
                height: 500,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Constants.primaryColor,
                  ),
                ),
              )
                  : (filterdata.length == 0)
                  ? Container(
                height: 300,
                child: Center(
                  child: Text(
                    "no machines found",
                    style: TextStyle(
                        fontFamily: Constants.popins,
                        color: Constants.textColor,
                        // fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                ),
              )
                  : Expanded(
                      child: ListView.builder(
                          itemCount: filterdata.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: const Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          filterdata[index]['uilitysubc_name'],
                                          style: TextStyle(
                                              fontFamily: Constants.popins,
                                              color: Constants.textColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  name.text = filterdata[index]
                                                      ['uilitysubc_name'];
                                                  avg.text = filterdata[index]
                                                          ['average']
                                                      .toString();
                                                  dev.text = filterdata[index]
                                                          ['deviation']
                                                      .toString();
                                                  mf.text = filterdata[index]['mf'].toString();
                                                  updateData(
                                                      context,
                                                      filterdata[index]['id']
                                                          .toString());
                                                },
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.green,
                                                  size: 20,
                                                )),
                                            IconButton(
                                                onPressed: () {
                                                  _deleteMachineDialog(context,
                                                      filterdata[index]['id']);
                                                },
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 20,
                                                )),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Average",
                                          style: TextStyle(
                                              fontFamily: Constants.popins,
                                              fontSize: 12),
                                        ),
                                        Text(
                                          filterdata[index]['average']
                                              .toString(),
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              fontFamily: Constants.popins,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Deviation Allowed",
                                          style: TextStyle(
                                              fontFamily: Constants.popins,
                                              fontSize: 12),
                                        ),
                                        Text(
                                          filterdata[index]['deviation']
                                              .toString(),
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              fontFamily: Constants.popins,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Multiplying Factor",
                                          style: TextStyle(
                                              fontFamily: Constants.popins,
                                              fontSize: 12),
                                        ),
                                        Text(
                                          filterdata[index]['mf']
                                              .toString(),
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              fontFamily: Constants.popins,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    // Container(color: Colors.blue,width: w,height: 1,),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
            ],
          ),
        ));
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    final w = MediaQuery.of(context).size.width;
    final GlobalKey<FormState> _key = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            title: Text(
              "Add New Machine",
              style: TextStyle(
                // color: Colors.white,
                fontSize: 20,
                fontFamily: Constants.popinsbold,
              ),
            ),
            content: Builder(
              builder: (context) {
                // Get available height and width of the build area of this widget. Make a choice depending on the size.
                var height = MediaQuery.of(context).size.height;
                var width = MediaQuery.of(context).size.width;
                return Form(
                  key: _key,
                  child: SizedBox(
                    height: height / 3.5,
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 60,
                          // width: w * 0.45,
                          child: TextFormField(
                            controller: name,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Machine name is required.';
                              return null;
                            },
                            style: TextStyle(
                              fontFamily: Constants.popins,
                              // color: Constants.textColor,
                            ),
                            decoration: InputDecoration(
                                labelText: "Machine Name",
                                hintText: "Enter Machine Name",
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
                                    fontSize: 14),
                                labelStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontFamily: Constants.popins,
                                    fontSize: 14),
                                // hintText: "first name",
                                fillColor: Colors.white70),
                          ),
                        ),
                        // const SizedBox(height: 10),
                        SizedBox(
                          height: 60,
                          // width: w * 0.25,
                          child: TextFormField(
                            controller: avg,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Average is required.';
                              return null;
                            },
                            style: TextStyle(
                              fontFamily: Constants.popins,
                              // color: Constants.textColor,
                            ),
                            decoration: InputDecoration(
                                labelText: "Average",
                                hintText: "Average",
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
                                    fontSize: 14),
                                labelStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontFamily: Constants.popins,
                                    fontSize: 14),
                                // hintText: "first name",
                                fillColor: Colors.white70),
                          ),
                        ),
                        // const SizedBox(height: 10),
                        SizedBox(
                          height: 60,
                          child: TextFormField(
                            controller: dev,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Unit is required.';
                              return null;
                            },
                            style: TextStyle(
                              fontFamily: Constants.popins,
                            ),
                            decoration: InputDecoration(
                                labelText: "Deviation Allowed",
                                hintText: "Deviation Allowed",
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
                                    fontSize: 14),
                                labelStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontFamily: Constants.popins,
                                    fontSize: 14),
                                // hintText: "first name",
                                fillColor: Colors.white70),
                          ),
                        ),
                        SizedBox(
                          height: 60,
                          child: TextFormField(
                            controller: mf,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Unit is required.';
                              return null;
                            },
                            style: TextStyle(
                              fontFamily: Constants.popins,
                            ),
                            decoration: InputDecoration(
                                labelText: "Multiplying Factor",
                                hintText: "Multiplying Factor",
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
                                    fontSize: 14),
                                labelStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontFamily: Constants.popins,
                                    fontSize: 14),
                                // hintText: "first name",
                                fillColor: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            actions: <Widget>[
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_key.currentState!.validate()) {
                        _key.currentState!.save();
                        Navigator.pop(context);
                        AddSubMachineList();
                      }
                    });
                  },
                  style: ButtonStyle(
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                        fontSize: 16,
                        fontFamily: Constants.popins,
                      )),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Constants.primaryColor)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      Text(
                        "Add",
                        style: TextStyle(
                          // color: Colors.white,
                          fontSize: 16,
                          fontFamily: Constants.popins,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future<void> updateData(BuildContext context, String id) async {
    final w = MediaQuery.of(context).size.width;
    final GlobalKey<FormState> _key = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            title: Text(
              "Update Machine",
              style: TextStyle(
                // color: Colors.white,
                fontSize: 20,
                fontFamily: Constants.popinsbold,
              ),
            ),
            content: Builder(
              builder: (context) {
                // Get available height and width of the build area of this widget. Make a choice depending on the size.
                var height = MediaQuery.of(context).size.height;
                var width = MediaQuery.of(context).size.width;
                return Form(
                  key: _key,
                  child: SizedBox(
                    height: height / 3.5,
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 60,
                          // width: w * 0.45,
                          child: TextFormField(
                            controller: name,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Machine name is required.';
                              return null;
                            },
                            style: TextStyle(
                              fontFamily: Constants.popins,
                              // color: Constants.textColor,
                            ),
                            decoration: InputDecoration(
                                labelText: "Machine Name",
                                hintText: "Enter Machine Name",
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
                                    fontSize: 14),
                                labelStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontFamily: Constants.popins,
                                    fontSize: 14),
                                // hintText: "first name",
                                fillColor: Colors.white70),
                          ),
                        ),
                        // const SizedBox(height: 10),
                        SizedBox(
                          height: 60,
                          // width: w * 0.25,
                          child: TextFormField(
                            controller: avg,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Average is required.';
                              return null;
                            },
                            style: TextStyle(
                              fontFamily: Constants.popins,
                              // color: Constants.textColor,
                            ),
                            decoration: InputDecoration(
                                labelText: "Average",
                                hintText: "Average",
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
                                    fontSize: 14),
                                labelStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontFamily: Constants.popins,
                                    fontSize: 14),
                                // hintText: "first name",
                                fillColor: Colors.white70),
                          ),
                        ),
                        // const SizedBox(height: 10),
                        SizedBox(
                          height: 60,
                          child: TextFormField(
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            controller: dev,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Unit is required.';
                              return null;
                            },
                            style: TextStyle(
                              fontFamily: Constants.popins,
                            ),
                            decoration: InputDecoration(
                                labelText: "Deviation Allowed",
                                hintText: "Deviation Allowed",
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
                                    fontSize: 14),
                                labelStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontFamily: Constants.popins,
                                    fontSize: 14),
                                // hintText: "first name",
                                fillColor: Colors.white70),
                          ),
                        ),
                        SizedBox(
                          height: 60,
                          child: TextFormField(
                            controller: mf,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Unit is required.';
                              return null;
                            },
                            style: TextStyle(
                              fontFamily: Constants.popins,
                            ),
                            decoration: InputDecoration(
                                labelText: "Multiplying Factor",
                                hintText: "Multiplying Factor",
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
                                    fontSize: 14),
                                labelStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontFamily: Constants.popins,
                                    fontSize: 14),
                                // hintText: "first name",
                                fillColor: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            actions: <Widget>[
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_key.currentState!.validate()) {
                        _key.currentState!.save();
                        Navigator.pop(context);
                        UpdateSubMachineList(id);
                      }
                    });
                  },
                  style: ButtonStyle(
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                        fontSize: 16,
                        fontFamily: Constants.popins,
                      )),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Constants.primaryColor)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 14,
                      ),
                      Text(
                        "Update",
                        style: TextStyle(
                          // color: Colors.white,
                          fontSize: 14,
                          fontFamily: Constants.popins,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future<void> _deleteMachineDialog(BuildContext context, int id) async {
    final w = MediaQuery.of(context).size.width;
    final GlobalKey<FormState> _key = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            title: Text(
              "Are you sure to Delete ?",
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
                      deleteMachine(id);
                      Navigator.pop(context);
                    });
                  },
                  style: ButtonStyle(
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                        fontSize: 16,
                        fontFamily: Constants.popins,
                      )),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red)),
                  child: Text(
                    "Delete",
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
