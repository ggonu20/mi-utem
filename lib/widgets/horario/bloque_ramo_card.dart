import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mi_utem/models/horario.dart';
import 'package:mi_utem/repositories/interfaces/asignaturas_repository.dart';
import 'package:mi_utem/screens/asignatura/asignatura_detalle_screen.dart';
import 'package:mi_utem/services/analytics_service.dart';
import 'package:mi_utem/services/interfaces/carreras_service.dart';
import 'package:mi_utem/widgets/horario/bloque_clase.dart';
import 'package:mi_utem/widgets/horario/bloque_vacio.dart';
import 'package:mi_utem/widgets/horario/modals/asignatura_vista_previa_modal.dart';

class ClassBlockCard extends StatelessWidget {
  final BloqueHorario? block;
  final double width;
  final double height;
  final double internalMargin;
  final Color textColor;

  ClassBlockCard({
    super.key,
    required this.block,
    required this.width,
    required this.height,
    this.internalMargin = 0,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: width,
    child: Padding(
      padding: EdgeInsets.all(internalMargin),
      child: block?.asignatura == null ? BloqueVacio() : BloqueClase(
        block: block!,
        width: width,
        height: height,
        textColor: textColor,
        onTap: (block) => _onTap(block, context),
        onLongPress: (block) => _onLongPress(block, context),
      ),
    ),
  );

  _onTap(BloqueHorario block, BuildContext context) async {
    final asignatura = (await Get.find<AsignaturasRepository>().getAsignaturas((Get.find<CarrerasService>().selectedCarrera)?.id))?.firstWhereOrNull((asignatura) => asignatura.id == block.asignatura?.id || asignatura.codigo == block.asignatura?.codigo);
    if(asignatura == null) return;
    AnalyticsService.logEvent(
      "horario_class_block_tap",
      parameters: {
        "asignatura": asignatura.nombre,
        "codigo": asignatura.codigo,
      },
    );

    Navigator.push(context, MaterialPageRoute(builder: (ctx) => AsignaturaDetalleScreen(asignatura: asignatura)));
  }

  _onLongPress(BloqueHorario block, BuildContext context) async {
    final asignatura = (await Get.find<AsignaturasRepository>().getAsignaturas((Get.find<CarrerasService>().selectedCarrera)?.id))?.firstWhereOrNull((asignatura) => asignatura.id == block.asignatura?.id || asignatura.codigo == block.asignatura?.codigo);
    if(asignatura == null) return;
    AnalyticsService.logEvent(
      "horario_class_block_long_press",
      parameters: {
        "asignatura": block.asignatura?.nombre,
        "codigo": block.asignatura?.codigo,
      },
    );

    showModalBottomSheet(context: context, builder: (ctx) => AsignaturaVistaPreviaModal(asignatura: asignatura, bloque: block));
  }
}
