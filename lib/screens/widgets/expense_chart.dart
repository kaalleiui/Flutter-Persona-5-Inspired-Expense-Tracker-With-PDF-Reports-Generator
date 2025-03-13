import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/expense.dart';
import '../../models/category.dart';
import '../../theme/persona_theme.dart';

class ExpenseChart extends StatefulWidget {
  final List<Expense> expenses;
  final String timeFrame;

  const ExpenseChart({
    Key? key, 
    required this.expenses,
    required this.timeFrame,
  }) : super(key: key);

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> with SingleTickerProviderStateMixin {
  int touchedIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _animation;
  Box<Category>? _categoryBox;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _initHiveBox();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuart,
    );
    _animationController.forward();
  }

  Future<void> _initHiveBox() async {
    try {
      _categoryBox = Hive.box<Category>('categories');
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error initializing Hive box: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_categoryBox == null) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
      );
    }

    final categoryData = <int, Map<String, dynamic>>{};

    // Calculate totals per category
    for (var expense in widget.expenses) {
      try {
        final category = _categoryBox!.get(expense.categoryId);
        if (category != null) {
          if (!categoryData.containsKey(expense.categoryId)) {
            categoryData[expense.categoryId] = {
              'total': 0.0,
              'name': category.name,
              'color': Color(category.color),
              'icon': category.icon,
            };
          }
          categoryData[expense.categoryId]!['total'] += expense.amount;
        }
      } catch (e) {
        debugPrint('Error processing expense: $e');
      }
    }

    final totalAmount = widget.expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    final sections = <PieChartSectionData>[];
    categoryData.forEach((id, data) {
      final percentage = totalAmount > 0 ? (data['total'] / totalAmount) * 100 : 0;
      final isTouched = sections.length == touchedIndex;
      final radius = isTouched ? 85.0 : 70.0;
      
      sections.add(
        PieChartSectionData(
          value: data['total'],
          title: isTouched 
              ? '${data['name']}\n${percentage.toStringAsFixed(1)}%\n${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(data['total'])}'
              : '${percentage.toStringAsFixed(1)}%',
          color: data['color'],
          radius: radius,
          titleStyle: TextStyle(
            color: Colors.white,
            fontSize: isTouched ? 14 : 12,
            fontWeight: FontWeight.bold,
            shadows: const [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          badgeWidget: isTouched ? _buildBadge(data['name'], data['icon']) : null,
          badgePositionPercentageOffset: 1.2,
        ),
      );
    });

    return widget.expenses.isEmpty
        ? SizedBox(
            height: 200,
            child: _buildEmptyState(),
          )
        : SizedBox(
            height: 400,
            child: _buildChart(sections),
          );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade800, width: 2),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_rounded,
            color: Colors.red.shade800,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'No expenses recorded yet!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.red,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<PieChartSectionData> sections) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade800, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade900.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Expenses by Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade100,
                  shadows: [
                    Shadow(
                      color: Colors.red.shade800,
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.3,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 35,
                      sectionsSpace: 3,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      startDegreeOffset: _animation.value * 360,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(String category, int? iconData) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade800),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade900.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconData != null) Icon(
            IconData(iconData, fontFamily: 'MaterialIcons'),
            color: Colors.white,
            size: 16,
          ),
          if (iconData != null) const SizedBox(width: 4),
          Text(
            category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
