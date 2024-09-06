import 'package:mi_utem/Domain/models/horario.dart';
import 'package:mi_utem/utils/http/functions.dart';

class HorarioRepository {

  Future<Horario?> getHorario(String carreraId, {bool forceRefresh = false}) async {
    final response = await authClientRequest("carreras/$carreraId/horarios",
      ttl: const Duration(days: 14),
      forceRefresh: forceRefresh,
    );
    return Horario.fromJson(response.data);
  }
}
