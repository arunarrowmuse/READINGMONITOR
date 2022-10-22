import 'package:flutter/material.dart';
import 'package:readingmonitor/screens/meterReading/readingGEB.dart';
import 'package:readingmonitor/screens/meterReading/readingMachines.dart';
import 'package:readingmonitor/screens/meterReading/readingMisc.dart';
import 'package:readingmonitor/screens/meterReading/readingUtility.dart';

import '../../constants.dart';

class MeterReading extends StatefulWidget {
  const MeterReading({Key? key}) : super(key: key);

  @override
  State<MeterReading> createState() => _MeterReadingState();
}

class _MeterReadingState extends State<MeterReading> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 50,
              child: AppBar(
                backgroundColor: Colors.white,
                bottom: TabBar(
                  indicatorColor: Colors.red,
                  isScrollable: true,
                  tabs: [
                    Tab(
                        child: Text("Utility",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                    Tab(
                        child: Text("Machines",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                    Tab(
                        child: Text("GEB",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                    Tab(
                        child: Text("Misc",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  ReadingUtility(),
                  ReadingMachines(),
                  ReadingGEB(),
                  ReadingMisc(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
