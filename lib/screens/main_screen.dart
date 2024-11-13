import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/calculation_controller.dart';
import '../calculation_model.dart';

class MainScreen extends StatelessWidget {
  final CalculationController controller = Get.put(CalculationController());
  final double _fabHeight = 56.0;

  MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if we're in edit mode
    final args = Get.arguments as Map?;
    final bool isEditing = args?['isEditing'] ?? false;
    final CalculationModel? calculation = args?['calculation'];

    // Initialize the controller with the existing data if editing
    if (isEditing && calculation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final calculation = Get.arguments['calculation'] as CalculationModel;
        controller.loadCalculation(calculation);
      });

    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Calculation' : 'Denomination Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Get.toNamed('/history'),
          ),
        ],
      ),
      body: Column(
        children: [
          Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              Container(
                  width: double.infinity,
                  height: 150,
                  child: Image.asset(
                    "assets/images/currency_banner.jpg",
                    fit: BoxFit.cover,
                  )),
              Obx(() => Text(
                'Total Amount: ₹${controller.totalAmount.value}',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              )),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ...controller.denominations.keys.map((denomination) {
                      return Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('₹$denomination'),
                          ),
                          Expanded(
                            child: Text('X'),
                          ),
                          Expanded(
                            child: Obx(
                                  () {
                                // Creating a controller for this specific TextField
                                final textController = TextEditingController(
                                  text: controller
                                      .denominations[denomination]?.value
                                      .toString(),
                                );

                                // Update the selection to keep the cursor at the end
                                textController.selection =
                                    TextSelection.fromPosition(
                                      TextPosition(
                                        offset: textController.text.length,
                                      ),
                                    );

                                return TextField(
                                  keyboardType: TextInputType.number,
                                  controller: textController,
                                  onChanged: (val) {
                                    controller.denominations[denomination]
                                        ?.value = int.tryParse(val) ?? 0;
                                    controller.calculateTotal();
                                  },
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    border: OutlineInputBorder(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Obx(() => Text(
                                '= ₹${denomination * controller.denominations[denomination]!.value}')),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            height: controller.isOpen.value ? _fabHeight : 0,
            child: Opacity(
              opacity: controller.isOpen.value ? 1.0 : 0.0,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton(
                  heroTag: 'save',
                  onPressed: () {
                    _showSaveDialog(context, isEditing, calculation);
                  },
                  child: Icon(Icons.save),
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            height: controller.isOpen.value ? _fabHeight : 0,
            child: Opacity(
              opacity: controller.isOpen.value ? 1.0 : 0.0,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton(
                  heroTag: 'clear',
                  onPressed: () {
                    controller.clearDenominations();
                  },
                  child: Text('Clear'),
                ),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: controller.toggleFab,
            child: Icon(Icons.bolt),
          ),
        ],
      )),
    );
  }

  void _showSaveDialog(BuildContext context, bool isEditing, CalculationModel? calculation) {
    final nameController = TextEditingController(text: calculation?.name ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Update Calculation' : 'Save Calculation'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name of Calculation'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                if (isEditing && calculation != null) {
                  controller.updateCalculation(calculation, nameController.text);
                } else {
                  controller.saveCalculation(nameController.text);
                }
                Navigator.of(context).pop();
              }
            },
            child: Text(isEditing ? 'Update' : 'Save'),
          ),
        ],
      ),
    );
  }
}
