import 'package:mi_utem/models/permiso_ingreso.dart';

abstract class PermisoIngresoRepository {

  Future<PermisoIngreso> getDetallesPermiso(String id, { bool forceRefresh = false});
  
  Future<List<PermisoIngreso>> getPermisos({ bool forceRefresh = false });
}