import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mi_utem/models/asignaturas/asistencia.dart';
import 'package:mi_utem/models/evaluacion/grades.dart';
import 'package:mi_utem/models/user/persona.dart';
import 'package:mi_utem/models/user/rut.dart';
import 'package:mi_utem/models/user/user.dart';
import 'package:mi_utem/themes/theme.dart';
import 'package:mi_utem/utils/string_utils.dart';
import 'package:mi_utem/utils/utils.dart';

class Asignatura {
  String id;
  String nombre;
  String codigo;
  String tipoHora;
  String estado;
  String seccion;
  Persona docente;

  Asistencia? asistencia;
  Grades? grades;
  List<User>? estudiantes;
  String? tipoAsignatura;
  num? intentos;
  String? horario;
  String? sala;
  String? tipoSala;

  Asignatura({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.tipoHora,
    required this.estado,
    required this.seccion,
    required this.docente,
    this.asistencia,
    this.grades,
    this.estudiantes,
    this.tipoAsignatura,
    this.sala,
    this.horario,
    this.intentos,
    this.tipoSala,
  });

  Color get colorPorEstado {
    switch (estado) {
      case "Aprobado":
        return MainTheme.aprobadoColor;
      case "Reprobado":
        return MainTheme.reprobadoColor;
      default:
        return MainTheme.inscritoColor;
    }
  }

  factory Asignatura.fromJson(Map<String, dynamic> json) => Asignatura(
    id: json['id'],
    codigo: json['codigo'],
    nombre: capitalize(json['nombre'] ?? ''),
    tipoHora: capitalize(json['tipoHora'] ?? ''),
    estado: capitalize(json['estado'] ?? ''),
    docente: let<String, Persona?>(json['docente'], (String? docente) {
      if(docente == null) {
        return null;
      }

      final nombreCompleto = docente.split(" ").where((element) => int.tryParse(element) == null).join(" ").replaceAll("- ", "");
      final digitos = int.tryParse(docente.split(" ").where((element) => int.tryParse(element) != null).join(" ").replaceAll("-", ""));
      return Persona(
        nombreCompleto: capitalize(nombreCompleto),
        rut: digitos != null ? Rut(digitos) : null,
      );
    }) ?? Persona(nombreCompleto: "Sin Docente"),
    seccion: json['seccion'],
    grades: json['notas'] != null ? Grades.fromJson(json['notas']) : Grades(),
    estudiantes: json.containsKey("estudiantes") ? User.fromJsonList(json["estudiantes"]) : [],
    asistencia: Asistencia(asistidos: json['asistenciaAlDia']),
    tipoAsignatura: capitalize(json['tipoAsignatura'] as String? ?? ''),
    sala: capitalize(json['sala'] ?? ''),
    horario: json['horario'],
    intentos: json.containsKey('intentos') ? (json['intentos'] is num ? json['intentos'] as num? : num.tryParse(json['intentos'])) : null,
    tipoSala: capitalize(json['tipoSala'] ?? ''),
  );

  static List<Asignatura> fromJsonList(dynamic json) => json != null ? (json as List<dynamic>).map((it) => Asignatura.fromJson(it)).toList() : [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'codigo': codigo,
    'nombre': nombre,
    'tipoHora': tipoHora,
    'estado': estado,
    'docente': docente,
    'seccion': seccion,
    'estudiantes': estudiantes,
    'notas': grades?.toJson() ?? [],
    'asistencia': asistencia?.toJson() ?? {},
    'tipoAsignatura': tipoAsignatura,
    'sala': sala,
    'horario': horario,
    'intentos': intentos,
    'tipoSala': tipoSala,
  };

  @override
  String toString() => jsonEncode(toJson());

  Asignatura copyWith({
    String? id,
    String? nombre,
    String? codigo,
    String? tipoHora,
    String? estado,
    Persona? docente,
    String? seccion,
    Asistencia? asistencia,
    Grades? grades,
    List<User>? estudiantes,
    String? tipoAsignatura,
    String? sala,
    String? horario,
    num? intentos,
    String? tipoSala,
  }) => Asignatura(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    codigo: codigo ?? this.codigo,
    tipoHora: tipoHora ?? this.tipoHora,
    estado: estado ?? this.estado,
    docente: docente ?? this.docente,
    seccion: seccion ?? this.seccion,
    asistencia: asistencia ?? this.asistencia,
    grades: grades ?? this.grades,
    estudiantes: estudiantes ?? this.estudiantes,
    tipoAsignatura: tipoAsignatura ?? this.tipoAsignatura,
    sala: sala ?? this.sala,
    horario: horario ?? this.horario,
    intentos: intentos ?? this.intentos,
    tipoSala: tipoSala ?? this.tipoSala,
  );
}