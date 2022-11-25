import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';

class SteamBoilerList extends StatefulWidget {
  const SteamBoilerList({Key? key}) : super(key: key);

  @override
  State<SteamBoilerList> createState() => _SteamBoilerListState();
}

class _SteamBoilerListState extends State<SteamBoilerList> with AutomaticKeepAliveClientMixin<SteamBoilerList>{
  TextEditingController bfw = TextEditingController();
  TextEditingController temp = TextEditingController();
  TextEditingController bfwpr = TextEditingController();
  TextEditingController bfwtemppr = TextEditingController();
  TextEditingController ro_water = TextEditingController();
  TextEditingController ro_water_per = TextEditingController();
  TextEditingController coal1 = TextEditingController();
  TextEditingController coal1dv = TextEditingController();
  TextEditingController ratecoal1 = TextEditingController();
  TextEditingController coal2 = TextEditingController();
  TextEditingController coal2dv = TextEditingController();
  TextEditingController ratecoal2 = TextEditingController();
  TextEditingController steamcost = TextEditingController();
  TextEditingController steamcostpr = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  var data;
  late SharedPreferences prefs;
  String? tokenvalue;
  bool isLoad = false;

  @override
  void initState() {

    super.initState();
    FetchSteamMachineList();
  }

  void addsteamMachineList() async {
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.post(
      Uri.parse('${Constants.weblink}SteamBolierAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "bfw": bfw.text,
        "temperature": temp.text,
        "bfw_percentage": bfwpr.text,
        "bfw_temperature_percentage": bfwtemppr.text,
        "ro_water": ro_water.text,
        "ro_water_per":ro_water_per.text,
        "coal_1": coal1.text,
        "coal_deviation_1": coal1dv.text,
        "rate_of_coal_1": ratecoal1.text,
        "coal_2": coal2.text,
        "coal_deviation_2": coal2dv.text,
        "rate_of_coal_2": ratecoal2.text,
        "steam_cost": steamcost.text,
        "steam_cost_percentage": steamcostpr.text,
      }),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      Constants.showtoast("Report Added!");
      FetchSteamMachineList();
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
      Uri.parse('${Constants.weblink}SteamBolierUpadated/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        '_method': "PUT",
        "bfw": bfw.text,
        "temperature": temp.text,
        "bfw_percentage": bfwpr.text,
        "bfw_temperature_percentage": bfwtemppr.text,
        "ro_water": ro_water.text,
        "ro_water_per":ro_water_per.text,
        "coal_1": coal1.text,
        "coal_deviation_1": coal1dv.text,
        "rate_of_coal_1": ratecoal1.text,
        "coal_2": coal2.text,
        "coal_deviation_2": coal2dv.text,
        "rate_of_coal_2": ratecoal2.text,
        "steam_cost": steamcost.text,
        "steam_cost_percentage": steamcostpr.text,
      }),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      Constants.showtoast("Report Updated!");
      FetchSteamMachineList();
    } else {
      print(response.statusCode);
      print(response.body);
      Constants.showtoast("Error Updating Report.");
    }
  }

  void FetchSteamMachineList() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    print(tokenvalue);
    final response = await http.get(
      Uri.parse('${Constants.weblink}SteamBolierListing'),
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
        bfw.text = "";
        temp.text = "";
        bfwpr.text = "";
        bfwtemppr.text = "";
        ro_water.text = "";
        ro_water_per.text = "";
        coal1.text = "";
        coal1dv.text = "";
        ratecoal1.text = "";
        coal2.text = "";
        coal2dv.text = "";
        ratecoal2.text = "";
        steamcost.text = "";
        steamcostpr.text = "";
      } else {
        bfw.text = data[0]['bfw'].toString();
        temp.text = data[0]['temperature'].toString();
        bfwpr.text = data[0]['bfw_percentage'].toString();
        bfwtemppr.text = data[0]['bfw_temperature_percentage'].toString();
        ro_water.text = data[0]['ro_water'].toString();
        ro_water_per.text = data[0]['ro_water_per'].toString();
        coal1.text = data[0]['coal_1'].toString();
        coal1dv.text = data[0]['coal_deviation_1'].toString();
        ratecoal1.text = data[0]['rate_of_coal_1'].toString();
        coal2.text = data[0]['coal_2'].toString();
        coal2dv.text = data[0]['coal_deviation_2'].toString();
        ratecoal2.text = data[0]['rate_of_coal_2'].toString();
        steamcost.text = data[0]['steam_cost'].toString();
        steamcostpr.text = data[0]['steam_cost_percentage'].toString();
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

  @override
  Widget build(BuildContext context) {
    // final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      onRefresh: (){
        return Future(() => FetchSteamMachineList());
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
                        children: [
                          Text(
                            "BFW",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                // fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 50,
                            width: w * 0.4,
                          child: TextFormField(
                                    keyboardType: TextInputType.number,
                              controller: bfw,
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
                                  // hintText: "first name",
                                  fillColor: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "BFW %",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                // fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 50,
                            width: w * 0.4,
                          child: TextFormField(
                                    keyboardType: TextInputType.number,
                              controller: bfwpr,
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
                                  // hintText: "first name",
                                  fillColor: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Temperature",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                // fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 50,
                            width: w * 0.4,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: temp,
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
                                  // hintText: "first name",
                                  fillColor: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "BFW Temperature %",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                // fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 50,
                            width: w * 0.4,
                          child: TextFormField(
                                    keyboardType: TextInputType.number,
                              controller: bfwtemppr,
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
                                  // hintText: "first name",
                                  fillColor: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "RO Water",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                // fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 50,
                            width: w * 0.4,
                          child: TextFormField(
                                    keyboardType: TextInputType.number,
                              controller: ro_water,
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
                                  // hintText: "first name",
                                  fillColor: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "RO Water %",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                // fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 50,
                            width: w * 0.4,
                          child: TextFormField(
                                    keyboardType: TextInputType.number,
                              controller: ro_water_per,
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
                                  // hintText: "first name",
                                  fillColor: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Coal 1",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                // fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 50,
                            width: w * 0.4,
                          child: TextFormField(
                                    keyboardType: TextInputType.number,
                              controller: coal1,
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
                                  // hintText: "first name",
                                  fillColor: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Coal 1 Deviation",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                // fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 50,
                            width: w * 0.4,
                          child: TextFormField(
                                    keyboardType: TextInputType.number,
                              controller: coal1dv,
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
                                  // hintText: "first name",
                                  fillColor: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Rate of Coal 1",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                // fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 50,
                            width: w * 0.4,
                          child: TextFormField(
                                    keyboardType: TextInputType.number,
                              controller: ratecoal1,
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
                                  // hintText: "first name",
                                  fillColor: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Coal 2",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                // fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 50,
                            width: w * 0.4,
                          child: TextFormField(
                                    keyboardType: TextInputType.number,
                              controller: coal2,
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
                                  // hintText: "first name",
                                  fillColor: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Coal 2 Deviation",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                // fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 50,
                            width: w * 0.4,
                          child: TextFormField(
                                    keyboardType: TextInputType.number,
                              controller: coal2dv,
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
                                  // hintText: "first name",
                                  fillColor: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Rate of Coal 2",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                // fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 50,
                            width: w * 0.4,
                          child: TextFormField(
                                    keyboardType: TextInputType.number,
                              controller: ratecoal2,
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
                                  // hintText: "first name",
                                  fillColor: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Steam Cost",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                // fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 50,
                            width: w * 0.4,
                          child: TextFormField(
                                    keyboardType: TextInputType.number,
                              controller: steamcost,
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
                                  // hintText: "first name",
                                  fillColor: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Steam Cost %",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                // fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 50,
                            width: w * 0.4,
                          child: TextFormField(
                                    keyboardType: TextInputType.number,
                              controller: steamcostpr,
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
                                  // hintText: "first name",
                                  fillColor: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (_key.currentState!.validate()) {
                              _key.currentState!.save();
                              if (data.length == 0) {
                                addsteamMachineList();
                              } else {
                                print("updates");
                                updatesteamMachineList(data[0]['id'].toString());
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
