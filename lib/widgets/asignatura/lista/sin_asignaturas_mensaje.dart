import 'package:flutter/material.dart';
import 'package:mi_utem/widgets/custom_error_widget.dart';

class SinAsignaturasMensaje extends StatelessWidget {

  final String mensaje, emoji;

  const SinAsignaturasMensaje({
    super.key,
    required this.mensaje,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: CustomErrorWidget(
        emoji: emoji,
        title: mensaje,
      ),
    ),
  );
}