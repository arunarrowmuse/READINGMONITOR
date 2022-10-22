import 'package:flutter/material.dart';

class MachineComparison extends StatefulWidget {
  const MachineComparison({Key? key}) : super(key: key);

  @override
  State<MachineComparison> createState() => _MachineComparisonState();
}

class _MachineComparisonState extends State<MachineComparison> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Machine Comparison"),
      ),
    );
  }
}
