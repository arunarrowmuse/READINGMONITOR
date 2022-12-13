import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../constants.dart';
import '../../auth/adduser.dart';
import '../../auth/login_screen.dart';
import '../../auth/switchuser.dart';

class MachineDetail extends StatefulWidget {
  String id = "";
  String name = "";

  MachineDetail({Key? key, required this.id, required this.name})
      : super(key: key);

  @override
  State<MachineDetail> createState() => _MachineDetailState();
}

class _MachineDetailState extends State<MachineDetail> {
  TextEditingController name = TextEditingController();
  TextEditingController mfem = TextEditingController();
  TextEditingController mfwater = TextEditingController();
  TextEditingController emhm = TextEditingController();
  TextEditingController emhmdev = TextEditingController();
  TextEditingController waterbatch = TextEditingController();
  TextEditingController temperaturedev = TextEditingController();
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
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    filterdata.clear();
    setState(() {
      isLoad = true;
    });
    final response = await http.get(
      Uri.parse('${Constants.weblink}GetMachineSubCategoriesListing/${DateTime.now().toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      print(response.statusCode);
      print(response.body);
      data = jsonDecode(response.body);
      print("hey im here");
      for (int i = 0; i < data.length; i++) {
        if (widget.id.toString() == data[i]['categories_id'].toString()) {
          filterdata.add(data[i]);
        }
      }
      print(filterdata);
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

  void AddSubMachineList() async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}MachineSubCategoriesAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        // '_method': "PUT",
        "categories_id": widget.id,
        "sub_name": name.text,
        "em_hm": emhm.text,
        "em_hm_percentage": emhmdev.text,
        "water_batch": waterbatch.text,
        "temp_percentage": temperaturedev.text,
        "mfem" : mfem.text,
        "mf_water" : mfwater.text,
      }),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      Constants.showtoast("Machine Added!");
      name.clear();
      emhm.clear();
      emhmdev.clear();
      waterbatch.clear();
      temperaturedev.clear();
      mfem.clear();
      mfwater.clear();
      FetchSubMachineList();
    } else {
      print(response.statusCode);
      print(response.body);
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void UpdateSubMachineList(String id) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}MachineSubCategoriUpdated/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        '_method': "PUT",
        "sub_name": name.text,
        "em_hm": emhm.text,
        "em_hm_percentage": emhmdev.text,
        "water_batch": waterbatch.text,
        "temp_percentage": temperaturedev.text,
        "mfem" : mfem.text,
        "mf_water" : mfwater.text
      }),
    );
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      Constants.showtoast("Machine Updated!");
      name.clear();
      emhm.clear();
      emhmdev.clear();
      waterbatch.clear();
      temperaturedev.clear();
      mfem.clear();
      mfwater.clear();
      FetchSubMachineList();
    } else {
      print(response.statusCode);
      print(response.body);
      Constants.showtoast("Error Updating Data.");
    }
  }

  void deleteMachine(int id) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}MachineSubCategoriesDelated/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{'_method': 'DELETE'}),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      Constants.showtoast("Machine Deleted!");
      FetchSubMachineList();
    } else {
      Constants.showtoast("Error Fetching Data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
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
                              emhm.clear();
                              emhmdev.clear();
                              waterbatch.clear();
                              temperaturedev.clear();
                              mfem.clear();
                              mfwater.clear();
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
                                          filterdata[index]['sub_name']
                                              .toString(),
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
                                                      ['sub_name'];
                                                  emhm.text = filterdata[index]
                                                          ['em_hm']
                                                      .toString();
                                                  emhmdev
                                                      .text = filterdata[index]
                                                          ['em_hm_percentage']
                                                      .toString();
                                                  waterbatch.text =
                                                      filterdata[index]
                                                              ['water_batch']
                                                          .toString();
                                                  temperaturedev
                                                      .text = filterdata[index]
                                                          ['temp_percentage']
                                                      .toString();
                                                  mfem.text = filterdata[index]['mfem'].toString();
                                                  mfwater.text = filterdata[index]['mf_water'].toString();
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
                                        SizedBox(
                                            width: w / 3,
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "EM/HM",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              Constants.popins,
                                                          // color: Constants.textColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      filterdata[index]['em_hm']
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontFamily:
                                                              Constants.popins,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          // color: Constants.textColor,
                                                          // fontWeight: FontWeight.w600,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "EM/HM %",
                                                      style: TextStyle(
                                                          fontFamily:
                                                          Constants.popins,
                                                          // color: Constants.textColor,
                                                          fontWeight:
                                                          FontWeight.w600,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      filterdata[index][
                                                      'em_hm_percentage']
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontFamily:
                                                          Constants.popins,
                                                          decoration:
                                                          TextDecoration
                                                              .underline,
                                                          // color: Constants.textColor,
                                                          // fontWeight: FontWeight.w600,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "EM MF",
                                                      style: TextStyle(
                                                          fontFamily:
                                                          Constants.popins,
                                                          // color: Constants.textColor,
                                                          fontWeight:
                                                          FontWeight.w600,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      filterdata[index][
                                                      'mfem']
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontFamily:
                                                          Constants.popins,
                                                          decoration:
                                                          TextDecoration
                                                              .underline,
                                                          // color: Constants.textColor,
                                                          // fontWeight: FontWeight.w600,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),

                                              ],
                                            )),
                                        Container(
                                          color: Constants.secondaryColor
                                              .withOpacity(0.2),
                                          width: 1,
                                          height: h / 15,
                                        ),
                                        SizedBox(
                                            width: w / 3,
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Water/Batch",
                                                      style: TextStyle(
                                                          fontFamily:
                                                          Constants.popins,
                                                          // color: Constants.textColor,
                                                          fontWeight:
                                                          FontWeight.w600,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      filterdata[index]
                                                      ['water_batch']
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontFamily:
                                                          Constants.popins,
                                                          decoration:
                                                          TextDecoration
                                                              .underline,
                                                          // color: Constants.textColor,
                                                          // fontWeight: FontWeight.w600,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Water/Batch %",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              Constants.popins,
                                                          // color: Constants.textColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      filterdata[index][
                                                              'temp_percentage']
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontFamily:
                                                              Constants.popins,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          // color: Constants.textColor,
                                                          // fontWeight: FontWeight.w600,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Water MF",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              Constants.popins,
                                                          // color: Constants.textColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      filterdata[index][
                                                              'mf_water']
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontFamily:
                                                              Constants.popins,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          // color: Constants.textColor,
                                                          // fontWeight: FontWeight.w600,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),

                                              ],
                                            )),
                                      ],
                                    )
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
                    height: height / 3,
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
                        // SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 60,
                              width: w * 0.25,
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Value is required.';
                                  return null;
                                },
                                controller: emhm,
                                style: TextStyle(
                                  fontFamily: Constants.popins,
                                  // color: Constants.textColor,
                                ),
                                decoration: InputDecoration(
                                    labelText: "Em/HM",
                                    hintText: "Em/HM",
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
                              width: w * 0.25,
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Value % is required.';
                                  return null;
                                },
                                controller: emhmdev,
                                style: TextStyle(
                                  fontFamily: Constants.popins,
                                  // color: Constants.textColor,
                                ),
                                decoration: InputDecoration(
                                    labelText: "Em/HM % ",
                                    hintText: "Em/HM % ",
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
                        // SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 60,
                              width: w * 0.25,
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Value is required.';
                                  return null;
                                },
                                controller: waterbatch,
                                style: TextStyle(
                                  fontFamily: Constants.popins,
                                  // color: Constants.textColor,
                                ),
                                decoration: InputDecoration(
                                    labelText: "Water/Batch",
                                    hintText: "Water/Batch",
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
                              width: w * 0.25,
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Value % is required.';
                                  return null;
                                },
                                controller: temperaturedev,
                                style: TextStyle(
                                  fontFamily: Constants.popins,
                                  // color: Constants.textColor,
                                ),
                                decoration: InputDecoration(
                                    labelText: "Water/Batch % ",
                                    hintText: "Water/Batch % ",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 60,
                              width: w * 0.25,
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Value is required.';
                                  return null;
                                },
                                controller: mfem,
                                style: TextStyle(
                                  fontFamily: Constants.popins,
                                  // color: Constants.textColor,
                                ),
                                decoration: InputDecoration(
                                    labelText: "EM MF",
                                    hintText: "EM MF",
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
                              width: w * 0.25,
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Value % is required.';
                                  return null;
                                },
                                controller: mfwater,
                                style: TextStyle(
                                  fontFamily: Constants.popins,
                                  // color: Constants.textColor,
                                ),
                                decoration: InputDecoration(
                                    labelText: "Water MF",
                                    hintText: "Water MF",
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
                    height: height / 3,
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
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 60,
                              width: w * 0.25,
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Value is required.';
                                  return null;
                                },
                                controller: emhm,
                                style: TextStyle(
                                  fontFamily: Constants.popins,
                                  // color: Constants.textColor,
                                ),
                                decoration: InputDecoration(
                                    labelText: "Em/HM",
                                    hintText: "Em/HM",
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
                              width: w * 0.25,
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Value % is required.';
                                  return null;
                                },
                                controller: emhmdev,
                                style: TextStyle(
                                  fontFamily: Constants.popins,
                                  // color: Constants.textColor,
                                ),
                                decoration: InputDecoration(
                                    labelText: "Em/HM % ",
                                    hintText: "Em/HM % ",
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
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 60,
                              width: w * 0.25,
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Value is required.';
                                  return null;
                                },
                                controller: waterbatch,
                                style: TextStyle(
                                  fontFamily: Constants.popins,
                                  // color: Constants.textColor,
                                ),
                                decoration: InputDecoration(
                                    labelText: "Water/Batch",
                                    hintText: "Water/Batch",
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
                              width: w * 0.25,
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Value % is required.';
                                  return null;
                                },
                                controller: temperaturedev,
                                style: TextStyle(
                                  fontFamily: Constants.popins,
                                  // color: Constants.textColor,
                                ),
                                decoration: InputDecoration(
                                    labelText: "Water/Batch % ",
                                    hintText: "Water/Batch % ",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 60,
                              width: w * 0.25,
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Value is required.';
                                  return null;
                                },
                                controller: mfem,
                                style: TextStyle(
                                  fontFamily: Constants.popins,
                                  // color: Constants.textColor,
                                ),
                                decoration: InputDecoration(
                                    labelText: "EM MF",
                                    hintText: "EM MF",
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
                              width: w * 0.25,
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Value % is required.';
                                  return null;
                                },
                                controller: mfwater,
                                style: TextStyle(
                                  fontFamily: Constants.popins,
                                  // color: Constants.textColor,
                                ),
                                decoration: InputDecoration(
                                    labelText: "Water MF",
                                    hintText: "Water MF",
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
                        Icons.update,
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
