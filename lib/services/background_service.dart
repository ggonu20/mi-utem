
import 'package:background_fetch/background_fetch.dart';
import 'package:get/get.dart';
import 'package:mi_utem/config/logger.dart';
import 'package:mi_utem/Domain/repositories/asignaturas_repository.dart';
import 'package:mi_utem/Domain/repositories/carreras_repository.dart';
import 'package:mi_utem/Domain/repositories/horario_repository.dart';
import 'package:mi_utem/Domain/repositories/permiso_ingreso_repository.dart';
import 'package:mi_utem/services/auth_service.dart';
import 'package:mi_utem/services/carreras_service.dart';
import 'package:mi_utem/services/grades_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

final _backgroundFetchConfig = BackgroundFetchConfig(
  minimumFetchInterval: 15,
  startOnBoot: true,
  stopOnTerminate: false,
  enableHeadless: true,
  requiresBatteryNotLow: false,
  requiresCharging: false,
  requiresStorageNotLow: false,
  requiresDeviceIdle: false,

  // Se necesita conexión a internet para funcionar.
  requiredNetworkType: NetworkType.ANY,
);

class BackgroundController {
  // [Android-only] This "Headless Task" is run when the Android app is terminated with `enableHeadless: true`
  // Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
  @pragma('vm:entry-point')
  static void backgroundFetchHeadlessTask(HeadlessTask task) async {
    String taskId = task.taskId;
    bool isTimeout = task.timeout;
    if (isTimeout) {
      BackgroundFetch.finish(taskId);
      return;
    }
    BackgroundFetch.finish(taskId);
  }
}

class BackgroundService {

  static Future<void> initAndStart() async {
    BackgroundFetch.registerHeadlessTask(BackgroundController.backgroundFetchHeadlessTask);
    await BackgroundFetch.configure(_backgroundFetchConfig, (taskId) => Sentry.metrics().timing("BackgroundFetch_$taskId",
      function: () async => await _onFetch(taskId),
      unit: DurationSentryMeasurementUnit.milliSecond,
    ), _onTimeout);

    BackgroundFetch.start().then((_) {}).catchError((e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    });
  }

  static _onFetch(String taskId) async {
    final init = DateTime.now();
    var now = init;
    logger.d("[BackgroundFetch]: Se ejecutó la tarea '$taskId' (${now.toIso8601String()})");

    // Refresca el token de autenticación
    bool loggedIn = await Get.find<AuthService>().isLoggedIn(forceRefresh: true);
    if(!loggedIn) {
      logger.d("[BackgroundFetch]: No se pudo refrescar el token de autenticación");
      BackgroundFetch.finish(taskId);
      return;
    }
    logger.d("[BackgroundFetch]: Se refrescó el token de autenticación, tomó ${DateTime.now().difference(now).inMilliseconds} ms");
    now = DateTime.now();

    // Refresca las carreras
    now = await refrescarCarreras(now);

    // Actualiza el horario
    now = await refrescarHorario(now);

    // Revisa si hubo un cambio en las notas
    now = await notificarCambiosNotas(now);

    // Actualiza los permisos de ingreso
    now = await refrescarPermisos(now);
    
    // Actualiza los datos de las asignaturas
    now = await refrescarAsignaturasYEstudiantes(now);

    logger.d("[BackgroundFetch]: Se terminó la tarea '$taskId', tomó ${DateTime.now().difference(init).inMilliseconds} ms");
  }

  static Future<DateTime> refrescarHorario(DateTime now) async {
    try {
      final carreraId = (await Get.find<CarrerasService>().getCarreras())?.id;
      if(carreraId != null) {
        await Get.find<HorarioRepository>().getHorario(carreraId, forceRefresh: true);
      }
    } catch(_){}
    logger.d("[BackgroundFetch]: Se refrescó el horario, tomó ${DateTime.now().difference(now).inMilliseconds} ms");
    now = DateTime.now();
    return now;
  }

  static Future<DateTime> refrescarAsignaturasYEstudiantes(DateTime now) async {
    try {
      final carreraId = (await Get.find<CarrerasService>().getCarreras())?.id;
      if(carreraId != null) {
        AsignaturasRepository asignaturasRepository = Get.find<AsignaturasRepository>();
        final asignaturas = await asignaturasRepository.getAsignaturas(carreraId, forceRefresh: true) ?? [];
        for(final asignatura in asignaturas) {
          await asignaturasRepository.getEstudiantesAsignatura(asignatura, forceRefresh: true);
        }
      }
    } catch(_){}
    logger.d("[BackgroundFetch]: Se refrescaron los datos de las carreras y asignaturas, tomó ${DateTime.now().difference(now).inMilliseconds} ms");
    now = DateTime.now();
    return now;
  }

  static Future<DateTime> refrescarPermisos(DateTime now) async {
    try {
      PermisoIngresoRepository permisoIngresoRepository = Get.find<PermisoIngresoRepository>();
      final permisos = await permisoIngresoRepository.getPermisos(forceRefresh: true);
      for(final permiso in permisos) {
        final id = permiso.id;
        if(id == null) continue;
        await permisoIngresoRepository.getDetallesPermiso(id, forceRefresh: true);
      }
    } catch (_){}
    logger.d("[BackgroundFetch]: Se refrescaron los permisos de ingreso, tomó ${DateTime.now().difference(now).inMilliseconds} ms");
    now = DateTime.now();
    return now;
  }

  static Future<DateTime> notificarCambiosNotas(DateTime now) async {
    await Get.find<GradesService>().lookForGradeUpdates();
    logger.d("[BackgroundFetch]: Se revisaron las notas, tomó ${DateTime.now().difference(now).inMilliseconds} ms");
    now = DateTime.now();
    return now;
  }

  static Future<DateTime> refrescarCarreras(DateTime now) async {
    await Get.find<CarrerasRepository>().getCarreras(forceRefresh: true);
    logger.d("[BackgroundFetch]: Se refrescaron las carreras, tomó ${DateTime.now().difference(now).inMilliseconds} ms");
    now = DateTime.now();
    return now;
  }

  static _onTimeout(String taskId) async {
    logger.w("Se agotó el tiempo de espera para la tarea '$taskId'");
    Sentry.captureMessage("Se agotó el tiempo de espera para la tarea '$taskId'",
      level: SentryLevel.warning,
    );
    BackgroundFetch.finish(taskId);
  }
}

