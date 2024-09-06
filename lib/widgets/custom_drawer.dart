import 'dart:convert';

import 'package:badges/badges.dart' as badge;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mdi/mdi.dart';
import 'package:mi_utem/Domain/models/pair.dart';
import 'package:mi_utem/Domain/models/preferencia.dart';
import 'package:mi_utem/Domain/models/user/user.dart';
import 'package:mi_utem/screens/acerca_screen.dart';
import 'package:mi_utem/screens/asignatura/asignaturas_lista_screen.dart';
import 'package:mi_utem/screens/credencial_screen.dart';
import 'package:mi_utem/screens/horario/horario_screen.dart';
import 'package:mi_utem/screens/main_screen.dart';
import 'package:mi_utem/screens/perfil/perfil_screen.dart';
import 'package:mi_utem/services/auth_service.dart';
import 'package:mi_utem/services/remote_config/remote_config.dart';
import 'package:mi_utem/services/review_service.dart';
import 'package:mi_utem/themes/theme.dart';
import 'package:mi_utem/utils/utils.dart';
import 'package:mi_utem/widgets/profile_photo.dart';

class CustomDrawer extends StatelessWidget {


  const CustomDrawer({
    super.key,
  });

  Widget? _getRoute(String? name) {
    switch (name) {
      case "Perfil":
        return PerfilScreen();
      case "Asignaturas":
        return AsignaturasListaScreen();
      case "Horario":
        return HorarioScreen();
      case "Credencial":
        return CredencialScreen();
      // case "Docentes":
      //   return DocentesScreen();
      //   break;
      default:
        return MainScreen();
    }
  }

  List get _menu => (jsonDecode(RemoteConfigService.drawerMenu).where((e) => e['mostrar'] == true).toList()) ?? [];

  @override
  Widget build(BuildContext context) {
    final _authService = Get.find<AuthService>();

    return Drawer(
      semanticLabel: "Abrir menú",
      child: LayoutBuilder(
        builder: (context, BoxConstraints constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: constraints.copyWith(
              minHeight: constraints.maxHeight,
              maxHeight: double.infinity,
            ),
            child: FutureBuilder<Pair<String?, User?>>(
              future: () async {
                final user = await _authService.getUser();
                final apodo = await Preferencia.apodo.get();
                return Pair(apodo, user);
              }(),
              builder: (context, snapshot) {
                final pair = snapshot.data;
                String? alias = pair?.a;
                User? user = pair?.b;
                if(!snapshot.hasData || snapshot.hasError || user == null) {
                  return Container();
                }

                return IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      UserAccountsDrawerHeader(
                        accountEmail: Text(user.correoUtem ?? user.correoPersonal ?? ""),
                        accountName: Text(alias ?? user.nombreCompleto,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        currentAccountPicture: ProfilePhoto(
                          fotoUrl: user.fotoUrl,
                          iniciales: user.iniciales,
                          radius: 30,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [MainTheme.utemAzul, MainTheme.utemVerde],
                          ),
                        ),
                      ),
                      SafeArea(
                        top: false,
                        child: Column(
                          children: _menu.map((e) => ListTile(
                            leading: Icon(IconData(e["icono"]["codePoint"],
                              fontFamily: e["icono"]["fontFamily"],
                              fontPackage: e["icono"]["fontPackage"],
                            )),
                            title: Text(e["nombre"]),
                            trailing: let<bool, Widget>(e["esNuevo"], (esNuevo) => badge.Badge(
                              showBadge: esNuevo,
                              shape: badge.BadgeShape.square,
                              borderRadius: BorderRadius.circular(10),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              elevation: 0,
                              badgeContent: const Text("Nuevo",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )),
                            onTap: () => let<Widget, void>(_getRoute(e["nombre"]), (route) {
                              Navigator.push(context, MaterialPageRoute(builder: (ctx) => route));
                              ReviewService.checkAndRequestReview(context);
                            }),
                          )).toList(),
                        ),
                      ),
                      Expanded(
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Divider(height: 5),
                              ListTile(
                                leading: const Icon(Mdi.heart),
                                title: const Text("Acerca de Mi UTEM"),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (ctx) => AcercaScreen()));
                                  ReviewService.checkAndRequestReview(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Mdi.closeCircle),
                                title: const Text('Cerrar sesión'),
                                onTap: () async => await _authService.logout(context: context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
