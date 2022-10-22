import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'fluegaslist.dart';
import 'geblist.dart';
import 'machineslist.dart';
import 'manometerlist.dart';
import 'miscellaneous.dart';
import 'steamboilerlist.dart';
import 'supplypumplist.dart';
import 'thermopack.dart';
import 'utilitylist.dart';
import 'waterqualitylist.dart';

class MainMachineList extends StatefulWidget {
  const MainMachineList({Key? key}) : super(key: key);

  @override
  State<MainMachineList> createState() => _MainMachineListState();
}

class _MainMachineListState extends State<MainMachineList> {
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
                  UtilityList(),
                  SteamBoilerList(),
                  ThermoPackList(),
                  MachinesList(),
                  WaterQualityList(),
                  SupplyPumpList(),
                  GEBList(),
                  ManoMeterList(),
                  FlueGasList(),
                  MiscellaneousList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
