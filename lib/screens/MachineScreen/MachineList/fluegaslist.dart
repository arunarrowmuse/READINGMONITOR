import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';

class FlueGasList extends StatefulWidget {
  const FlueGasList({Key? key}) : super(key: key);

  @override
  State<FlueGasList> createState() => _FlueGasListState();
}

class _FlueGasListState extends State<FlueGasList> {
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          DefaultTabController(
              length: 2, // length of tabs
              initialIndex: 0,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      color: Constants.primaryColor,
                      child: TabBar(
                        indicatorColor: Colors.red,
                        // labelColor: Colors.green,
                        // unselectedLabelColor: Colors.black,
                        tabs: [
                          Tab(
                            child: Text(
                              "Steam Boiler",
                              style: TextStyle(
                                  fontFamily: Constants.popins,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                          ),
                          Tab(
                            child: Text(
                              "Thermopack",
                              style: TextStyle(
                                  fontFamily: Constants.popins,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        height: h / 1.4, //height of TabBarView
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.grey, width: 0.5))),
                        child: TabBarView(children: <Widget>[
                          FlueSteamBoiler(),
                          FlueThermoPack(),
                        ]))
                  ])),
        ],
      ),
    ));
  }
}

class FlueSteamBoiler extends StatefulWidget {
  const FlueSteamBoiler({Key? key}) : super(key: key);

  @override
  State<FlueSteamBoiler> createState() => _FlueSteamBoilerState();
}

