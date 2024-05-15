import 'package:mi_utem/models/permiso_ingreso.dart';
import 'package:mi_utem/utils/http/functions.dart';

class PermisoIngresoRepository {

  Future<List<PermisoIngreso>> getPermisos({ bool forceRefresh = false }) async {
    final response = await authClientRequest("permisos",
      method: "POST",
      ttl: Duration(days: 30),
      forceRefresh: forceRefresh,
    );
    return PermisoIngreso.fromJsonList(response.data as List<dynamic>?);
  }

  Future<PermisoIngreso> getDetallesPermiso(String id, { bool forceRefresh = false }) async {
    final response = await authClientRequest("permisos/$id",
      method: "POST",
      ttl: Duration(days: 30),
      forceRefresh: forceRefresh,
    );
    return PermisoIngreso.fromJson(response.data as Map<String, dynamic>?);
  }


}