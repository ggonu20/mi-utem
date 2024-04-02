import 'package:flutter/material.dart';
import 'package:mi_utem/widgets/field_list_tile.dart';

class DetallesPermiso extends StatelessWidget {
  const DetallesPermiso({
    super.key,
    this.campus,
    this.dependencias,
    this.jornada,
    this.vigencia,
    this.motivo,
  });

  final String? campus, dependencias, jornada, vigencia, motivo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldListTile(
            padding: EdgeInsets.zero,
            title: "Motivo",
            value: motivo,
          ),
          if (campus != null || dependencias != null) Container(height: 20),
          if (campus != null || dependencias != null)
            Row(
              children: [
                Expanded(
                  child: FieldListTile(
                    padding: EdgeInsets.zero,
                    title: "Campus",
                    value: campus,
                  ),
                ),
                Expanded(
                  child: FieldListTile(
                    padding: EdgeInsets.zero,
                    title: "Dependencias",
                    value: dependencias,
                  ),
                ),
              ],
            ),
          if (jornada != null || vigencia != null) Container(height: 20),
          if (jornada != null || vigencia != null)Row(
            children: [
              Expanded(
                child: FieldListTile(
                  padding: EdgeInsets.zero,
                  title: "Jornada",
                  value: jornada,
                ),
              ),
              Expanded(
                child: FieldListTile(
                  padding: EdgeInsets.zero,
                  title: "Vigencia",
                  value: vigencia,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}