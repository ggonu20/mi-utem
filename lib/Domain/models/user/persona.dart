import 'package:mi_utem/Domain/models/user/rut.dart';
import 'package:mi_utem/utils/string_utils.dart';

class Persona {

  final String nombreCompleto;
  final Rut? rut;

  const Persona({
    required this.nombreCompleto,
    this.rut
  });

  String get nombreCompletoCapitalizado => capitalize(nombreCompleto.trim());
  String get primerNombre => nombreCompletoCapitalizado.split(' ')[0];
  String get iniciales => nombreCompletoCapitalizado.split(' ').map((it) => it[0]).join('');

  factory Persona.fromJson(Map<String, dynamic> json) => Persona(
    nombreCompleto: json['nombreCompleto'],
    rut: json.containsKey("rut") ? Rut.fromString("${json['rut']}") : null,
  );

  Map<String, dynamic> toJson() => {
    'nombreCompleto': nombreCompleto,
    'rut': rut?.rut,
  };

}