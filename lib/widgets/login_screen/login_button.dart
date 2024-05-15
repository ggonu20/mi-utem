import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mi_utem/config/logger.dart';
import 'package:mi_utem/models/exceptions/custom_exception.dart';
import 'package:mi_utem/models/preferencia.dart';
import 'package:mi_utem/models/user/credential.dart';
import 'package:mi_utem/repositories/credentials_repository.dart';
import 'package:mi_utem/screens/main_screen.dart';
import 'package:mi_utem/screens/onboarding/welcome_screen.dart';
import 'package:mi_utem/services/analytics_service.dart';
import 'package:mi_utem/services/auth_service.dart';
import 'package:mi_utem/widgets/acerca/dialog/acerca_dialog.dart';
import 'package:mi_utem/widgets/dialogs/monkey_error_dialog.dart';
import 'package:mi_utem/widgets/loading/loading_dialog.dart';
import 'package:mi_utem/widgets/snackbar.dart';


class LoginButton extends StatefulWidget {

  final TextEditingController correoController;
  final TextEditingController contraseniaController;

  final GlobalKey<FormState> formKey;

  LoginButton({
    super.key,
    required this.correoController,
    required this.contraseniaController,
    required this.formKey,
  });

  @override
  _LoginButtonState createState() => _LoginButtonState();

}

class _LoginButtonState extends State<LoginButton> {

  final _authService = Get.find<AuthService>();
  final _credentialsService = Get.find<CredentialsRepository>();

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => _login(context),
    child: Text("Iniciar Sesión"),
  );

  Future<void> _login(BuildContext context) async {
    final correo = widget.correoController.text;
    final contrasenia = widget.contraseniaController.text;

    if (correo == "error@utem.cl") {
      showDialog(context: context, builder: (ctx) => MonkeyErrorDialog());
      return;
    } else if (correo == "test@utem.cl" && contrasenia == "test") {
      showTextSnackbar(context,
        title: "Error",
        message: "Usuario o contraseña incorrecta",
      );
      return;
    }

    if(widget.formKey.currentState?.validate() == false) {
      return;
    }

    showLoadingDialog(context);

    try {
      await _credentialsService.setCredentials(Credentials(
        email: correo,
        password: contrasenia,
      ));

      if(!(await _credentialsService.hasCredentials())) {
        showTextSnackbar(context,
          title: "Error",
          message: "Ha ocurrido un error al guardar tus claves. Intenta más tarde.",
        );
        return;
      }

      await _authService.login();

      final isFirstTime = await _authService.isFirstTime();
      final user = await _authService.getUser();
      if(user == null) {
        Navigator.pop(context);
        showTextSnackbar(context,
          title: "Error",
          message: "Ha ocurrido un error desconocido. Por favor intenta más tarde.",
        );
        return;
      }

      AnalyticsService.logEvent('login');
      AnalyticsService.setUser(user);

      Navigator.of(context).popUntil((route) => route.isFirst); // Esto elimina todas las pantallas anteriores
      // Y esto reemplaza la pantalla actual por la nueva, cosa de que no pueda "volver" al login a menos que cierre la sesión.
      final hasCompletedOnboarding = (await Preferencia.onboardingStep.get()) == 'complete';
      if(hasCompletedOnboarding) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen()));
        if(isFirstTime) {
          showDialog(context: context, builder: (ctx) => AcercaDialog());
        }
        return;
      }

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => WelcomeScreen()));
    } on CustomException catch (e) {
      logger.e(e);
      Navigator.pop(context);
      showTextSnackbar(context,
        title: "Error",
        message: e.message,
      );
    }  on DioError catch (e) {
      Navigator.pop(context);
      showTextSnackbar(context,
        title: "Error",
        message: (e.error as CustomException).message,
      );
    } catch (e) {
      logger.e(e);
      Navigator.pop(context);
      showTextSnackbar(context,
        title: "Error",
        message: "Ha ocurrido un error desconocido. Por favor intenta más tarde.",
      );
    }
  }
}