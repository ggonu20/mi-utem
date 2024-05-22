import 'package:mi_utem/models/asignaturas/asignatura.dart';
import 'package:mi_utem/models/user/user.dart';
import 'package:mi_utem/utils/http/functions.dart';

class AsignaturasRepository {

  /// Obtiene las asignaturas de una carrera
  Future<List<Asignatura>?> getAsignaturas(String? carreraId, {bool forceRefresh = false}) async {
    if(carreraId == null) {
      return null;
    }

    final response = await authClientRequest("carreras/$carreraId/asignaturas", forceRefresh: forceRefresh);
    return Asignatura.fromJsonList(response.data);
  }

  /// Obtiene los estudiantes de una asignatura
  Future<List<User>?> getEstudiantesAsignatura(Asignatura? asignatura, {bool forceRefresh = false}) async {
    if(asignatura == null) {
      return null;
    }

    final response = await authClientRequest("asignaturas/${asignatura.codigo}", forceRefresh: forceRefresh);
    final json = response.data as Map<String, dynamic>;

    // Por ahora solo se actualizan los estudiantes
    return User.fromJsonList(json['estudiantes']);
  }


}