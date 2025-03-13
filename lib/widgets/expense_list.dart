import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/expense.dart';
import '../models/category.dart';
import '../theme/persona_theme.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final Function(Expense) onDelete;

  const ExpenseList({
    Key? key,
    required this.expenses,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PersonaTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PersonaTheme.primaryRed.withOpacity(0.3), width: 1),
          ),
          child: Center(
            child: Text(
              'Tidak ada pengeluaran',
              style: GoogleFonts.rajdhani(
                textStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final expense = expenses[index];
          final category = Hive.box<Category>('categories').get(expense.categoryId);
          final categoryColor = category != null ? Color(category.color) : PersonaTheme.primaryRed;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Dismissible(
              key: ValueKey(expense.key),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => onDelete(expense),
              child: Card(
                elevation: 4,
                shadowColor: categoryColor.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: categoryColor.withOpacity(0.3), width: 1),
                ),
                color: PersonaTheme.cardColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: categoryColor.withOpacity(0.3), width: 2),
                    ),
                    child: Icon(
                      IconData(category?.icon ?? Icons.help.codePoint,
                          fontFamily: 'MaterialIcons'),
                      color: categoryColor,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    expense.description,
                    style: GoogleFonts.rajdhani(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  subtitle: Text(
                    category?.name ?? 'Tidak Ada Kategori',
                    style: GoogleFonts.rajdhani(
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: categoryColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(expense.amount),
                        style: GoogleFonts.rajdhani(
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy', 'id_ID').format(expense.date),
                        style: GoogleFonts.rajdhani(
                          textStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: expenses.length,
      ),
    );
  }
} 