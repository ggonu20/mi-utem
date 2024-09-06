import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mdi/mdi.dart';
import 'package:mi_utem/config/logger.dart';
import 'package:mi_utem/Domain/models/asignaturas/asignatura.dart';
import 'package:mi_utem/Domain/models/carrera.dart';
import 'package:mi_utem/Domain/models/exceptions/custom_exception.dart';
import 'package:mi_utem/Domain/models/pair.dart';
import 'package:mi_utem/Domain/repositories/asignaturas_repository.dart';
import 'package:mi_utem/Domain/repositories/grades_repository.dart';
import 'package:mi_utem/screens/calculadora_notas_screen.dart';
import 'package:mi_utem/services/carreras_service.dart';
import 'package:mi_utem/services/remote_config/remote_config.dart';
import 'package:mi_utem/widgets/asignatura/lista/lista_asignaturas.dart';
import 'package:mi_utem/widgets/asignatura/lista/sin_asignaturas_mensaje.dart';
import 'package:mi_utem/widgets/custom_app_bar.dart';
import 'package:mi_utem/widgets/loading/loading_indicator.dart';
import 'package:mi_utem/widgets/pull_to_refresh.dart';

class AsignaturasListaScreen extends StatefulWidget {

  const AsignaturasListaScreen({
    super.key,
  });

  @override
  State<AsignaturasListaScreen> createState() => _AsignaturasListaScreenState();
}

class _AsignaturasListaScreenState extends State<AsignaturasListaScreen> {

  final _asignaturasService = Get.find<AsignaturasRepository>();
  bool _forceRefresh = false;

  bool get _mostrarCalculadora => RemoteConfigService.calculadoraMostrar;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: Text("Asignaturas"),
      actions: _mostrarCalculadora ? [
        IconButton(
          icon: Icon(Mdi.calculator),
          tooltip: "Calculadora",
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => CalculadoraNotasScreen())),
        ),
      ] : [],
    ),
    body: SafeArea(child: PullToRefresh(
      onRefresh: () async => setState(() => _forceRefresh = true),
      child: FutureBuilder<Pair<Carrera?, List<Asignatura>?>>(
        future: () async {
          final carrera = await Get.find<CarrerasService>().getCarreras();
          if(carrera == null) {
            _forceRefresh = false;
            throw CustomException.custom("No pudimos cargar los datos de tu carrera.");
          }
          final asignaturas = await _asignaturasService.getAsignaturas(carrera.id, forceRefresh: _forceRefresh);
          if(asignaturas == null) {
            _forceRefresh = false;
            throw CustomException.custom("No pudimos cargar las asignaturas.");
          }
          _forceRefresh = false;
          asignaturas.forEach((asignatura) => Get.find<GradesRepository>().getGrades(carreraId: carrera.id, asignaturaId: asignatura.id));
          return Pair(carrera, asignaturas);
        }(),
        builder: (context, snapshot) {
          if(snapshot.hasError) {
            logger.e(snapshot.error);
            final error = snapshot.error is CustomException ? (snapshot.error as CustomException).message : "Ocurrió un error al obtener las asignaturas";
            return _errorWidget(error);
          }

          if(snapshot.connectionState == ConnectionState.waiting) {
            return _loadingWidget();
          }

          final datos = snapshot.data;
          final carrera = datos?.a;
          final asignaturas = datos?.b;
          if(carrera == null || asignaturas == null) {
            return _errorWidget("No encontramos asignaturas. Por favor intenta más tarde.");
          }

          return ListaAsignaturas(
            carrera: carrera,
            asignaturas: asignaturas,
          );
        },
      ),
    )),
  );

  Widget _loadingWidget() => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: LoadingIndicator.centered(),
        ),
      ],
    ),
  );

  Widget _errorWidget(String mensaje) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: SinAsignaturasMensaje(mensaje: mensaje, emoji: "\u{1F622}"),
          ),
        ),
      ],
    ),
  );
}
