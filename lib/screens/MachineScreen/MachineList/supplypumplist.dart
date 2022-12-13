import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';

class SupplyPumpList extends StatefulWidget {
  const SupplyPumpList({Key? key}) : super(key: key);

  @override
  State<SupplyPumpList> createState() => _SupplyPumpListState();
}

class _SupplyPumpListState extends State<SupplyPumpList>
    with AutomaticKeepAliveClientMixin<SupplyPumpList> {
  TextEditingController name = TextEditingController();
  TextEditingController average = TextEditingController();
  TextEditingController deviation = TextEditingController();
  bool isLoad = false;
  var data;
  late SharedPreferences prefs;
  String? tokenvalue;

  @override
  void initState() {
    FetchSupplyMachineList();
    super.initState();
  }

  void FetchSupplyMachineList() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse('${Constants.weblink}GetSupplyPumpListing/${DateTime.now().toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      print(response.statusCode);
      print(response.body);
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

  void AddSupplyMachineList(
      String machine, String averaged, String deviationd) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}GetSupplyPumpDataAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "name": machine,
        "average": averaged.toString(),
        "deviation": deviationd.toString(),
      }),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      Constants.showtoast("Machine Added!");
      name.clear();
      average.clear();
      deviation.clear();
      FetchSupplyMachineList();
    } else {
      print(response.statusCode);
      print(response.body);
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void UpdateSupplyMachineList(
      String machine, String average, String deviation, String id) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}GetSupplyPumpDataUpdated/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        '_method': "PUT",
        "name": machine,
        "average": average.toString(),
        "deviation": deviation.toString(),
        // "id": id.toString(),
      }),
    );
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);

      Constants.showtoast("Machine Updated!");
      FetchSupplyMachineList();
      // setState(() {
      //   isLoad = false;
      // });
    } else {
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void deleteMachine(int id) async {
    final response = await http.post(
      Uri.parse('${Constants.weblink}GetSupplyPumpDataDeleted/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{'_method': 'DELETE'}),
    );
    if (response.statusCode == 200) {
      Constants.showtoast("Machine Deleted!");
      FetchSupplyMachineList();
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
        return  Future(() => FetchSupplyMachineList());
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
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          name.clear();
                          average.clear();
                          deviation.clear();
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
                                      vertical: 10, horizontal: 15),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data[index]['name'].toString(),
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
                                                            ['name']
                                                        .toString();
                                                    average.text = data[index]
                                                            ['average']
                                                        .toString();
                                                    deviation.text = data[index]
                                                            ['deviation']
                                                        .toString();
                                                    _updateDialog(
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Flow / Unit (Average)",
                                            style: TextStyle(
                                                fontFamily: Constants.popins,
                                                fontSize: 12),
                                          ),
                                          Text(
                                            data[index]['average'].toString(),
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
                                            "Deviation",
                                            style: TextStyle(
                                                fontFamily: Constants.popins,
                                                fontSize: 12),
                                          ),
                                          Text(
                                            data[index]['deviation'].toString(),
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
            content: Builder(
              builder: (context) {
                // Get available height and width of the build area of this widget. Make a choice depending on the size.
                var height = MediaQuery.of(context).size.height;
                var width = MediaQuery.of(context).size.width;
                return Form(
                  key: _key,
                  child: SizedBox(
                    height: height / 4.5,
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 60,
                          // width: w * 0.25,
                          child: TextFormField(
                            controller: name,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Name is required.';
                              return null;
                            },
                            style: TextStyle(
                              fontFamily: Constants.popins,
                              // color: Constants.textColor,
                            ),
                            decoration: InputDecoration(
                                labelText: "Machine Name",
                                hintText: "Machine Name",
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
                            controller: average,
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
                                labelText: "Flow/Unit Average",
                                hintText: "Flow/Unit Average",
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
                            controller: deviation,
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
                                labelText: "Deviation",
                                hintText: "Deviation",
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
                        AddSupplyMachineList(
                            name.text, average.text, deviation.text);
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

  Future<void> _updateDialog(BuildContext context, String id) async {
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
                    height: height / 4.5,
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
                        SizedBox(
                          height: 60,
                          // width: w * 0.25,
                          child: TextFormField(
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            controller: average,
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
                                labelText: "Flow/Unit Average",
                                hintText: "Flow/Unit Average",
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
                            controller: deviation,
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
                                labelText: "Deviation",
                                hintText: "Deviation",
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
                        UpdateSupplyMachineList(
                            name.text, average.text, deviation.text, id);
                        // AddSupplyMachineList(
                        //     name.text, average.text, deviation.text);
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
