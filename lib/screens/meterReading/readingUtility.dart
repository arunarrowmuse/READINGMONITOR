       import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';

class ReadingUtility extends StatefulWidget {
  const ReadingUtility({Key? key}) : super(key: key);

  @override
  State<ReadingUtility> createState() => _ReadingUtilityState();
}

class _ReadingUtilityState extends State<ReadingUtility> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    DateTime now = DateTime.now();
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    return Scaffold(
        body: Column(
      children: [
        const SizedBox(height: 10),
        Container(
          height: 40,
          // color: Constants.secondaryColor,
          child: GestureDetector(
            onTap: () {
              _selectDate(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Icon(Icons.calendar_month, color: Colors.white,),
                    Container(
                        padding: const EdgeInsets.all(8.0),
                        height: 40,
                        width: 40,
                        child: Image.asset(
                          "assets/icons/calendar.png",
                          color: Constants.primaryColor,
                        )),
                    SizedBox(
                      height: 30,
                      width: 100,
                      child: Center(
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                              color: Constants.secondaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: Constants.popins),
                        ),
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.all(8.0),
                        height: 40,
                        width: 40,
                        child: Image.asset(
                          "assets/icons/down.png",
                          color: Constants.primaryColor,
                        )),
                    // Icon(Icons.l, color: Colors.white,),
                  ],
                ),
                Container(
                  height: 30,
                  padding: const EdgeInsets.only(right: 15.0),
                  // width: 100,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Constants.primaryColor)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(" Sumbit  ",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: Constants.popins,
                                fontSize: 14)),
                        Image.asset(
                          "assets/icons/Edit.png",
                          height: 16,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        TextField(
          style: TextStyle(fontFamily: Constants.popins, fontSize: 14),
          decoration: InputDecoration(
              hintText: 'Search Machines',
              hintStyle: TextStyle(fontFamily: Constants.popins, fontSize: 14),
              contentPadding: const EdgeInsets.only(left: 25),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
          onChanged: (value) {
            // do something
          },
        ),
        Expanded(
          child: ListView.builder(
              itemCount: 6,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Machine $index",
                          style: TextStyle(
                              fontFamily: Constants.popins,
                              color: Constants.textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 15),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.sp,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: w / 4,
                                    decoration: BoxDecoration(
                                        color: Constants.primaryColor.withOpacity(0.4),
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "Date",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                    width: w / 3.2,
                                    decoration: BoxDecoration(
                                        color: Constants.primaryColor.withOpacity(0.4),
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "EM",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                    width: w / 3.2,
                                    decoration: BoxDecoration(
                                        color: Constants.primaryColor.withOpacity(0.4),
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "HM",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                     width: w / 4,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "18/07/22",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                     width: w / 3.2,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "0.23232323",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                     width: w / 3.2,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "0.23434345",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                     width: w / 4,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "18/07/22",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                     width: w / 3.2,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "0.23232323",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                     width: w / 3.2,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "0.23434345",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                     width: w / 4,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "18/07/22",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                     width: w / 3.2,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "0.23232323",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                     width: w / 3.2,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "0.23434345",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                     width: w / 4,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "18/07/22",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                     width: w / 3.2,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "0.23232323",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                     width: w / 3.2,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "0.23434345",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                     width: w / 4,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "18/07/22",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                     width: w / 3.2,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "0.23",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                     width: w / 3.2,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Center(
                                      child: Text(
                                        "0.235",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.popins,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
        )
      ],
    ));
  }
}
