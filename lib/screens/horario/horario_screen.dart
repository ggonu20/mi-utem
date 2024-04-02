import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mi_utem/controllers/interfaces/horario_controller.dart';
import 'package:mi_utem/models/exceptions/custom_exception.dart';
import 'package:mi_utem/models/horario.dart';
import 'package:mi_utem/screens/horario/widgets/horario_main_scroller.dart';
import 'package:mi_utem/services/analytics_service.dart';
import 'package:mi_utem/services/review_service.dart';
import 'package:mi_utem/widgets/custom_app_bar.dart';
import 'package:mi_utem/widgets/custom_error_widget.dart';
import 'package:mi_utem/widgets/loading_dialog.dart';
import 'package:mi_utem/widgets/loading_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class HorarioScreen extends StatefulWidget {
  const HorarioScreen({super.key});

  @override
  State<HorarioScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends State<HorarioScreen> {

  final ScreenshotController _screenshotController = ScreenshotController();

  bool _forceRefresh = false;
  final horarioController = Get.find<HorarioController>();

  @override
  void initState() {
    ReviewService.addScreen("HorarioScreen");
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _forceRefresh = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    horarioController.init(context);
    return FutureBuilder<Horario?>(
      future: () async {
        final data = await horarioController.getHorario(forceRefresh: _forceRefresh);
        _forceRefresh = false;
        return data;
      }(),
      builder: (context, snapshot) {
        if(snapshot.hasError) {
          final error = snapshot.error is CustomException ? (snapshot.error as CustomException).message : "Ocurrió un error al cargar el horario! Por favor intenta más tarde.";
          return Scaffold(
            appBar: CustomAppBar(
              title: Text("Horario"),
            ),
            body: Center(
              child: CustomErrorWidget(
                title: "Error al cargar el horario",
                error: error,
              ),
            ),
          );
        }

        if(snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: CustomAppBar(
              title: Text("Horario"),
            ),
            body: LoadingIndicator.centeredDefault(),
          );
        }

        final horario = snapshot.data;
        if(!snapshot.hasData || horario == null) {
          return Scaffold(
            appBar: CustomAppBar(
              title: Text("Horario"),
              actions: [
                IconButton(
                  onPressed: _reloadData,
                  icon: Icon(Icons.refresh_sharp),
                  tooltip: "Forzar actualización del horario",
                )
              ],
            ),
            body: Center(
              child: CustomErrorWidget(
                title: "Error al cargar el horario",
                error: "Ocurrió un error al cargar el horario! Por favor intenta más tarde.",
              ),
            ),
          );
        }

        return Obx(() => Scaffold(
          appBar: CustomAppBar(
            title: Text("Horario"),
            actions: [
              IconButton(
                onPressed: _reloadData,
                icon: Icon(Icons.refresh_sharp),
                tooltip: "Forzar actualización del horario",
              ),
              if(!horarioController.isCenteredInCurrentPeriodAndDay.value) IconButton(
                onPressed: _moveViewportToCurrentTime,
                icon: Icon(Icons.center_focus_strong),
                tooltip: "Centrar Horario En Hora Actual",
              ),
              IconButton(
                onPressed: () => _captureAndShareScreenshot(horario),
                icon: Icon(Icons.share),
                tooltip: "Compartir Horario",
              )
            ],
          ),
          body: Screenshot(
            controller: _screenshotController,
            child: HorarioMainScroller(
              horario: horario,
            ),
          ),
        ));
      },
    );
  }

  void _moveViewportToCurrentTime() {
    AnalyticsService.logEvent("horario_move_viewport_to_current_time");
    horarioController.moveViewportToCurrentPeriodAndDay(context);
  }

  void _captureAndShareScreenshot(Horario horario) async {
    showLoadingDialog(context);
    AnalyticsService.logEvent("horario_capture_and_share_screenshot");
    final horarioScroller = HorarioMainScroller(
      horario: horario,
      showActive: false,
    );
    final image = await _screenshotController.captureFromWidget(
      horarioScroller.basicHorario,
      targetSize:
      Size(HorarioMainScroller.totalWidth, HorarioMainScroller.totalHeight),
    );

    final directory = await getApplicationDocumentsDirectory();
    final imagePath = await File('${directory.path}/horario.png').create();
    await imagePath.writeAsBytes(image);

    Navigator.pop(context);
    /// Share Plugin
    await Share.shareXFiles([XFile(imagePath.path)]);
  }

  void _reloadData() => setState(() => _forceRefresh = true);
}
