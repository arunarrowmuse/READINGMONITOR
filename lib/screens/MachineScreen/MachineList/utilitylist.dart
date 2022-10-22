import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readingmonitor/screens/MachineScreen/MachineList/utilityDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';

class UtilityList extends StatefulWidget {
  const UtilityList({Key? key}) : super(key: key);

  @override
  State<UtilityList> createState() => _UtilityListState();
}

class _UtilityListState extends State<UtilityList>
    with AutomaticKeepAliveClientMixin<UtilityList> {
  TextEditingController name = TextEditingController();
  bool isLoad = false;
  var data;
  late SharedPreferences prefs;
  String? tokenvalue;

  @override
  void initState() {
    super.initState();
    FetchUtilityMachineList();
    print(DateTime.now());
  }

  void FetchUtilityMachineList() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse('${Constants.weblink}GetUtilityLisiting/${DateTime.now().toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
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

  void AddUtilityMachineList() async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}UtilityAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "uitility_categories": name.text,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      data = jsonDecode(response.body);
      Constants.showtoast("Machine Added!");
      name.clear();
      FetchUtilityMachineList();
    } else {
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void UpdateMachinesMachineList(String id) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}UtiliyUpdate/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        '_method': "PUT",
        "uitility_categories": name.text,
        "id": id,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      data = jsonDecode(response.body);
      Constants.showtoast("Machine Updated!");
      name.clear();
      FetchUtilityMachineList();
    } else {
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void deleteMachine(int id) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}UtiliyDelete/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{'_method': "DELETE"}),
    );
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 202) {
      Constants.showtoast("Machine Deleted!");
      FetchUtilityMachineList();
    } else {
      Constants.showtoast("Error Fetching Data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchUtilityMachineList());
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Machine",
                    style: TextStyle(
                      // color: Colors.white,
                      fontSize: 25,
                      fontFamily: Constants.popinsbold,
                    ),
                  ),
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
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  elevation: 0.5,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UtilityDetail(
                                                      name: data[index][
                                                          'uitility_categories'],
                                                      id: data[index]['id']
                                                          .toString())));
                                    },
                                    child: ListTile(
                                        leading: CircleAvatar(
                                          radius: 14,
                                          backgroundColor:
                                              Constants.secondaryColor,
                                          child: Text(
                                            (index + 1).toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: Constants.popins,
                                            ),
                                          ),
                                        ),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              data[index]['uitility_categories']
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    name.text = data[index]
                                                        ['uitility_categories'];
                                                    updatemachine(
                                                        context,
                                                        data[index]['id']
                                                            .toString());
                                                  },
                                                  icon: Icon(Icons.edit),
                                                  color: Colors.green,
                                                ),
                                                // SizedBox(width: 20),
                                                IconButton(
                                                  onPressed: () {
                                                    _deleteMachineDialog(
                                                        context,
                                                        data[index]['id']);
                                                  },
                                                  icon: Icon(Icons.delete),
                                                  color: Colors.red,
                                                ),
                                              ],
                                            )
                                          ],
                                        )),
                                  ),
                                );
                              }),
                        ),
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
          return Form(
            key: _key,
            child: AlertDialog(
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
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required.';
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
              actions: <Widget>[
                Container(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_key.currentState!.validate()) {
                          _key.currentState!.save();
                          Navigator.pop(context);
                          AddUtilityMachineList();
                        }
                      });
                    },
                    style: ButtonStyle(
                        textStyle:
                            MaterialStateProperty.all<TextStyle>(TextStyle(
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
            ),
          );
        });
  }

  Future<void> updatemachine(BuildContext context, String id) async {
    final w = MediaQuery.of(context).size.width;
    final GlobalKey<FormState> _key = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (context) {
          return Form(
            key: _key,
            child: AlertDialog(
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
              content: SizedBox(
                height: 60,
                width: w * 0.25,
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required.';
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
              actions: <Widget>[
                Container(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_key.currentState!.validate()) {
                          _key.currentState!.save();
                          Navigator.pop(context);
                          UpdateMachinesMachineList(id);
                        }
                      });
                    },
                    style: ButtonStyle(
                        textStyle:
                            MaterialStateProperty.all<TextStyle>(TextStyle(
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
                          size: 16,
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
            ),
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
