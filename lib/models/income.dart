import 'package:hive/hive.dart';

part 'income.g.dart';

@HiveType(typeId: 5)
class Income extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  double amount;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  DateTime date;
  
  Income({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
  });
} 