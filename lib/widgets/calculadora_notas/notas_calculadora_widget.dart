import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mi_utem/controllers/calculator_controller.dart';
import 'package:mi_utem/Domain/models/evaluacion/evaluacion.dart';
import 'package:mi_utem/services/analytics_service.dart';
import 'package:mi_utem/widgets/calculadora_notas/nota_list_item.dart';

class NotasCalculadoraWidget extends StatelessWidget {

  const NotasCalculadoraWidget({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final CalculatorController calculatorController = Get.find<CalculatorController>();

    return Obx(() => ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, idx) => NotaListItem(
        evaluacion: IEvaluacion.fromRemote(calculatorController.partialGrades[idx]),
        editable: true,
        gradeController: calculatorController.gradeTextFieldControllers[idx],
        percentageController: calculatorController.percentageTextFieldControllers[idx],
        onChanged: (evaluacion) => calculatorController.updateGradeAt(idx, evaluacion),
        onDelete: () {
          AnalyticsService.logEvent("calculator_delete_grade");
          calculatorController.removeGradeAt(idx);
        },
      ),
      itemCount: calculatorController.partialGrades.length,
    ));
  }
}
