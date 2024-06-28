import 'package:mi_utem/models/evaluacion/grades.dart';
import 'package:mi_utem/utils/http/functions.dart';

class GradesRepository {

  Future<Grades?> getGrades({required String? carreraId, required String? asignaturaId, bool forceRefresh = false}) async {
    if(carreraId == null || asignaturaId == null) {
      return null;
    }

    final response = await authClientRequest("carreras/$carreraId/asignaturas/$asignaturaId/notas", forceRefresh: forceRefresh);
    return Grades.fromJson(response.data as Map<String, dynamic>);
  }
}