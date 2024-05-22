import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:get/get.dart';
import 'package:mi_utem/models/evaluacion/evaluacion.dart';
import 'package:mi_utem/models/evaluacion/grades.dart';

class CalculatorController {

  /* Porcentaje máximo de todas las notas */
  static const maxPercentage = 100;

  /* Nota máxima */
  static const maxGrade = 7;

  /* Nota mínima para presentarse al examen */
  static const minimumGradeForExam = 2.95;

  /* Nota para pasar el ramo */
  static const passingGrade = 3.95;

  /* Porcentaje de la nota del examen */
  static const examFinalWeight = 0.4;

  /* Porcentaje de la nota de presentación */
  static const presentationFinalWeight = 1 - examFinalWeight;

  /* Notas parciales */
  RxList<IEvaluacion> partialGrades = <IEvaluacion>[].obs;

  /* Controlador de texto para los porcentajes con máscara (para autocompletar formato) */
  RxList<MaskedTextController> percentageTextFieldControllers = <MaskedTextController>[].obs;

  /* Controlador de texto para las notas con máscara (para autocompletar formato) */
  RxList<MaskedTextController> gradeTextFieldControllers = <MaskedTextController>[].obs;

  /* Nota del examen */
  Rx<double?> examGrade = Rx(null);

  /* Controlador de texto para la nota del examen con máscara (para autocompletar formato) */
  Rx<MaskedTextController> examGradeTextFieldController = MaskedTextController(mask: "0.0").obs;

  RxBool freeEditable = false.obs;

  Rx<double?> calculatedFinalGrade = Rx(null);

  Rx<double?> calculatedPresentationGrade = Rx(null);

  Rx<int> amountOfPartialGradesWithoutGrade = 0.obs;

  Rx<int> amountOfPartialGradesWithoutPercentage = 0.obs;

  RxBool hasMissingPartialGrade = false.obs;

  RxBool canTakeExam = false.obs;

  Rx<double?> minimumRequiredExamGrade = Rx(null);

  RxDouble percentageOfPartialGrades = 0.0.obs;

  RxDouble missingPercentage = 0.0.obs;

  RxBool hasMissingPercentage = false.obs;

  Rx<double?> suggestedPercentage = Rx(null);

  Rx<double?> suggestedPresentationGrade = Rx(null);

  RxDouble percentageWithoutGrade = 0.0.obs;

  RxBool hasCorrectPercentage = false.obs;

  Rx<double?> suggestedGrade = Rx(null);

  void updateWithGrades(Grades grades) {
    partialGrades.clear();
    percentageTextFieldControllers.clear();
    gradeTextFieldControllers.clear();

    for(final grade in grades.notasParciales) {
      addGrade(IEvaluacion.fromRemote(grade));
    }

    setExamGrade(grades.notaExamen);
  }

  void updateGradeAt(int index, IEvaluacion updatedGrade) {
    final grade = partialGrades[index];
    if(!(grade.editable || freeEditable.value)) {
      return;
    }

    partialGrades[index] = updatedGrade;

    _updateCalculations();
    if(hasMissingPartialGrade.value) {
      clearExamGrade();
    }
  }

  void addGrade(IEvaluacion grade) {
    partialGrades.add(grade);
    percentageTextFieldControllers.add(MaskedTextController(
      mask: "000",
      text: grade.porcentaje?.toStringAsFixed(0) ?? "",
    ));
    gradeTextFieldControllers.add(MaskedTextController(
      mask: "0.0",
      text: grade.nota?.toStringAsFixed(2) ?? "",
    ));
    _updateCalculations();
  }

  void clearGrades() {
    partialGrades.clear();
    percentageTextFieldControllers.clear();
    gradeTextFieldControllers.clear();
    _updateCalculations();
  }

  void removeGradeAt(int index) {
    final grade = partialGrades[index];
    if(!(grade.editable || freeEditable.value)) {
      return;
    }

    partialGrades.removeAt(index);
    percentageTextFieldControllers.removeAt(index);
    gradeTextFieldControllers.removeAt(index);
    _updateCalculations();
  }

  void makeEditable() {
    freeEditable.value = true;
    _updateCalculations();
  }

  void makeNonEditable() {
    freeEditable.value = false;
    _updateCalculations();
  }

  void clearExamGrade() {
    examGrade.value = null;
    examGradeTextFieldController.value.updateText("");
    _updateCalculations();
  }

  void setExamGrade(num? grade, { bool updateTextController = true }) {
    examGrade.value = grade?.toDouble();
    if(updateTextController) {
      examGradeTextFieldController.value.updateText(grade?.toStringAsFixed(2) ?? "--");
    }
    _updateCalculations();
  }

  void _updateCalculations() {
    _calculateFinalGrade();
    _calculatePresentationGrade();
    _calculateAmountOfPartialGradesWithoutGrade();
    _calculateAmountOfPartialGradesWithoutPercentage();
    _checkHasMissingPartialGrade();
    _checkCanTakeExam();
    _calculateMinimumRequiredExamGrade();
    _calculatePercentageOfPartialGrades();
    _calculateMissingPercentage();
    _checkMissingPercentage();
    _calculateSuggestedPercentage();
    _calculateSuggestedPresentationGrade();
    _calculatePercentageWithoutGrade();
    _checkCorrectPercentage();
    _calculateSuggestedGrade();
  }

