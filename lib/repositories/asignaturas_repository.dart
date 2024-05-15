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

    final asignaturas = Asignatura.fromJsonList(response.data);
    for(int i = 0; i < asignaturas.length; i++) {
      final asignatura = await getNotasAsignatura(carreraId, asignaturas[i], forceRefresh: forceRefresh);
      if(asignatura != null) {
        asignaturas[i] = asignatura;
      }
    }

    return asignaturas;
  }

  /// Obtiene las notas de una asignatura
  Future<Asignatura?> getNotasAsignatura(String? carreraId, Asignatura? asignatura, { bool forceRefresh = false }) async {
    if(asignatura == null || carreraId == null) {
      return null;
    }

    final response = await authClientRequest("carreras/$carreraId/asignaturas/${asignatura.id}/notas", forceRefresh: forceRefresh);
    return Asignatura.fromJson({
      ...asignatura.toJson(),
      'notas': response.data as Map<String, dynamic>,
    });
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