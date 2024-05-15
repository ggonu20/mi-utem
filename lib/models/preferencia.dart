import 'package:mi_utem/config/secure_storage.dart';

enum Preferencia {
  apodo,
  lastLogin,
  onboardingStep,
  ;

  /// Revisa si la preferencia existe
  Future<bool> exists() async => await secureStorage.containsKey(key: this.name);

  /// Obtiene la preferencia del storage, pero si no existe retorna el valor por defecto
  /// Si [guardar] es verdadero, entonces si no existe la preferencia, se guardará el valor por defecto
  Future<String?> get({ String? defaultValue, bool guardar = false }) async {
    if(defaultValue != null) {
      await add(defaultValue);
    }
    return await secureStorage.read(key: this.name) ?? defaultValue;
  }

  /// Guarda la preferencia en el storage
  set(String value) async => await secureStorage.write(key: this.name, value: value);

  /// Guarda la preferencia en el storage solo si no existe
  /// Si la preferencia ya existe, no se guardará nada
  add(String value) async {
    if (!(await exists())) {
      await set(value);
    }
  }

  /// Elimina la preferencia del storage
  delete() async => await secureStorage.delete(key: this.name);

}