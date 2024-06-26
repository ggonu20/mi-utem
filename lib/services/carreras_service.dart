
import 'package:get/get.dart';
import 'package:mi_utem/config/logger.dart';
import 'package:mi_utem/models/carrera.dart';
import 'package:mi_utem/repositories/carreras_repository.dart';

class CarrerasService {

  final _carrerasRepository = Get.find<CarrerasRepository>();

  List<Carrera> carreras = [];

  Carrera? selectedCarrera;

  Future<Carrera?> getCarreras({ bool forceRefresh = false }) async {
    logger.d("[CarrerasService#getCarreras]: Obteniendo carreras...");
    final _carreras = await _carrerasRepository.getCarreras(forceRefresh: forceRefresh);

    carreras.clear();
    carreras.addAll(_carreras);
    autoSelectCarreraActiva();
    return selectedCarrera;
  }

  void changeSelectedCarrera(Carrera carrera) => selectedCarrera = carrera;

  void autoSelectCarreraActiva() {
    final estados = ["Regular", "Causal de Eliminacion"]
        .reversed
        .map((e) => e.toLowerCase())
        .toList();

    carreras.sort((a,b) => estados.indexOf(b.estado!.toLowerCase()).compareTo(estados.indexOf(a.estado!.toLowerCase())));
    final carreraActiva = carreras.first;

    changeSelectedCarrera(carreraActiva);
  }

}