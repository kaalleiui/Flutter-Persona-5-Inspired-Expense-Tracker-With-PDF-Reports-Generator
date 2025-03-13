import 'package:flutter/material.dart';
import '../../models/expense.dart';
import 'package:intl/intl.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final Function(Expense)? onDelete;

  const ExpenseList({
    Key? key, 
    required this.expenses,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return ListTile(
          title: Text(expense.description),
          subtitle: Text(DateFormat('MMM d, y').format(expense.date)),
          trailing: Text(currencyFormat.format(expense.amount)),
          onTap: onDelete != null ? () => onDelete!(expense) : null,
        );
      },
    );
  }
}
