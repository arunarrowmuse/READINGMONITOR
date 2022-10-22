import 'package:flutter/material.dart';

import '../../constants.dart';
import 'uploadGEB.dart';
import 'uploadfluegas.dart';
import 'uploadmachines.dart';
import 'uploadmanometer.dart';
import 'uploadmisc.dart';
import 'uploadsteamboiler.dart';
import 'uploadsupplypump.dart';
import 'uploadthermopack.dart';
import 'uploadutility.dart';
import 'uploadwaterquality.dart';

class UploadReport extends StatefulWidget {
  const UploadReport({Key? key}) : super(key: key);

  @override
  State<UploadReport> createState() => _UploadReportState();
}

class _UploadReportState extends State<UploadReport> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 10,
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
                        child: Text("Steam Boiler",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                    Tab(
                        child: Text("Thermopack",
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
                        child: Text("Water Quality",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                    Tab(
                        child: Text("Supply Pump & Input",
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
                        child: Text("Mano Meter",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                    Tab(
                        child: Text("Flue Gas",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: Constants.popins))),
                    Tab(
                        child: Text("Miscellaneous",
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
                  UploadUtility(),
                  UploadSteamBoiler(),
                  UploadThermoPack(),
                  UploadMachines(),
                  UploadWaterQuality(),
                  UploadSupplyPump(),
                  UploadGEB(),
                  UploadManoMeter(),
                  UploadFlueGas(),
                  UploadMisc()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
