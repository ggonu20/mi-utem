import 'package:flutter/material.dart';
import 'package:mi_utem/themes/theme.dart';

class HorarioCorner extends StatelessWidget {
  final double height;
  final double width;
  final Color backgroundColor;

  const HorarioCorner({
    Key? key,
    required this.height,
    required this.width,
    this.backgroundColor = MainTheme.lightGrey,
  });

  @override
  Widget build(BuildContext context) => Table(
    defaultColumnWidth: FixedColumnWidth(width),
    border: TableBorder(
      right: BorderSide(
        color: Color(0xFFBDBDBD),
        style: BorderStyle.solid,
        width: 2,
      ),
    ),
    children: [
      TableRow(
        children: [
          Container(
            height: height,
            width: width,
            color: backgroundColor,
          ),
        ],
      ),
    ],
  );
}
