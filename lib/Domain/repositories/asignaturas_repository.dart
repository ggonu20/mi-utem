import 'package:mi_utem/Domain/models/asignaturas/asignatura.dart';
import 'package:mi_utem/Domain/models/user/user.dart';
import 'package:mi_utem/utils/http/functions.dart';
import 'package:mi_utem/utils/utils.dart';

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

    final estudiantes = (json['estudiantes'] as List<dynamic>).map((it) {
      it['nombreCompleto'] = (it['nombreCompleto'] as String).split(" ").rotate(2).join(" ");
      return it;
    }).toList();

    return User.fromJsonList(estudiantes);
  }


}