  void _calculateFinalGrade() {
    _calculatePresentationGrade();
    final calculatedPresentationGrade = this.calculatedPresentationGrade.value;
    if (calculatedPresentationGrade == null) {
      calculatedFinalGrade.value = null;
      return;
    }

    final examGradeValue = examGrade.value;
    if(examGradeValue == null) {
      calculatedFinalGrade.value = calculatedPresentationGrade;
      return;
    }

    final weightedFinalGrade = calculatedPresentationGrade * presentationFinalWeight;
    final weightedExamGrade = examGradeValue * examFinalWeight;

    calculatedFinalGrade.value = weightedFinalGrade + weightedExamGrade;
  }

  void _calculatePresentationGrade() {
    double presentationGrade = 0;
    for (final partialGrade in partialGrades) {
      final weight = (partialGrade.porcentaje ?? 0) / maxPercentage;
      presentationGrade += (partialGrade.nota ?? 0) * weight;
    }

    calculatedPresentationGrade.value = presentationGrade != 0 ? presentationGrade : null;
  }

  void _calculateAmountOfPartialGradesWithoutGrade() => amountOfPartialGradesWithoutGrade.value = partialGrades
      .where((partialGrade) => partialGrade.nota == null)
      .length;

  void _calculateAmountOfPartialGradesWithoutPercentage() => amountOfPartialGradesWithoutPercentage.value = partialGrades
      .where((partialGrade) => partialGrade.porcentaje == null)
      .length;

  void _checkHasMissingPartialGrade() {
    _calculateAmountOfPartialGradesWithoutGrade();
    hasMissingPartialGrade.value = amountOfPartialGradesWithoutGrade.value > 0;
  }

  void _checkCanTakeExam() {
    _checkHasMissingPartialGrade();
    if(hasMissingPartialGrade.value) {
      canTakeExam.value = false;
      return;
    }

    _calculatePresentationGrade();
    final calculatedPresentationGrade = this.calculatedPresentationGrade.value;
    if(calculatedPresentationGrade == null) {
      canTakeExam.value = false;
      return;
    }

    canTakeExam.value = calculatedPresentationGrade >= minimumGradeForExam && calculatedPresentationGrade < passingGrade;
  }

  void _calculateMinimumRequiredExamGrade() {
    _checkCanTakeExam();
    if(!canTakeExam.value) {
      minimumRequiredExamGrade.value = null;
      return;
    }

    _calculatePresentationGrade();
    final calculatedPresentationGrade = this.calculatedPresentationGrade.value;
    if(calculatedPresentationGrade == null) {
      minimumRequiredExamGrade.value = null;
      return;
    }

    final weightedPresentationGrade = calculatedPresentationGrade * presentationFinalWeight;
    minimumRequiredExamGrade.value = (passingGrade - weightedPresentationGrade) / examFinalWeight;
  }

  void _calculatePercentageOfPartialGrades() {
    double percentage = 0;
    for (final partialGrade in partialGrades) {
      percentage += (partialGrade.porcentaje ?? 0);
    }
    percentageOfPartialGrades.value = percentage;
  }

  void _calculateMissingPercentage()  {
    _calculatePercentageOfPartialGrades();
    missingPercentage.value = maxPercentage - percentageOfPartialGrades.value;
  }

  void _checkMissingPercentage() {
    _calculateAmountOfPartialGradesWithoutPercentage();
    hasMissingPercentage.value = amountOfPartialGradesWithoutPercentage.value > 0;
  }

  void _calculateSuggestedPercentage() {
    _calculateAmountOfPartialGradesWithoutPercentage();
    _calculateMissingPercentage();
    final percentage = missingPercentage.value / amountOfPartialGradesWithoutPercentage.value;
    suggestedPercentage.value = 0 <= percentage && percentage <= maxPercentage ? percentage : null;
  }

  void _calculateSuggestedPresentationGrade() {
    _calculateSuggestedPercentage();
    double presentationGrade = 0;
    for(final partialGrade in partialGrades) {
      final weight = (partialGrade.porcentaje ?? (suggestedPercentage.value ?? 0)) / maxPercentage;
      presentationGrade += (partialGrade.nota ?? 0) * weight;
    }

    suggestedPresentationGrade.value =  0 <= presentationGrade && presentationGrade <= maxGrade ? presentationGrade : null;
  }

  void _calculatePercentageWithoutGrade() {
    _calculateSuggestedPercentage();
    double percentage = 0;
    for(final partialGrade in partialGrades) {
      if(partialGrade.nota == null) {
        percentage += (partialGrade.porcentaje ?? (suggestedPercentage.value ?? 0));
      }
    }

    percentageWithoutGrade.value = percentage;
  }

  void _checkCorrectPercentage() {
    _calculatePercentageOfPartialGrades();
    hasCorrectPercentage.value = percentageOfPartialGrades.value == maxPercentage;
  }

  void _calculateSuggestedGrade() {
    _calculatePercentageWithoutGrade();
    final percentageWithoutGrade = this.percentageWithoutGrade.value;
    if(!(hasMissingPartialGrade.value && percentageWithoutGrade > 0)) {
      suggestedGrade.value = null;
      return;
    }

    _calculateSuggestedPresentationGrade();
    final weightOfMissingGrades = percentageWithoutGrade / maxPercentage;
    final requiredGradeValue = passingGrade - (suggestedPresentationGrade.value ?? 0);
    suggestedGrade.value = requiredGradeValue / weightOfMissingGrades;
  }
}