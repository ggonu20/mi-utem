import 'package:flutter/material.dart';
import 'package:mi_utem/models/asignaturas/asignatura.dart';
import 'package:mi_utem/models/horario.dart';

class AsignaturaVistaPreviaModal extends StatelessWidget {
  final Asignatura asignatura;
  final BloqueHorario bloque;

  const AsignaturaVistaPreviaModal({
    super.key,
    required this.asignatura,
    required this.bloque,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Container(
      alignment: Alignment.topCenter,
      child: Card(
        margin: const EdgeInsets.all(20),
        child: ListView(
          padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: [
            GestureDetector(
              child: ListTile(
                title: Text(asignatura.nombre ?? "Sin nombre"),
                subtitle: Text(asignatura.docente?.split(" ").where((element) => int.tryParse(element) == null).join(" ").replaceAll("- ", "") ?? "Sin docente"), // Se filtran enteros, al parecer hay algunos textos que incluyen un identificador.
              ),
              onTap: () async {
                // TODO: Mostrar perfil del docente.
              },
            ),
            if (asignatura.seccion?.isNotEmpty == true) ...[
              Divider(height: 5, indent: 20, endIndent: 20),
              ListTile(
                title: Text("Sección"),
                subtitle: Text(asignatura.seccion.toString()),
              ),
            ],
            Divider(height: 5, indent: 20, endIndent: 20),
            ListTile(
              title: Text("Código Asignatura"),
              subtitle: Text(asignatura.codigo.toString()),
            ),
            Divider(height: 5, indent: 20, endIndent: 20),
            ListTile(
              title: Text("Sala"),
              subtitle: Text(bloque.sala!),
            ),
          ],
        ),
      ),
    ),
  );
}
