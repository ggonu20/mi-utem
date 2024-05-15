import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mi_utem/config/constants.dart';
import 'package:mi_utem/config/logger.dart';
import 'package:mi_utem/models/preferencia.dart';
import 'package:mi_utem/screens/login_screen/login_screen.dart';
import 'package:mi_utem/screens/main_screen.dart';
import 'package:mi_utem/screens/onboarding/welcome_screen.dart';
import 'package:mi_utem/services/analytics_service.dart';
import 'package:mi_utem/services/auth_service.dart';
import 'package:mi_utem/utils/http/http_client.dart';
import 'package:mi_utem/widgets/loading/loading_dialog.dart';
import 'package:mi_utem/widgets/snackbar.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  final _authService = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).primaryColor,
    body: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xff1d8e5c), Color(0xff06607a)],
            ),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Hero(
                  tag: 'utemLogo',
                  child: FlareActor("assets/animations/utem.flr",
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                    animation: "default",
                    callback: (String val) async {
                      showLoadingDialog(context);
                      // Revisar si tenemos conexión a internet
                      try {
                        final response = await HttpClient.httpClient.head(apiUrl);
                        if(response.statusCode != 200) {
                          Navigator.pop(context);
                          showTextSnackbar(context,
                            title: "Error al conectar con la API",
                            message: "La app funcionará en modo Offline. Revisa tu conexión a internet si quieres acceder a todas las funcionalidades.",
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 20),
                          );
                        }
                      } catch (e) {
                        logger.e("[SplashScreen]: Error al conectar con la API", e);
                        Navigator.pop(context);
                        showTextSnackbar(context,
                          title: "Error al conectar con la API",
                          message: "La app funcionará en modo Offline. Revisa tu conexión a internet si quieres acceder a todas las funcionalidades.",
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 20),
                        );
                        return;
                      }

                      final isLoggedIn = await _authService.isLoggedIn();
                      logger.d("[SplashScreen]: isLoggedIn: $isLoggedIn");
                      final user = await _authService.getUser();
                      AnalyticsService.removeUser();
                      if(isLoggedIn && user != null) {
                        AnalyticsService.setUser(user);
                      }

                      // Esto nos asegura de que el splash es la única ruta inicial, y resuelve el error de poder volver al login.
                      Navigator.popUntil(context, (route) => route.isFirst);

                      final hasCompletedOnboarding = (await Preferencia.onboardingStep.get()) == "complete";
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => isLoggedIn ? (hasCompletedOnboarding ? MainScreen() : WelcomeScreen()) : LoginScreen()));
                    },
                  ),
                ),
              ),
            ),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) => !snapshot.hasError && snapshot.hasData && snapshot.data != null ? Padding(
                padding: const EdgeInsets.all(10),
                child: Text("Versión: ${snapshot.data?.version}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ) : Container(),
            ),
          ],
        ),
      ],
    ),
  );
}
