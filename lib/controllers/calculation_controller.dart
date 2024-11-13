import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../calculation_model.dart';

class CalculationController extends GetxController with GetSingleTickerProviderStateMixin{

  late AnimationController animationController;
  late Animation<double> animation;
  RxBool isOpen = false.obs;

  @override
  void onInit() async{
    await Hive.openBox<CalculationModel>('calculations');
    calculationBox = Hive.box<CalculationModel>('calculations');
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(animationController);
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  void toggleFab() {
    isOpen.value = !isOpen.value;
    if (isOpen.value) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }
  Map denominations = {
    2000: 0.obs,
    500: 0.obs,
    200: 0.obs,
    100: 0.obs,
    50: 0.obs,
    20: 0.obs,
    10: 0.obs,
    5: 0.obs,
    2: 0.obs,
    1: 0.obs,
  }.obs;

  var totalAmount = 0.obs;

  Box<CalculationModel>? calculationBox;

  // @override
  // void onInit() async {
  //   await Hive.openBox<CalculationModel>('calculations');
  //   calculationBox = Hive.box<CalculationModel>('calculations');
  //   super.onInit();
  // }

  void calculateTotal() {
    totalAmount.value = denominations.entries
        .map((entry) => entry.key * entry.value.value)
        .reduce((sum, value) => sum + value);
  }

  Future<void> saveCalculation(String name) async {
    if (calculationBox != null) {
      final calculation = CalculationModel(name: name, amount: totalAmount.value, denominations: denominations.map((key, value) => MapEntry(key, value.value)), timestamp: DateTime.now());
      await calculationBox!.add(calculation);
      clearDenominations();
      Get.back();
    }
  }

  void loadCalculation(CalculationModel calculation) {
    // Populate denominations from the provided calculation
    for (var key in calculation.denominations.keys) {
      denominations[key]?.value = calculation.denominations[key] ?? 0;
    }
    totalAmount.value = calculation.amount;
  }

  Future<void> updateCalculation(CalculationModel calculation, String name) async {
    if (calculationBox != null) {
      calculation.name = name;
      calculation.amount = totalAmount.value;
      calculation.denominations = denominations.map((key, value) => MapEntry(key, value.value));
      calculation.timestamp = DateTime.now();
      await calculation.save();
      clearDenominations();
      Get.back();
    }
  }

  void clearDenominations() {
    // Reset each denomination to 0
    for (var key in denominations.keys) {
      denominations[key]?.value = 0;
    }
    // Recalculate the total amount after clearing
    calculateTotal();
  }

}
