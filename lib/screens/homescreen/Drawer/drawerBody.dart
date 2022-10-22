import 'package:flutter/material.dart';

import '../../../constants.dart';

Widget createDrawerBodyItem(
    {required String path,
    required String text,
    required GestureTapCallback onTap}) {
  return ListTile(
    dense: true,
    visualDensity: VisualDensity(horizontal: 0, vertical: -1),
    // contentPadding: EdgeInsets.only(top: 0.0, bottom: 0.0),
    title: Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8.0),
          height: 40,
          width: 40,
          child: Image.asset(path),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            text,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: Constants.popins),
          ),
        )
      ],
    ),
    onTap: onTap,
  );
}
