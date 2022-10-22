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

  void updatesteamMachineList() async {

    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.post(
      Uri.parse('${Constants.weblink}GebUpdated/${data[0]['id']}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        '_method': "PUT",
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
      print(response.body);
      data = jsonDecode(response.body);
      print("hey im here");
      if (data.length == 0) {
        _kwh.text = "";
        _dev_kwh.text = "";
        _kvarh.text = "";
        _dev_kvarh.text = "";
        _kvah.text = "";
        _dev_kvah.text = "";
        _pf.text = "";
        _dev_pf.text = "";
        _md.text = "";
        _dev_md.text = "";
        _tb.text = "";
        _dev_tb.text = "";
        _mf.text = "";
      } else {
        _kwh.text = data[0]['kwh'].toString();
        _dev_kwh.text = data[0]['kwm_deviation'].toString();
        _kvarh.text = data[0]['kvarh'].toString();
        _dev_kvarh.text = data[0]['kvarsh_deviation'].toString();
        _kvah.text = data[0]['kevah'].toString();
        _dev_kvah.text = data[0]['kevah_deviation'].toString();
        _pf.text = data[0]['pf'].toString();
        _dev_pf.text = data[0]['pf_deviation'].toString();
        _md.text = data[0]['md'].toString();
        _dev_md.text = data[0]['md_deviation'].toString();
        _tb.text = data[0]['turbine'].toString();
        _dev_tb.text = data[0]['turbine_deviation'].toString();
        _mf.text = data[0]['mf'].toString();
      }
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
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Form(
            key: _key,
            child: (isLoad == true)
                ? SizedBox(
                    height: 500,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Constants.primaryColor,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "KWH",
                            style: TextStyle(
                                fontFamily: Constants.popins, fontSize: 16),
                          ),
                          SizedBox(
                            height: 45,
                            width: w * 0.4,
                            child: Center(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _kwh,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return '';
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
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 45,
                            width: w * 0.4,
                            child: Center(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _dev_kwh,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return '';
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
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 45,
                            width: w * 0.4,
                            child: Center(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _kvarh,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return '';
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
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 45,
                            width: w * 0.4,
                            child: Center(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _dev_kvarh,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return '';
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
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 45,
                            width: w * 0.4,
                            child: Center(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _kvah,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return '';
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
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 45,
                            width: w * 0.4,
                            child: Center(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _dev_kvah,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return '';
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
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 45,
                            width: w * 0.4,
                            child: Center(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _pf,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return '';
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
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 45,
                            width: w * 0.4,
                            child: Center(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _dev_pf,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return '';
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
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 45,
                            width: w * 0.4,
                            child: Center(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _md,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return '';
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
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 45,
                            width: w * 0.4,
                            child: Center(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _dev_md,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return '';
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
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 45,
                            width: w * 0.4,
                            child: Center(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _tb,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return '';
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
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 45,
                            width: w * 0.4,
                            child: Center(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _dev_tb,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return '';
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
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 45,
                            width: w * 0.4,
                            child: Center(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _mf,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return '';
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
                                    // hintText: "first name",
                                    fillColor: Colors.white70),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (_key.currentState!.validate()) {
                              _key.currentState!.save();
                              if (data.length == 0) {
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
                              } else {
                                updatesteamMachineList();
                              }
                            } else {
                              Constants.showtoast("Please fill all the fields");
                            }
                          });
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Constants.primaryColor)),
                        child: Text(
                          "           Save           ",
                          style: TextStyle(
                              fontFamily: Constants.popins,
                              // color: Constants.textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
