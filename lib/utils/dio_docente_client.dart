
class DioDocenteClient {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static const String debugUrl = 'http://192.168.5.109:3100/v1';
  static const String productionUrl = 'http://docentes.inndev.studio/v1';

  static const String url = isProduction ? productionUrl : productionUrl;
}
