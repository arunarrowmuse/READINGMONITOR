import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import 'report_tabs.dart';

class ViewReport extends StatefulWidget {
  const ViewReport({Key? key}) : super(key: key);

  @override
  State<ViewReport> createState() => _ViewReportState();
}

class _ViewReportState extends State<ViewReport> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2050, 1));
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
        const SizedBox(
          height: 10,
        ),
        Container(
          height: 40,
          color: Constants.secondaryColor,
          child: GestureDetector(
            onTap: () {
              // _selectDate(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon(Icons.calendar_month, color: Colors.white,),
                Container(
                    padding: const EdgeInsets.all(8.0),
                    height: 40,
                    width: 40,
                    child: Image.asset("assets/icons/calendar.png")),
                SizedBox(
                  height: 30,
                  width: 100,
                  child: Center(
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: Constants.popins),
                    ),
                  ),
                ),
                // Container(
                //     padding: const EdgeInsets.all(8.0),
                //     height: 40,
                //     width: 40,
                //     child: Image.asset("assets/icons/down.png")),
                // Icon(Icons.l, color: Colors.white,),
              ],
            ),
          ),
        ),
        Expanded(
          child: GridView.count(
              primary: false,
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              padding: const EdgeInsets.only(
                  top: 40, left: 70, right: 70, bottom: 20),
              children: List.generate(choices.length, (index) {
                return Center(
                  child: SelectCard(choice: choices[index]),
                );
              })),
        )
      ],
    ));
  }
}

class Choice {
  const Choice({required this.title, required this.icon, required this.index});

  final String title;
  final String icon;
  final int index;
}

const List<Choice> choices = <Choice>[
  Choice(
      title: 'Utility',
      icon: "assets/icons/report/electric_bolt.png",
      index: 0),
  Choice(
      title: 'Steam Boiler', icon: "assets/icons/report/steam.png", index: 1),
  Choice(
      title: 'Thermopack', icon: "assets/icons/report/thermpack.png", index: 2),
  Choice(title: 'Machines', icon: "assets/icons/report/machines.png", index: 3),
  Choice(
      title: 'Water Quality',
      icon: "assets/icons/report/Quality.png",
      index: 4),
  Choice(
      title: 'Supply Pump & Input',
      icon: "assets/icons/report/pump.png",
      index: 5),
  Choice(title: 'GEB', icon: "assets/icons/report/geb.png", index: 6),
  Choice(
      title: 'Mano Meter',
      icon: "assets/icons/report/mano_meter.png",
      index: 7),
  Choice(title: 'Flue Gas', icon: "assets/icons/report/temp.png", index: 8),
  Choice(
      title: 'Miscellaneous', icon: "assets/icons/report/misc.png", index: 9),
];

class SelectCard extends StatelessWidget {
  const SelectCard({Key? key, required this.choice}) : super(key: key);
  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReportTabs(selectedPage: choice.index),
          ),
        );
      },
      child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          // color: Colors.orange,
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: h * 0.04, child: Image.asset(choice.icon)),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: w * 0.3,
                    child: Text(choice.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Constants.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: Constants.popins)),
                  ),
                ]),
          )),
    );
  }
}
