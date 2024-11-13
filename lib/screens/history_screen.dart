import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../calculation_model.dart';
import 'main_screen.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Box<CalculationModel> calculationBox =
        Hive.box<CalculationModel>('calculations');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'History',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: calculationBox.listenable(),
        builder: (context, Box<CalculationModel> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text(
                'No calculations saved.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              final calculation = box.getAt(index);
              return _buildSlidableCalculation(
                  context, calculation!, index, box);
            },
          );
        },
      ),
    );
  }

  Widget _buildSlidableCalculation(BuildContext context,
      CalculationModel calculation, int index, Box<CalculationModel> box) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Slidable(
        key: ValueKey(index),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) =>
                  _editCalculation(calculation),
              backgroundColor: Colors.blue.withOpacity(0.2),
              foregroundColor: Colors.blue,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (context) => _shareCalculation(calculation),
              backgroundColor: Colors.green.withOpacity(0.2),
              foregroundColor: Colors.green,
              icon: Icons.share,
              label: 'Share',
            ),
            SlidableAction(
              onPressed: (context) => _deleteCalculation(context, index, box),
              backgroundColor: Colors.red.withOpacity(0.2),
              foregroundColor: Colors.red,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Container(
          color: const Color(0xFF1E1E1E),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        calculation.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${calculation.amount}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatDateTime(calculation.timestamp),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime timestamp) {
    final date = DateFormat('MMM dd, yyyy').format(timestamp);
    final time = DateFormat('hh:mm a').format(timestamp);
    return '$date\n$time';
  }

  void _editCalculation(CalculationModel calculation) async {
   Get.to(
          () => MainScreen(),
      arguments: {
        'isEditing': true,
        'calculation': calculation,
      },
    );
  }

  Future<void> _deleteCalculation(
      BuildContext context, int index, Box<CalculationModel> box) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete Calculation',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this calculation?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await box.deleteAt(index);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calculation deleted')),
        );
      }
    }
  }

  void _shareCalculation(CalculationModel calculation) {
    final shareText = '''
Calculation Details:
Name: ${calculation.name}
Amount: ₹${calculation.amount}
''';

    Share.share(shareText);
  }
}
