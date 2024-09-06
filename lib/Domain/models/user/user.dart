import 'dart:convert';

import 'package:mi_utem/Domain/models/user/persona.dart';
import 'package:mi_utem/Domain/models/user/rut.dart';
import 'package:mi_utem/utils/string_utils.dart';

class User extends Persona {

  String? token;

  String? correoPersonal;
  String? correoUtem;

  String? fotoBase64;
  List<String> perfiles;

  String? nombres;
  String? apellidos;

  String? username;
  String? fotoUrl;

  get nombreDisplayCapitalizado => capitalize("${nombres?.split(' ')[0]} $apellidos");

  User({
    super.rut,
    super.nombreCompleto = "N/N",
    this.token,
    this.correoPersonal = "N/N",
    this.correoUtem,
    this.fotoBase64,
    this.perfiles = const [],
    this.nombres,
    this.apellidos,
    this.username,
    this.fotoUrl
  });

  static List<User> fromJsonList(List<dynamic>? list)  => list != null ? list.map((json) => User.fromJson(json as Map<String, dynamic>)).toList() : [];

  factory User.fromJson(Map<String, dynamic> json) => User(
    rut: json.containsKey('rut') ? Rut.fromString("${json['rut']}") : null,
    nombreCompleto: json['nombreCompleto'],
    token: json['token'],
    correoPersonal: json['correoPersonal'],
    correoUtem: json['correoUtem'],
    fotoBase64: json['fotoBase64'],
    perfiles: ((json['perfiles'] as List<dynamic>?) ?? []).map((it) => it.toString()).toList(),
    nombres: json['nombres'],
    apellidos: json['apellidos'],
    username: json['username'],
    fotoUrl: json['fotoUrl'],
  );

  Map<String, dynamic> toJson() => {
    'token': token,
    'rut': rut?.rut,
    'correoPersonal': correoPersonal,
    'correoUtem': correoUtem,
    'fotoBase64': fotoBase64,
    'perfiles': perfiles,
    'nombreCompleto': nombreCompleto,
    'nombres': nombres,
    'apellidos': apellidos,
    'username': username,
    'fotoUrl': fotoUrl
  };

  @override
  String toString() => jsonEncode(toJson());

  User copyWith({
    Rut? rut,
    String? nombreCompleto,
    String? token,
    String? correoPersonal,
    String? correoUtem,
    String? fotoBase64,
    List<String>? perfiles,
    String? nombres,
    String? apellidos,
    String? username,
    String? fotoUrl
  }) => User(
    rut: rut ?? this.rut,
    nombreCompleto: nombreCompleto ?? this.nombreCompleto,
    token: token ?? this.token,
    correoPersonal: correoPersonal ?? this.correoPersonal,
    correoUtem: correoUtem ?? this.correoUtem,
    fotoBase64: fotoBase64 ?? this.fotoBase64,
    perfiles: perfiles ?? this.perfiles,
    nombres: nombres ?? this.nombres,
    apellidos: apellidos ?? this.apellidos,
    username: username ?? this.username,
    fotoUrl: fotoUrl ?? this.fotoUrl
  );
}