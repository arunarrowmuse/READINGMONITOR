import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';

class ManoMeterList extends StatefulWidget {
  const ManoMeterList({Key? key}) : super(key: key);

  @override
  State<ManoMeterList> createState() => _ManoMeterListState();
}

class _ManoMeterListState extends State<ManoMeterList> {
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
                          ManoSteamBoiler(),
                          ManoThermoPack(),
                        ]))
                  ])),
        ],
      ),
    ));
  }
}

class ManoSteamBoiler extends StatefulWidget {
  const ManoSteamBoiler({Key? key}) : super(key: key);

  @override
  State<ManoSteamBoiler> createState() => _ManoSteamBoilerState();
}

class _ManoSteamBoilerState extends State<ManoSteamBoiler>
    with AutomaticKeepAliveClientMixin<ManoSteamBoiler> {
  TextEditingController name = TextEditingController();
  bool isLoad = false;
  var data;
  late SharedPreferences prefs;
  String? tokenvalue;

  @override
  void initState() {
    FetchManoSteamMachineList();
    super.initState();
  }

  void FetchManoSteamMachineList() async {
    print("1");
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    print("2");
    final response = await http.get(
      Uri.parse('${Constants.weblink}ManoMeterSteamBoilerLisiting/${DateTime.now().toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    print("3");
    print(response.statusCode);
    if (response.statusCode == 200) {
      print("4");
      // print(response.statusCode);
      // print("datdddda");
      data = jsonDecode(response.body);
      print(data);
      setState(() {
        isLoad = false;
      });
    } else {
      print("5");
      setState(() {
        isLoad = false;
      });
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void AddManoSteamMachineList(String machine) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}ManoMeterSteamBoilerAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "steam_boiler": machine,
      }),
    );
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);

      Constants.showtoast("Machine Added!");
      FetchManoSteamMachineList();
    } else {
      print(response.statusCode);
      print(response.body);
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void UpdateManoSteamMachineList(String uid, String machine, String id) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}ManoMeterSteamBoilerUpdate/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        '_method': "PUT",
        "steam_boiler": machine,
      }),
    );
    if (response.statusCode == 200) {
      name.clear();
      // data = jsonDecode(response.body);
      Constants.showtoast("Machine Updated!");
      FetchManoSteamMachineList();
    } else {
      print(response.body);
      print(response.statusCode);
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void deleteMachine(int id) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}ManoMeterSteamBoilerDelete/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{'_method': 'DELETE'}),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      Constants.showtoast("Machine Deleted!");
      FetchManoSteamMachineList();
    } else {
      Constants.showtoast("Error Fetching Data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchManoSteamMachineList());
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
                          name.clear();
                          _displayTextInputDialog(context);
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Constants.primaryColor)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(),
                            const Text("Add",
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
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data[index]["steam_boiler"].toString(),
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
                                                name.text = data[index]
                                                        ['steam_boiler']
                                                    .toString();
                                                _updateDialog(
                                                    context,
                                                    data[index]['uid']
                                                        .toString(),
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
                                                    context, data[index]['id']);
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
    final GlobalKey<FormState> key = GlobalKey<FormState>();
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
            content: Form(
              key: key,
              child: SizedBox(
                height: 60,
                width: w * 0.25,
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Machine name is required.';
                    }
                    return null;
                  },
                  controller: name,
                  style: TextStyle(
                    fontFamily: Constants.popins,
                    // color: Constants.textColor,
                  ),
                  decoration: InputDecoration(
                      labelText: "Machine Name",
                      hintText: "Enter Machine Name",
                      contentPadding:
                          const EdgeInsets.only(bottom: 10.0, left: 10.0),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1.0),
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
            ),
            actions: <Widget>[
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (key.currentState!.validate()) {
                        key.currentState!.save();
                        Navigator.pop(context);
                        AddManoSteamMachineList(name.text);
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

  Future<void> _updateDialog(
      BuildContext context, String uid, String id) async {
    final w = MediaQuery.of(context).size.width;
    final GlobalKey<FormState> key = GlobalKey<FormState>();
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
            content: Form(
              key: key,
              child: SizedBox(
                height: 60,
                width: w * 0.25,
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Machine name is required.';
                    }
                    return null;
                  },
                  controller: name,
                  style: TextStyle(
                    fontFamily: Constants.popins,
                    // color: Constants.textColor,
                  ),
                  decoration: InputDecoration(
                      labelText: "Machine Name",
                      hintText: "Enter Machine Name",
                      contentPadding:
                          const EdgeInsets.only(bottom: 10.0, left: 10.0),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1.0),
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
            ),
            actions: <Widget>[
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (key.currentState!.validate()) {
                        key.currentState!.save();
                        Navigator.pop(context);
                        UpdateManoSteamMachineList(uid, name.text, id);
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

  Future<void> _deleteMachineDialog(BuildContext context, int id) async {
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

class ManoThermoPack extends StatefulWidget {
  const ManoThermoPack({Key? key}) : super(key: key);

  @override
  State<ManoThermoPack> createState() => _ManoThermoPackState();
}

class _ManoThermoPackState extends State<ManoThermoPack> with AutomaticKeepAliveClientMixin<ManoThermoPack> {
  TextEditingController nameController = TextEditingController();
  bool isLoad = false;
  var data;
  late SharedPreferences prefs;
  String? tokenvalue;

  @override
  void initState() {
    FetchManoThermoMachineList();
    super.initState();
  }

  void FetchManoThermoMachineList() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse('${Constants.weblink}ManoMeterThermopackLisiting/${DateTime.now().toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      // print(response.statusCode);
      print("data");
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

  void AddManoThermoMachineList(String machine) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}ManoMeterThermopackAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "thermopack": machine,
      }),
    );
    if (response.statusCode == 200) {
      nameController.clear();
      // data = jsonDecode(response.body);
      Constants.showtoast("Machine Added!");
      FetchManoThermoMachineList();
    } else {
      print(response.statusCode);
      print(response.body);
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void UpdateManoThermoMachineList(
      String uid, String machine, String id) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}ManoMeterThermopackUpdate/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        '_method': "PUT",
        "thermopack": machine,
      }),
    );
    if (response.statusCode == 200) {
      nameController.clear();
      // data = jsonDecode(response.body);
      Constants.showtoast("Machine Updated!");
      FetchManoThermoMachineList();
    } else {
      print(response.body);
      print(response.statusCode);
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void deleteMachine(int id) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}ManoMeterThermopackDelete/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{'_method': 'DELETE'}),
    );
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      Constants.showtoast("Machine Deleted!");
      FetchManoThermoMachineList();
    } else {
      Constants.showtoast("Error Fetching Data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      onRefresh: (){
        return Future(() => FetchManoThermoMachineList());
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
                          nameController.clear();
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
                          height: 500,
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
                                          vertical: 5, horizontal: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data[index]['thermopack'].toString(),
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
                                                    nameController.text =
                                                        data[index]['thermopack'];
                                                    _updateDialog(
                                                            context,
                                                            data[index]['uid']
                                                                .toString(),
                                                            data[index]['id']
                                                                .toString())
                                                        .toString();
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
            content: SizedBox(
              height: 40,
              width: w * 0.25,
              child: TextField(
                controller: nameController,
                style: TextStyle(
                  fontFamily: Constants.popins,
                  // color: Constants.textColor,
                ),
                decoration: InputDecoration(
                    labelText: "Machine Name",
                    hintText: "Enter Machine Name",
                    contentPadding:
                        const EdgeInsets.only(bottom: 10.0, left: 10.0),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Constants.primaryColor, width: 2.0),
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
            actions: <Widget>[
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (nameController.text == "") {
                        Constants.showtoast("please fill the field");
                      } else {
                        Navigator.pop(context);
                        AddManoThermoMachineList(nameController.text);
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

  Future<void> _updateDialog(
      BuildContext context, String uid, String id) async {
    final w = MediaQuery.of(context).size.width;
    final GlobalKey<FormState> key = GlobalKey<FormState>();
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
            content: Form(
              key: key,
              child: SizedBox(
                height: 60,
                width: w * 0.25,
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Machine name is required.';
                    }
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
                      contentPadding:
                          const EdgeInsets.only(bottom: 10.0, left: 10.0),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1.0),
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
            ),
            actions: <Widget>[
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (key.currentState!.validate()) {
                        key.currentState!.save();
                        Navigator.pop(context);
                        UpdateManoThermoMachineList(
                            uid, nameController.text, id);
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