class _FlueSteamBoilerState extends State<FlueSteamBoiler>
    with AutomaticKeepAliveClientMixin<FlueSteamBoiler> {
  TextEditingController nameController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController tempController = TextEditingController();
  TextEditingController valueprcntController = TextEditingController();
  TextEditingController tempprcntController = TextEditingController();
  var data;
  bool isLoad = false;
  late SharedPreferences prefs;
  String? tokenvalue;

  @override
  void initState() {

    super.initState();
    fetchSteamMachineList();
  }

  void fetchSteamMachineList() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse('${Constants.weblink}GetFlueGasSteamBolierListingData/${DateTime.now().toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      print(data);
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

  void AddSteamMachineList(
    String machine,
    String value,
    String value_deviation,
    String temperature,
    String temperature_deviation,
  ) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}GetFlueGasSteamBolierListingDataAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "machine_name": machine,
        "value": value.toString(),
        "deviation": value_deviation.toString(),
        "temperature": temperature.toString(),
        "temperature_deviation": temperature_deviation.toString(),
      }),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      nameController.clear();
      valueController.clear();
      tempController.clear();
      valueprcntController.clear();
      tempprcntController.clear();
      Constants.showtoast("Machine Added!");
      fetchSteamMachineList();
      // setState(() {
      //   isLoad = false;
      // });
    } else {
      // setState(() {
      //   isLoad = false;
      // });
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void UpdateSteamMachineList(
      String machine,
      String value,
      String value_deviation,
      String temperature,
      String temperature_deviation,
      String id) async {
    final response = await http.post(
      Uri.parse(
          '${Constants.weblink}GetFlueGasSteamBolierListingDataUpdated/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        '_method': "PUT",
        "machine_name": machine,
        "value": value.toString(),
        "deviation": value_deviation.toString(),
        "temperature": temperature.toString(),
        "temperature_deviation": temperature_deviation.toString(),
      }),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      nameController.clear();
      valueController.clear();
      tempController.clear();
      valueprcntController.clear();
      tempprcntController.clear();
      Constants.showtoast("Machine Updated!");
      fetchSteamMachineList();
      // setState(() {
      //   isLoad = false;
      // });
    } else {
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void deleteMachine(int id) async {
    final response = await http.post(
      Uri.parse(
          '${Constants.weblink}GetFlueGasSteamBolierListingDataDelete/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{'_method': 'DELETE'}),
    );
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);

      Constants.showtoast("Machine Deleted!");
      fetchSteamMachineList();
      // setState(() {
      //   isLoad = false;
      // });
    } else {
      // setState(() {
      //   isLoad = false;
      // });
      Constants.showtoast("Error Fetching Data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => fetchSteamMachineList());
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18),
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
                    // width: 100,
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: ElevatedButton(
                        onPressed: () {
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
              (isLoad == true)
                  ? SizedBox(
                      height: 500,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Constants.primaryColor,
                        ),
                      ),
                    )
                  : (data.length == 0)
                      ? SizedBox(
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
                                        offset: const Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 15),
                                  child: Column(
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
                                                    setState(() {
                                                      nameController.text =
                                                          data[index]
                                                              ['machine_name'];
                                                      valueController.text =
                                                          data[index]['value']
                                                              .toString();
                                                      valueprcntController
                                                          .text = data[index]
                                                              ['deviation']
                                                          .toString();
                                                      tempController
                                                          .text = data[index]
                                                              ['temperature']
                                                          .toString();
                                                      tempprcntController
                                                          .text = data[index][
                                                              'temperature_deviation']
                                                          .toString();
                                                    });
                                                    _updateTextInputDialog(
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
                                                    _deleteMachineDialog(
                                                        context,
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
                                                        "Value",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
                                                            // color: Constants.textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        data[index]['value']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
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
                                                        "Temp",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
                                                            // color: Constants.textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        data[index]
                                                                ['temperature']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
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
                                                        "Value %",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
                                                            // color: Constants.textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        data[index]['deviation']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
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
                                                        "Temp %",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
                                                            // color: Constants.textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        data[index][
                                                                'temperature_deviation']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
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
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
            ],
          ),
        ),
      ),
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
            content: Builder(builder: (context) {
              // Get available height and width of the build area of this widget. Make a choice depending on the size.
              var height = MediaQuery.of(context).size.height;
              var width = MediaQuery.of(context).size.width;
              return Form(
                key: _key,
                child: SizedBox(
                  height: height / 4,
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 60,
                        // width: w * 0.45,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Name is required.';
                            return null;
                          },
                          controller: nameController,
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
                                    color: Constants.primaryColor, width: 2.0),
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Value is required.';
                                return null;
                              },
                              controller: valueController,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  labelText: "Value",
                                  hintText: "Value",
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Value % is required.';
                                return null;
                              },
                              controller: valueprcntController,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  labelText: "Value % ",
                                  hintText: "Value % ",
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Temperature is required.';
                                return null;
                              },
                              controller: tempController,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  labelText: "Temp",
                                  hintText: "Temp",
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Temperature % is required.';
                                return null;
                              },
                              controller: tempprcntController,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  labelText: "Temp % ",
                                  hintText: "Temp % ",
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
            }),
            actions: <Widget>[
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_key.currentState!.validate()) {
                        _key.currentState!.save();
                        Navigator.pop(context);
                        AddSteamMachineList(
                            nameController.text,
                            valueController.text,
                            valueprcntController.text,
                            tempController.text,
                            tempprcntController.text);
                      }
                      // Navigator.pop(context);
                      // _textFieldController.clear();
                      // Constants.showtoast("Machine Added!");
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

  Future<void> _updateTextInputDialog(BuildContext context, String id) async {
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
            content: Builder(builder: (context) {
              // Get available height and width of the build area of this widget. Make a choice depending on the size.
              var height = MediaQuery.of(context).size.height;
              var width = MediaQuery.of(context).size.width;
              return Form(
                key: _key,
                child: SizedBox(
                  height: height / 4,
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 60,
                        // width: w * 0.45,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Name is required.';
                            return null;
                          },
                          controller: nameController,
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
                                    color: Constants.primaryColor, width: 2.0),
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Value is required.';
                                return null;
                              },
                              controller: valueController,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  labelText: "Value",
                                  hintText: "Value",
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Value % is required.';
                                return null;
                              },
                              controller: valueprcntController,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  labelText: "Value % ",
                                  hintText: "Value % ",
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Temperature is required.';
                                return null;
                              },
                              controller: tempController,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  labelText: "Temp",
                                  hintText: "Temp",
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Temperature % is required.';
                                return null;
                              },
                              controller: tempprcntController,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  labelText: "Temp % ",
                                  hintText: "Temp % ",
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
            }),
            actions: <Widget>[
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_key.currentState!.validate()) {
                        _key.currentState!.save();
                        Navigator.pop(context);
                        UpdateSteamMachineList(
                            nameController.text,
                            valueController.text,
                            valueprcntController.text,
                            tempController.text,
                            tempprcntController.text,
                            id);
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
                      ),
                      Text(
                        "Update",
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

class FlueThermoPack extends StatefulWidget {
  const FlueThermoPack({Key? key}) : super(key: key);

  @override
  State<FlueThermoPack> createState() => _FlueThermoPackState();
}

class _FlueThermoPackState extends State<FlueThermoPack>
    with AutomaticKeepAliveClientMixin<FlueThermoPack> {
  TextEditingController nameController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController tempController = TextEditingController();
  TextEditingController valueprcntController = TextEditingController();
  TextEditingController tempprcntController = TextEditingController();
  var data;
  bool isLoad = false;
  late SharedPreferences prefs;
  String? tokenvalue;

  @override
  void initState() {

    super.initState();
    fetchThermoMachineList();
  }

  void fetchThermoMachineList() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse('${Constants.weblink}GetFlueGasThermoPackListingData/${DateTime.now().toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      print(data);
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

  void AddThermoMachineList(
    String machine,
    String value,
    String value_deviation,
    String temperature,
    String temperature_deviation,
  ) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}GetFlueGasThermoPackListingDataAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "machine_name": machine,
        "value": value.toString(),
        "deviation": value_deviation.toString(),
        "temperature": temperature.toString(),
        "temperature_deviation": temperature_deviation.toString(),
      }),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      nameController.clear();
      valueController.clear();
      tempController.clear();
      valueprcntController.clear();
      tempprcntController.clear();
      Constants.showtoast("Machine Added!");
      fetchThermoMachineList();
      // setState(() {
      //   isLoad = false;
      // });
    } else {
      // setState(() {
      //   isLoad = false;
      // });
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void UpdateThermoMachineList(
      String uid,
      String machine,
      String value,
      String value_deviation,
      String temperature,
      String temperature_deviation,
      String id) async {
    final response = await http.post(
      Uri.parse(
          '${Constants.weblink}GetFlueGasThermoPackListingDataUpdated/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        '_method': "PUT",
        "machine_name": machine,
        "value": value.toString(),
        "deviation": value_deviation.toString(),
        "temperature": temperature.toString(),
        "temperature_deviation": temperature_deviation.toString(),
        // "id": id.toString(),
      }),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      nameController.clear();
      valueController.clear();
      tempController.clear();
      valueprcntController.clear();
      tempprcntController.clear();
      Constants.showtoast("Machine Updated!");
      fetchThermoMachineList();
      // setState(() {
      //   isLoad = false;
      // });
    } else {
      print(response.statusCode);
      print(response.body);
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void deleteMachine(int id) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}GetFlueGasThermoPackListingDelete/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{'_method': 'DELETE'}),
    );
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);

      Constants.showtoast("Machine Deleted!");
      fetchThermoMachineList();
      // setState(() {
      //   isLoad = false;
      // });
    } else {
      // setState(() {
      //   isLoad = false;
      // });
      Constants.showtoast("Error Fetching Data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => fetchThermoMachineList());
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18),
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
                    // width: 100,
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: ElevatedButton(
                        onPressed: () {
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
              (isLoad == true)
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
                                        offset: const Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 15),
                                  child: Column(
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
                                                    setState(() {
                                                      nameController
                                                          .text = data[index]
                                                              ['machine_name']
                                                          .toString();
                                                      valueController.text =
                                                          data[index]['value']
                                                              .toString();
                                                      valueprcntController
                                                          .text = data[index]
                                                              ['deviation']
                                                          .toString();
                                                      tempController
                                                          .text = data[index]
                                                              ['temperature']
                                                          .toString();
                                                      tempprcntController
                                                          .text = data[index][
                                                              'temperature_deviation']
                                                          .toString();
                                                    });
                                                    _updateTextInputDialog(
                                                        context,
                                                        data[index]['id']
                                                            .toString(),
                                                        data[index]['uid']
                                                            .toString());
                                                  },
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: Colors.green,
                                                    size: 20,
                                                  )),
                                              IconButton(
                                                  onPressed: () {
                                                    _deleteMachineDialog(
                                                        context,
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
                                                        "Value",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
                                                            // color: Constants.textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        data[index]['value']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
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
                                                        "Temp",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
                                                            // color: Constants.textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        data[index]
                                                                ['temperature']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
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
                                                        "Value %",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
                                                            // color: Constants.textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        data[index]['deviation']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
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
                                                        "Temp %",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
                                                            // color: Constants.textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        data[index][
                                                                'temperature_deviation']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
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
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
            ],
          ),
        ),
      ),
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
            content: Builder(builder: (context) {
              // Get available height and width of the build area of this widget. Make a choice depending on the size.
              var height = MediaQuery.of(context).size.height;
              var width = MediaQuery.of(context).size.width;
              return Form(
                key: _key,
                child: SizedBox(
                  height: height / 4,
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 60,
                        // width: w * 0.45,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Name is required.';
                            return null;
                          },
                          controller: nameController,
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
                                    color: Constants.primaryColor, width: 2.0),
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Value is required.';
                                return null;
                              },
                              controller: valueController,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  labelText: "Value",
                                  hintText: "Value",
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Value % is required.';
                                return null;
                              },
                              controller: valueprcntController,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  labelText: "Value % ",
                                  hintText: "Value % ",
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Temperature is required.';
                                return null;
                              },
                              controller: tempController,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  labelText: "Temp",
                                  hintText: "Temp",
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Temperature % is required.';
                                return null;
                              },
                              controller: tempprcntController,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  labelText: "Temp % ",
                                  hintText: "Temp % ",
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
            }),
            actions: <Widget>[
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_key.currentState!.validate()) {
                        _key.currentState!.save();
                        Navigator.pop(context);
                        AddThermoMachineList(
                            nameController.text,
                            valueController.text,
                            valueprcntController.text,
                            tempController.text,
                            tempprcntController.text);
                      }
                      // Navigator.pop(context);
                      // _textFieldController.clear();
                      // Constants.showtoast("Machine Added!");
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

  Future<void> _updateTextInputDialog(
      BuildContext context, String id, String uid) async {
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
            content: Builder(builder: (context) {
              // Get available height and width of the build area of this widget. Make a choice depending on the size.
              var height = MediaQuery.of(context).size.height;
              var width = MediaQuery.of(context).size.width;
              return Form(
                key: _key,
                child: SizedBox(
                  height: height / 4,
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 60,
                        // width: w * 0.45,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Name is required.';
                            return null;
                          },
                          controller: nameController,
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
                                    color: Constants.primaryColor, width: 2.0),
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Value is required.';
                                return null;
                              },
                              controller: valueController,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  labelText: "Value",
                                  hintText: "Value",
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Value % is required.';
                                return null;
                              },
                              controller: valueprcntController,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  labelText: "Value % ",
                                  hintText: "Value % ",
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Temperature is required.';
                                return null;
                              },
                              controller: tempController,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  labelText: "Temp",
                                  hintText: "Temp",
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Temperature % is required.';
                                return null;
                              },
                              controller: tempprcntController,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  labelText: "Temp % ",
                                  hintText: "Temp % ",
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
            }),
            actions: <Widget>[
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_key.currentState!.validate()) {
                        _key.currentState!.save();
                        Navigator.pop(context);
                        UpdateThermoMachineList(
                            uid,
                            nameController.text,
                            valueController.text,
                            valueprcntController.text,
                            tempController.text,
                            tempprcntController.text,
                            id);
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
                      ),
                      Text(
                        "Update",
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
