import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ToDo extends StatefulWidget {
  const ToDo({Key? key}) : super(key: key);

  @override
  State<ToDo> createState() => _ToDoState();
}

class _ToDoState extends State<ToDo> {
  DateTime selectedMonth = DateTime.now();
  TextEditingController _textEditingController = TextEditingController();
  late SharedPreferences prefs;
  String? tokenvalue;
  bool isLoad = false;
  var data;

  Future<void> _selectDate(BuildContext context) async {
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Constants.primaryColor, // header background color
              // onPrimary: Constants.secondaryColor, // header text color
              onSurface: Constants.primaryColor, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
                // style: TextButton.styleFrom(
                //   primary: Colors.red, // button text color
                // ),
                ),
          ),
          child: child!,
        );
      },
    );
    if (selected != null && selected != selectedMonth) {
      setState(() {
        selectedMonth = selected;
        print(selectedMonth);
        print(DateTime.now().toString().split(" ")[0]);
      });
    }
  }

  void initState() {
    super.initState();
    FetchToDoList();
  }

  @override
  void FetchToDoList() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    print(tokenvalue);
    final response = await http.get(
      Uri.parse('${Constants.weblink}GetToDoListDataListing'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      print(response.statusCode);
      print(response.body);
      data = jsonDecode(response.body);
      // print("hey im here");
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

  void AddToDoList() async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}GetToDoListDataAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "date": DateTime.now().toString(),
        "comment": _textEditingController.text,
      }),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      _textEditingController.clear();
      Constants.showtoast("TODO Added!");
      FetchToDoList();
    } else {
      print(response.statusCode);
      print(response.body);
      Constants.showtoast("Error Adding Data.");
    }
  }

  void UpdateToDoList(String id) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}GetToDoListDataAddUpdated/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        '_method': "PUT",
        "date": DateTime.now().toString(),
        // if want the created date only keep data[index]['date']
        "comment": _textEditingController.text,
      }),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      _textEditingController.clear();
      Constants.showtoast("TODO Updated!");
      FetchToDoList();
    } else {
      print(response.statusCode);
      print(response.body);
      Constants.showtoast("Error Updating Data.");
    }
  }

  void deleteMachine(int id) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}GetToDoListDataDelete/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{'_method': 'DELETE'}),
    );
    if (response.statusCode == 200) {
      Constants.showtoast("Machine Deleted!");
      FetchToDoList();
    } else {
      Constants.showtoast("Error Fetching Data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    DateTime now = DateTime.now();
    var formattedDate = DateFormat('MMMM-yy').format(selectedMonth);
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(left: 18.0, right: 18),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TODO",
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
                      _textEditingController.clear();
                      _displayTextInputDialog(context);
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Constants.primaryColor)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(),
                        const Text("      Add        ",
                            style: TextStyle(color: Colors.white)),
                        const Icon(
                          Icons.add_circle,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8.0),
                height: 40,
                width: 40,
                child: Image.asset("assets/icons/menu/date.png",
                    color: Constants.primaryColor),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 1.0),
                child: GestureDetector(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: Card(
                    elevation: 2,
                    color: Colors.white,
                    child: SizedBox(
                      height: 30,
                      width: 140,
                      child: Center(
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: Constants.popins),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    //todo:- navigate to the report of the date
                  },
                  child: Card(
                    elevation: 2,
                    color: Constants.primaryColor,
                    child: SizedBox(
                      height: 32,
                      width: 50,
                      child: Center(
                        child: Text(
                          "Go",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              fontFamily: Constants.popins),
                        ),
                      ),
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
              : (data.length != 0)
                  ? Expanded(
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
                                  vertical: 15, horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: w * 0.65,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          // "15-04-2022 • 3:22 AM",
                                          "• " + data[index]['date'] + " •",
                                          style: TextStyle(
                                              fontFamily: Constants.popins,
                                              color: Constants.textColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          data[index]['comment'].toString(),
                                          style: TextStyle(
                                              fontFamily: Constants.popins,
                                              // color: Constants.textColor,
                                              // fontWeight: FontWeight.w600,
                                              fontSize: 14),
                                        )
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            _textEditingController.text =
                                                data[index]['comment']
                                                    .toString();
                                            updateDialogBox(context,
                                                data[index]['id'].toString());
                                            // UpdateToDoList(data[index]['id'].toString());
                                          },
                                          icon: const Icon(Icons.edit,
                                              color: Colors.green)),
                                      IconButton(
                                          onPressed: () {
                                            _deleteMachineDialog(
                                                context, data[index]['id']);
                                          },
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      height: 300,
                      child: Center(
                        child: Text(
                          "No Todo Found",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: Constants.popins),
                        ),
                      ),
                    )
        ],
      ),
    ));
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
            content: Container(
              width: w * 0.25,
              child: TextField(
                maxLines: 6,
                controller: _textEditingController,
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
              Container(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                      AddToDoList();

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

  Future<void> updateDialogBox(BuildContext context, String id) async {
    final w = MediaQuery.of(context).size.width;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            title: Text(
              "Update TODO",
              style: TextStyle(
                // color: Colors.white,
                fontSize: 20,
                fontFamily: Constants.popinsbold,
              ),
            ),
            content: Container(
              width: w * 0.25,
              child: TextField(
                maxLines: 6,
                controller: _textEditingController,
                style: TextStyle(
                  fontFamily: Constants.popins,
                  // color: Constants.textColor,
                ),
                decoration: InputDecoration(
                    labelText: "TODO",
                    hintText: "TODO Detail",
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
              Container(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                      // AddToDoList();
                      UpdateToDoList(id);
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
