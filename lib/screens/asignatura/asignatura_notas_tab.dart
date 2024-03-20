import 'package:flutter/material.dart';
import 'package:mi_utem/models/asignatura.dart';
import 'package:mi_utem/models/evaluacion.dart';
import 'package:mi_utem/widgets/asignatura/notas_tab/notas_display.dart';
import 'package:mi_utem/widgets/custom_error_widget.dart';
import 'package:mi_utem/widgets/nota_list_item.dart';
import 'package:mi_utem/widgets/pull_to_refresh.dart';

class AsignaturaNotasTab extends StatefulWidget {
  final Asignatura? asignatura;

  const AsignaturaNotasTab({
    super.key,
    required this.asignatura,
  });

  @override
  State<AsignaturaNotasTab> createState() => _AsignaturaNotasTabState();
}

class _AsignaturaNotasTabState extends State<AsignaturaNotasTab> {

  @override
  Widget build(BuildContext context) => PullToRefresh(
    onRefresh: () async => setState(() {}),
    child: ListView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(10),
      children: [
        NotasDisplayWidget(
          notaFinal: widget.asignatura?.grades?.notaFinal,
          notaExamen: widget.asignatura?.grades?.notaExamen,
          notaPresentacion: widget.asignatura?.grades?.notaPresentacion,
          estado: widget.asignatura?.estado,
          colorPorEstado: widget.asignatura?.colorPorEstado,
        ),
        Card(
          child: Container(
            padding: EdgeInsets.all(20),
            child: widget.asignatura?.grades?.notasParciales.isNotEmpty == true ? ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, i) {
                REvaluacion evaluacion = widget.asignatura!.grades!.notasParciales[i];
                return NotaListItem(evaluacion: IEvaluacion.fromRemote(evaluacion));
              },
              itemCount: widget.asignatura!.grades!.notasParciales.length,
            ) : CustomErrorWidget(
              emoji: "🤔",
              title: "Parece que aún no hay notas ni ponderadores",
            ),
          ),
        ),
      ],
    ),
  );
}

