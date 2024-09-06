import 'dart:convert';

import 'package:get/get.dart';
import 'package:mi_utem/config/secure_storage.dart';
import 'package:mi_utem/Domain/models/asignaturas/asignatura.dart';
import 'package:mi_utem/Domain/models/carrera.dart';
import 'package:mi_utem/Domain/models/evaluacion/grades.dart';
import 'package:mi_utem/Domain/repositories/asignaturas_repository.dart';
import 'package:mi_utem/Domain/repositories/grades_repository.dart';
import 'package:mi_utem/services/auth_service.dart';
import 'package:mi_utem/services/carreras_service.dart';
import 'package:mi_utem/services/notification_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class GradesService {
  static const savedGradesPrefix = 'savedGrades_';
  static const subscribedAsignaturasPrefix = 'subscribedAsignaturas_';
  GradesRepository _gradesRepository = Get.find<GradesRepository>();

  Future<Grades?> getGrades(String carreraId, String asignaturaId, {bool forceRefresh = false, bool saveGrades = true}) async {
    final grades = await _gradesRepository.getGrades(carreraId: carreraId, asignaturaId: asignaturaId);

    if(saveGrades && grades != null) {
      await this.saveGrades(asignaturaId, grades);
    }

    return grades;
  }

  Future<void> saveGrades(String asignaturaId, Grades grades) {
    final jsonGrades = grades.toJson();
    jsonGrades['lastUpdate'] = DateTime.now().toIso8601String();
    return secureStorage.write(key: '$savedGradesPrefix$asignaturaId', value: jsonEncode(jsonGrades));
  }

  Future<Map<String, GradeChangeType>> lookForGradeUpdates() async {
    final isLoggedIn = await Get.find<AuthService>().isLoggedIn();

    if(!isLoggedIn) {
      return {};
    }

    final carrera = await Get.find<CarrerasService>().getCarreras();
    final carreraId = carrera?.id;

    if(carrera == null || carreraId == null) {
      return {};
    }

    final subscribedAsignaturasJson = await secureStorage.read(key: '$subscribedAsignaturasPrefix$carreraId');
    List<Asignatura> subscribedAsignaturas;
    if(subscribedAsignaturasJson == null) {
      subscribedAsignaturas = (await Get.find<AsignaturasRepository>().getAsignaturas(carreraId)) ?? [];
      await secureStorage.write(key: '$subscribedAsignaturasPrefix$carreraId', value: jsonEncode(subscribedAsignaturas.map((it) => it.toJson()).toList()));
    } else {
      subscribedAsignaturas = Asignatura.fromJsonList(jsonDecode(subscribedAsignaturasJson) as List<dynamic>);
    }

    final response = Map<String, GradeChangeType>();

    for(Asignatura? asignatura in subscribedAsignaturas) {
      final asignaturaId = asignatura?.id;
      if(asignatura == null || asignaturaId == null) {
        continue;
      }

      final updatedGrades = await this.getGrades(carreraId, asignaturaId, forceRefresh: true, saveGrades: false);
      if(updatedGrades == null) {
        continue;
      }

      final changeType = await this.compareGrades(asignaturaId, updatedGrades);
      await this.saveGrades(asignaturaId, updatedGrades);

      this._notifyGradeUpdate(carrera, asignatura, changeType);

      response[asignaturaId] = changeType;
    }

    return response;
  }

  Future<GradeChangeType> compareGrades(String asignaturaId, Grades grades) async {
    final prevGradesJson = await secureStorage.read(key: '$savedGradesPrefix$asignaturaId');
    if(prevGradesJson == null) {
      return GradeChangeType.noChange;
    }

    final prevGrades = Grades.fromJson(jsonDecode(prevGradesJson) as Map<String, dynamic>);
    final prevGradesLength = prevGrades.notasParciales.length;
    final currentGradesLength = grades.notasParciales.length;

    if(prevGradesLength == 0) {
      if(currentGradesLength == 0) {
        return GradeChangeType.noChange;
      }

      if(_hasAGradeWithValue(grades)) {
        return GradeChangeType.gradeSet;
      }

      return GradeChangeType.weightingsSet;
    }

    if(currentGradesLength == 0) {
      return GradeChangeType.weightingsDeleted;
    } else if(prevGradesLength != currentGradesLength) {
      return GradeChangeType.weightingsUpdated;
    } else if(_hasAWeightingDifference(prevGrades, grades)) {
      return GradeChangeType.weightingsUpdated;
    }

    return _getGradeValueChangeType(prevGrades, grades);
  }

  GradeChangeType _getGradeValueChangeType(Grades prev, Grades current) {
    final prevLength = prev.notasParciales.length;
    final currentLength = current.notasParciales.length;
    if(prevLength != currentLength) {
      Sentry.captureMessage("Asignatura $prev.id tiene un número distinto de ponderadores en la función _getGradeValueChangeType",
        level: SentryLevel.warning
      );
      return GradeChangeType.noChange;
    }

    GradeChangeType? changeType;

    for(int i = 0; i < prevLength; i++) {
      final prevValue = prev.notasParciales[i];
      final currentValue = current.notasParciales[i];
      if(prevValue.nota == currentValue.nota) {
        continue;
      }

      if(prevValue.nota == null && currentValue.nota != null) {
        Sentry.configureScope((scope) => scope.setExtra('newGrade', currentValue.nota));
        changeType = GradeChangeType.gradeSet;
      } else if(prevValue.nota != null && currentValue.nota == null) {
        changeType = changeType ?? GradeChangeType.gradeDeleted;
      } else {
        changeType = changeType ?? GradeChangeType.gradeUpdated;
      }
    }

    return changeType ?? GradeChangeType.noChange;
  }

  bool _hasAWeightingDifference(Grades pev, Grades current) {
    final prevLength = pev.notasParciales.length;
    final currentLength = current.notasParciales.length;
    if(prevLength != currentLength) {
      Sentry.captureMessage("Asignatura $pev.id tiene un número distinto de ponderadores en la función _hasAWeightingDifference",
        level: SentryLevel.warning
      );
      return false;
    }

    for(int i = 0; i < prevLength; i++) {
      final prevValue = pev.notasParciales[i];
      final currentValue = current.notasParciales[i];
      if(prevValue.porcentaje != currentValue.porcentaje) {
        return true;
      }
    }

    return false;
  }

  bool _hasAGradeWithValue(Grades asignatura) =>
      asignatura.notasParciales.any((it) => it.nota != null);

  void _notifyGradeUpdate(Carrera carrera, Asignatura asignatura, GradeChangeType changeType) {
    final name = asignatura.nombre;

    String? title;
    String? body;

    switch(changeType) {
      case GradeChangeType.gradeSet:
        title = "Tienes una nueva nota";
        body = "$name: se ha agregado una nota.";
        break;
      case GradeChangeType.gradeUpdated:
        title = "Una nota ha cambiado";
        body = "$name: se ha actualizado una nota.";
        break;
      case GradeChangeType.gradeDeleted:
        title = "Una nota se ha borrado";
        body = "$name: se ha eliminado una nota.";
        break;
      default:
        break;
    }

    if(title != null && body != null) {
      Sentry.captureMessage("Asignatura ha cambiado y notificado",
        level: SentryLevel.debug,
        withScope: (scope) {
          scope.setTag("asignaturaId", asignatura.id.toString());
          scope.setTag("asignaturaCodigo", asignatura.codigo.toString());
          scope.setTag("change", changeType.toString());
        }
      );

      NotificationService.showGradeChangeNotification(
        title: title,
        body: body,
        asignatura: asignatura,
        carrera: carrera,
      );
    } else if(changeType != GradeChangeType.noChange) {
      Sentry.captureMessage("Asignatura ha cambiado pero no notificado",
        level: SentryLevel.debug,
        withScope: (scope) {
          scope.setTag("asignaturaId", asignatura.id.toString());
          scope.setTag("asignaturaCodigo", asignatura.codigo.toString());
          scope.setTag("change", changeType.toString());
        }
      );
    }
  }

}

enum GradeChangeType {
  weightingsSet,
  weightingsUpdated,
  weightingsDeleted,
  gradeSet,
  gradeUpdated,
  gradeDeleted,
  noChange
}