import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';

class ReadingGEB extends StatefulWidget {
  const ReadingGEB({Key? key}) : super(key: key);

  @override
  State<ReadingGEB> createState() => _ReadingGEBState();
}

class _ReadingGEBState extends State<ReadingGEB> {
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
        // TextField(
        //   style: TextStyle(fontFamily: Constants.popins, fontSize: 14),
        //   decoration: InputDecoration(
        //       hintText: 'Search Machines',
        //       hintStyle: TextStyle(fontFamily: Constants.popins, fontSize: 14),
        //       contentPadding: const EdgeInsets.only(left: 25),
        //       border:
        //       OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
        //   onChanged: (value) {
        //     // do something
        //   },
        // ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
                  "KWH",
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
                    "KVARH",
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
        Expanded(
          child: ListView.builder(
              itemCount: 6,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      width: w / 4,
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
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
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
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
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
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
                  ],
                );
              }),
        )
      ],
    ));
  }
}
