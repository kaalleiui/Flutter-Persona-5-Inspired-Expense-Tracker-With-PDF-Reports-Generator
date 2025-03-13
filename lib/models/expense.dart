import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  double amount;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  int categoryId;
  
  @HiveField(4)
  DateTime date;
  
  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.date,
  });
}
