import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';

class GEBList extends StatefulWidget {
  const GEBList({Key? key}) : super(key: key);

  @override
  State<GEBList> createState() => _GEBListState();
}

class _GEBListState extends State<GEBList>
    with AutomaticKeepAliveClientMixin<GEBList> {
  final TextEditingController name = TextEditingController();
  final TextEditingController _kwh = TextEditingController();
  final TextEditingController _dev_kwh = TextEditingController();
  final TextEditingController _kvarh = TextEditingController();
  final TextEditingController _dev_kvarh = TextEditingController();
  final TextEditingController _kvah = TextEditingController();
  final TextEditingController _dev_kvah = TextEditingController();
  final TextEditingController _pf = TextEditingController();
  final TextEditingController _dev_pf = TextEditingController();
  final TextEditingController _md = TextEditingController();
  final TextEditingController _dev_md = TextEditingController();
  final TextEditingController _tb = TextEditingController();
  final TextEditingController _dev_tb = TextEditingController();
  final TextEditingController _mf = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  var data;
  late SharedPreferences prefs;
  String? tokenvalue;
  bool isLoad = false;

  @override
  void initState() {
    super.initState();
    FetchGEBMachineList();
  }

  void FetchGEBMachineList() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    print(tokenvalue);
    final response = await http.get(
      Uri.parse('${Constants.weblink}GetGebListing'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      print(response.statusCode);
      // print(response.body);
      data = jsonDecode(response.body);
      print("hey im here");
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

  void addGEBMachineList(
    String kwh,
    String devKwh,
    String kvarh,
    String devKvarh,
    String kvah,
    String devKvah,
    String pf,
    String devPf,
    String md,
    String devMd,
    String tb,
    String devTb,
    String mf,
  ) async {
    SharedPreferences prefs;
    String? tokenvalue;
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.post(
      Uri.parse('${Constants.weblink}GebAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "machine_name": name.text,
        "kwh": kwh,
        "kwm_deviation": devKwh,
        "kvarh": kvarh,
        "kvarsh_deviation": devKvarh,
        "kevah": kvah,
        "kevah_deviation": devKvah,
        "pf": pf,
        "pf_deviation": devPf,
        "md": md,
        "md_deviation": devMd,
        "turbine": tb,
        "turbine_deviation": devTb,
        "mf": mf,
      }),
    );
    if (response.statusCode == 200) {
      Constants.showtoast("Report Added!");
      FetchGEBMachineList();
    } else {
      print(response.statusCode);
      print(response.body);
      Constants.showtoast("Error adding Report.");
    }
  }

  void updatesteamMachineList(String id) async {
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.post(
      Uri.parse('${Constants.weblink}GebUpdated/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        '_method': "PUT",
        "machine_name": name.text,
        "kwh": _kwh.text,
        "kwm_deviation": _dev_kwh.text,
        "kvarh": _kvarh.text,
        "kvarsh_deviation": _dev_kvarh.text,
        "kevah": _kvah.text,
        "kevah_deviation": _dev_kvah.text,
        "pf": _pf.text,
        "pf_deviation": _dev_pf.text,
        "md": _md.text,
        "md_deviation": _dev_md.text,
        "turbine": _tb.text,
        "turbine_deviation": _dev_tb.text,
        "mf": _mf.text,
      }),
    );
    if (response.statusCode == 200) {
      // String vdata = jsonDecode(response.body);
      Constants.showtoast("Report Updated!");
      FetchGEBMachineList();
    } else {
      print(response.statusCode);
      print(response.body);
      Constants.showtoast("Error adding Report.");
    }
  }

  void deleteMachine(int id) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}DeleteGeb/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{'_method': 'DELETE'}),
    );
    if (response.statusCode == 200) {
      Constants.showtoast("Machine Deleted!");
      FetchGEBMachineList();
    } else {
      Constants.showtoast("Error Fetching Data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    //    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchGEBMachineList());
      },
      child: Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 40,
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        name.clear();
                        _kwh.clear();
                        _dev_kwh.clear();
                        _kvarh.clear();
                        _dev_kvarh.clear();
                        _kvah.clear();
                        _dev_kvah.clear();
                        _pf.clear();
                        _dev_pf.clear();
                        _md.clear();
                        _dev_md.clear();
                        _tb.clear();
                        _dev_tb.clear();
                        _mf.clear();
                        _displayTextInputDialog(context);
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
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
              ],
            ),
            Form(
                key: _key,
                child: (isLoad == true)
                    ? Container(
                        height: 500,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Constants.primaryColor,
                          ),
                        ),
                      )
                    : (data.length == 0)
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
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                // final item = titles[index];
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
                                          offset: const Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              // crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data[index]['machine_name']
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
                                                          name.text = data[index]['machine_name'];
                                                          _kwh.text = data[index]
                                                                  ['kwh']
                                                              .toString();
                                                          _dev_kwh
                                                              .text = data[index]
                                                                  ['kwm_deviation']
                                                              .toString();
                                                          _kvarh.text = data[index]
                                                                  ['kvarh']
                                                              .toString();
                                                          _dev_kvarh
                                                              .text = data[index][
                                                                  'kvarsh_deviation']
                                                              .toString();
                                                          _kvah.text = data[index]
                                                                  ['kevah']
                                                              .toString();
                                                          _dev_kvah
                                                              .text = data[index][
                                                                  'kevah_deviation']
                                                              .toString();
                                                          _pf.text = data[index]
                                                                  ['pf']
                                                              .toString();
                                                          _dev_pf.text = data[index]
                                                                  ['pf_deviation']
                                                              .toString();
                                                          _md.text = data[index]
                                                                  ['md']
                                                              .toString();
                                                          _dev_md.text = data[index]
                                                                  ['md_deviation']
                                                              .toString();
                                                          _tb.text = data[index]
                                                                  ['turbine']
                                                              .toString();
                                                          _dev_tb.text = data[index]
                                                                  [
                                                                  'turbine_deviation']
                                                              .toString();
                                                          _mf.text = data[index]
                                                                  ['mf']
                                                              .toString();

                                                          updatedialog(
                                                              context,
                                                              data[index]['id']
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
                                                              data[index]['id']);

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
                                            //////////////////////////////

                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "KWH",
                                              style: TextStyle(
                                                  fontFamily: Constants.popins,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              data[index]['kwh'].toString(),
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
                                          children: [
                                            Text(
                                              "KWH Deviation",
                                              style: TextStyle(
                                                  fontFamily: Constants.popins,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              data[index]['kwm_deviation']
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
                                          children: [
                                            Text(
                                              "KVARH",
                                              style: TextStyle(
                                                  fontFamily: Constants.popins,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              data[index]['kvarh'].toString(),
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
                                          children: [
                                            Text(
                                              "KVARH Deviation",
                                              style: TextStyle(
                                                  fontFamily: Constants.popins,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              data[index]['kvarsh_deviation']
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
                                          children: [
                                            Text(
                                              "KVAH",
                                              style: TextStyle(
                                                  fontFamily: Constants.popins,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              data[index]['kevah'].toString(),
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
                                          children: [
                                            Text(
                                              "KVAH Deviation",
                                              style: TextStyle(
                                                  fontFamily: Constants.popins,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              data[index]['kevah_deviation']
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
                                          children: [
                                            Text(
                                              "PF",
                                              style: TextStyle(
                                                  fontFamily: Constants.popins,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              data[index]['pf'].toString(),
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
                                          children: [
                                            Text(
                                              "PF Deviation",
                                              style: TextStyle(
                                                  fontFamily: Constants.popins,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              data[index]['pf_deviation']
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
                                          children: [
                                            Text(
                                              "MD",
                                              style: TextStyle(
                                                  fontFamily: Constants.popins,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              data[index]['md'].toString(),
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
                                          children: [
                                            Text(
                                              "MD Deviation",
                                              style: TextStyle(
                                                  fontFamily: Constants.popins,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              data[index]['md_deviation']
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
                                          children: [
                                            Text(
                                              "Turbine",
                                              style: TextStyle(
                                                  fontFamily: Constants.popins,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              data[index]['turbine'].toString(),
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
                                          children: [
                                            Text(
                                              "Turbine Deviation",
                                              style: TextStyle(
                                                  fontFamily: Constants.popins,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              data[index]['turbine_deviation']
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
                                          children: [
                                            Text(
                                              "MF",
                                              style: TextStyle(
                                                  fontFamily: Constants.popins,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              data[index]['mf'].toString(),
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontFamily: Constants.popins,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        // ElevatedButton(
                                        //   onPressed: () {
                                        //     setState(() {
                                        //       if (_key.currentState!.validate()) {
                                        //         _key.currentState!.save();
                                        //         if (data.length == 0) {
                                        //           addGEBMachineList(
                                        //               _kwh.text,
                                        //               _dev_kwh.text,
                                        //               _kvarh.text,
                                        //               _dev_kvarh.text,
                                        //               _kvah.text,
                                        //               _dev_kvah.text,
                                        //               _pf.text,
                                        //               _dev_pf.text,
                                        //               _md.text,
                                        //               _dev_md.text,
                                        //               _tb.text,
                                        //               _dev_tb.text,
                                        //               _mf.text);
                                        //         } else {
                                        //           updatesteamMachineList();
                                        //         }
                                        //       } else {
                                        //         Constants.showtoast("Please fill all the fields");
                                        //       }
                                        //     });
                                        //   },
                                        //   style: ButtonStyle(
                                        //       backgroundColor: MaterialStateProperty.all<Color>(
                                        //           Constants.primaryColor)),
                                        //   child: Text(
                                        //     "           Save           ",
                                        //     style: TextStyle(
                                        //         fontFamily: Constants.popins,
                                        //         // color: Constants.textColor,
                                        //         fontWeight: FontWeight.w600,
                                        //         fontSize: 14),
                                        //   ),
                                        // ),
                                        // Row(
                                        //   mainAxisAlignment:
                                        //   MainAxisAlignment.spaceBetween,
                                        //   children: [
                                        //     Text(
                                        //       "Flow / Unit (Average)",
                                        //       style: TextStyle(
                                        //           fontFamily: Constants.popins,
                                        //           fontSize: 12),
                                        //     ),
                                        //     Text(
                                        //       data[index]['average'].toString(),
                                        //       style: TextStyle(
                                        //           decoration:
                                        //           TextDecoration.underline,
                                        //           fontFamily: Constants.popins,
                                        //           fontSize: 12),
                                        //     ),
                                        //   ],
                                        // ),
                                        // Row(
                                        //   mainAxisAlignment:
                                        //   MainAxisAlignment.spaceBetween,
                                        //   // crossAxisAlignment: CrossAxisAlignment.start,
                                        //   children: [
                                        //     Text(
                                        //       "Deviation",
                                        //       style: TextStyle(
                                        //           fontFamily: Constants.popins,
                                        //           fontSize: 12),
                                        //     ),
                                        //     Text(
                                        //       data[index]['deviation'].toString(),
                                        //       style: TextStyle(
                                        //           decoration:
                                        //           TextDecoration.underline,
                                        //           fontFamily: Constants.popins,
                                        //           fontSize: 12),
                                        //     ),
                                        //   ],
                                        // ),
                                        // Container(color: Colors.blue,width: w,height: 1,),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )),
          ],
        ),
      )),
    );
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
                    height: height / 1.2,
                    // width: 200,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Machine Name",
                                style: TextStyle(
                                    fontFamily: Constants.popins, fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    // keyboardType: TextInputType.number,
                                    controller: name,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "KWH",
                                style: TextStyle(
                                    fontFamily: Constants.popins, fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _kwh,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "KWH Deviation",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _dev_kwh,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "KVARH",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _kvarh,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "KVARH Deviation",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _dev_kvarh,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "KVAH",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _kvah,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "KVAH Deviation",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _dev_kvah,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "PF",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _pf,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "PF Deviation",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _dev_pf,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "MD",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _md,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "MD Deviation",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _dev_md,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Turbine",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _tb,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Turbine Deviation",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _dev_tb,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "MF",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _mf,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                        addGEBMachineList(
                            _kwh.text,
                            _dev_kwh.text,
                            _kvarh.text,
                            _dev_kvarh.text,
                            _kvah.text,
                            _dev_kvah.text,
                            _pf.text,
                            _dev_pf.text,
                            _md.text,
                            _dev_md.text,
                            _tb.text,
                            _dev_tb.text,
                            _mf.text);
                      }
                    });
                  },
                  style: ButtonStyle(
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                        fontSize: 14,
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

  Future<void> updatedialog(BuildContext context, String id) async {
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
                    height: height / 1.2,
                    // width: 200,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Machine Name",
                                style: TextStyle(
                                    fontFamily: Constants.popins, fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    // keyboardType: TextInputType.number,
                                    controller: name,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "KWH",
                                style: TextStyle(
                                    fontFamily: Constants.popins, fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _kwh,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "KWH Deviation",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _dev_kwh,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "KVARH",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _kvarh,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "KVARH Deviation",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _dev_kvarh,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "KVAH",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _kvah,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "KVAH Deviation",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _dev_kvah,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "PF",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _pf,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "PF Deviation",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _dev_pf,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "MD",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _md,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "MD Deviation",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _dev_md,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Turbine",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _tb,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Turbine Deviation",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _dev_tb,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "MF",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    // fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              SizedBox(
                                height: 45,
                                width: w * 0.3,
                                child: Center(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _mf,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return '';
                                      return null;
                                    },
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                        updatesteamMachineList(id);
                        ///todo
                      }
                    });
                  },
                  style: ButtonStyle(
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                        fontSize: 14,
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

  @override
  bool get wantKeepAlive => true;
}
