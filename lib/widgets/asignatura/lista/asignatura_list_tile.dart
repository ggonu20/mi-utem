import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mi_utem/models/asignaturas/asignatura.dart';
import 'package:mi_utem/models/carrera.dart';
import 'package:mi_utem/repositories/grades_repository.dart';
import 'package:mi_utem/screens/asignatura/asignatura_detalle_screen.dart';
import 'package:mi_utem/themes/theme.dart';

class AsignaturaListTile extends StatefulWidget {
  final Carrera carrera;
  final Asignatura asignatura;

  const AsignaturaListTile({
    super.key,
    required this.carrera,
    required this.asignatura,
  });

  @override
  State<AsignaturaListTile> createState() => _AsignaturaListTileState();
}

class _AsignaturaListTileState extends State<AsignaturaListTile> {
  late Asignatura asignatura;

  @override
  void initState() {
    asignatura = widget.asignatura;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: Card(
      child: InkWell(
        onTap: () async {
          final grades = await Get.find<GradesRepository>().getGrades(carreraId: widget.carrera.id, asignaturaId: asignatura.id);
          setState(() => asignatura = asignatura.copyWith(grades: grades));

          Navigator.push(context, MaterialPageRoute(builder: (ctx) => AsignaturaDetalleScreen(
            carrera: widget.carrera,
            asignatura: asignatura,
          )));
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${asignatura.nombre}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: MainTheme.theme.textTheme.titleMedium,
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${asignatura.codigo}"),
                  Text("${asignatura.tipoHora}"),
                ],
              )
            ],
          ),
        ),
      ),
    ),
  );
}
