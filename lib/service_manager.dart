import 'package:get/get.dart';
import 'package:mi_utem/controllers/calculator_controller.dart';
import 'package:mi_utem/controllers/horario_controller.dart';
import 'package:mi_utem/repositories/asignaturas_repository.dart';
import 'package:mi_utem/repositories/auth_repository.dart';
import 'package:mi_utem/repositories/carreras_repository.dart';
import 'package:mi_utem/repositories/credentials_repository.dart';
import 'package:mi_utem/repositories/grades_repository.dart';
import 'package:mi_utem/repositories/horario_repository.dart';
import 'package:mi_utem/repositories/noticias_repository.dart';
import 'package:mi_utem/repositories/permiso_ingreso_repository.dart';
import 'package:mi_utem/services/auth_service.dart';
import 'package:mi_utem/services/carreras_service.dart';
import 'package:mi_utem/services/grades_service.dart';

Future<void> registerServices() async {
  /* Repositorios (Para conectarse a la REST Api o servicios locales) */
  Get.lazyPut(() => AuthRepository());
  Get.lazyPut(() => AsignaturasRepository());
  Get.lazyPut(() => CredentialsRepository());
  Get.lazyPut(() => CarrerasRepository());
  Get.lazyPut(() => GradesRepository());
  Get.lazyPut(() => PermisoIngresoRepository());
  Get.lazyPut(() => NoticiasRepository());
  Get.lazyPut(() => HorarioRepository());


  /* Servicios (Para procesar datos REST) */
  Get.lazyPut(() => AuthService());
  Get.lazyPut(() => CarrerasService());
  Get.lazyPut(() => GradesService());

  /* Controladores (Para procesar datos de interfaz) */
  Get.lazyPut(() => HorarioController());
  Get.lazyPut(() => CalculatorController());
}