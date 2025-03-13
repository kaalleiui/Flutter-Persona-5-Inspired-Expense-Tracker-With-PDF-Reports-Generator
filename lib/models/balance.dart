import 'package:hive/hive.dart';

part 'balance.g.dart';

@HiveType(typeId: 2)
class Balance extends HiveObject {
  @HiveField(0)
  double amount;
  
  Balance({
    required this.amount,
  });
}