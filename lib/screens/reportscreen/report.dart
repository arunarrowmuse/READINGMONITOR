import 'package:flutter/material.dart';

import '../../constants.dart';
import '../charts.dart';
import '../todo.dart';
import '../uploadreport/uploadreport.dart';
import 'viewreport.dart';


// todo ABANDONED PAGE

class Report extends StatefulWidget {
  int page;

  Report({Key? key, required this.page}) : super(key: key);

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  late int pageIndex;

  final pages = [
    const ViewReport(),
    const UploadReport(),
    const Charts(),
    const ToDo(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageIndex = widget.page;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: pages[pageIndex],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: SizedBox(
          height: 70.0,
          width: 70.0,
          child: FittedBox(
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              child: Image.asset("assets/images/user1.png"),
              onPressed: () {},
            ),
          ),
        ),
        bottomNavigationBar: buildMyNavBar(context));
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Constants.secondaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                pageIndex = 0;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    height: 32,
                    width: 32,
                    child: Image.asset("assets/icons/menu/report.png")),
                Text(
                  "Report",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: Constants.popins),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                pageIndex = 1;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    height: 32,
                    width: 32,
                    child: Image.asset("assets/icons/menu/upload.png")),
                Text(
                  "Upload",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: Constants.popins),
                ),
              ],
            ),
          ),
          Container(),
          GestureDetector(
            onTap: () {
              setState(() {
                pageIndex = 2;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    height: 32,
                    width: 32,
                    child: Image.asset("assets/icons/menu/charts.png")),
                Text(
                  "Charts",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: Constants.popins),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                pageIndex = 3;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    height: 32,
                    width: 32,
                    child: Image.asset("assets/icons/menu/todo.png")),
                Text(
                  "To Do",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: Constants.popins),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
