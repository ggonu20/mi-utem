import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:mi_utem/themes/theme.dart';

class BloqueVacio extends StatelessWidget {
  const BloqueVacio({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MainTheme.lightGrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DottedBorder(
        strokeWidth: 2,
        color: MainTheme.grey,
        borderType: BorderType.RRect,
        radius: Radius.circular(15),
        child: Container(),
      ),
    );
  }
}