import 'package:hive/hive.dart';

part 'calculation_model.g.dart';

@HiveType(typeId: 0)
class CalculationModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int amount;

  @HiveField(2)
  Map<int, int> denominations;

  @HiveField(3)
  DateTime timestamp;

  CalculationModel({
    required this.name,
    required this.amount,
    required this.denominations,
    required this.timestamp,
  });
}

