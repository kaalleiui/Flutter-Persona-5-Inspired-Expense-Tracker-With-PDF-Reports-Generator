import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/expense.dart';
import '../models/category.dart';
import '../theme/persona_theme.dart';

// Chart widget that displays expenses grouped by category
class ExpenseChart extends StatefulWidget {
  final List<Expense> expenses;
  final String timeFrame;

  const ExpenseChart({
    Key? key,
    required this.expenses,
    required this.timeFrame,
  }) : super(key: key);

  @override
  _ExpenseChartState createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  // Initialize chart animation
  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuart,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryBox = Hive.box<Category>('categories');
    final categoryData = <int, Map<String, dynamic>>{};

    // Calculate totals per category
    for (var expense in widget.expenses) {
      final category = categoryBox.get(expense.categoryId);
      if (category != null) {
        if (!categoryData.containsKey(expense.categoryId)) {
          categoryData[expense.categoryId] = {
            'total': 0.0,
            'name': category.name,
            'color': Color(category.color),
          };
        }
        categoryData[expense.categoryId]!['total'] += expense.amount;
      }
    }

    // Calculate grand total
    final totalAmount = widget.expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    return widget.expenses.isEmpty
        ? _buildEmptyState()
        : _buildBarChart(categoryData, totalAmount);
  }

  // Build bar chart showing expense categories
  Widget _buildBarChart(Map<int, Map<String, dynamic>> categoryData, double totalAmount) {
    // Sort categories by total amount (descending)
    final sortedCategories = categoryData.entries.toList()
      ..sort((a, b) => b.value['total'].compareTo(a.value['total']));

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(221, 45, 8, 8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PersonaTheme.primaryRed, width: 1), // Reduced border width
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2), // Reduced shadow opacity
                blurRadius: 6, // Reduced blur
                spreadRadius: 1, // Reduced spread
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chart title
                Text(
                  'Tingkat Keborosan',
                  style: GoogleFonts.rajdhani(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color.fromARGB(255, 255, 255, 255),
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Color.fromARGB(255, 253, 10, 10),
                          blurRadius: 10, // Reduced blur for better readability
                          offset: Offset(1, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isSmallScreen = screenWidth < 600;
                    
                    return Column(
                      children: [
                        // Bar chart visualization
                        SizedBox(
                          height: isSmallScreen ? 220 : 300,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0, left: 8.0, top: 16, bottom: 8),
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: sortedCategories.isNotEmpty 
                                    ? sortedCategories.first.value['total'] * 1.2 
                                    : 100,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBgColor: const Color.fromARGB(221, 255, 31, 31),
                                    tooltipRoundedRadius: 8,
                                    tooltipBorder: BorderSide(color: const Color.fromARGB(255, 255, 255, 255)),
                                    tooltipPadding: const EdgeInsets.all(5),
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      final category = sortedCategories[groupIndex].value;
                                      final amount = category['total'];
                                      final percentage = totalAmount > 0 
                                          ? (amount / totalAmount) * 100 
                                          : 0;
                                      
                                      return BarTooltipItem(
                                        '${category['name']}\n',
                                        GoogleFonts.rajdhani(
                                          textStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '${NumberFormat.compact().format(amount)}\n',
                                            style: GoogleFonts.rajdhani(
                                              textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${percentage.toStringAsFixed(1)}%',
                                            style: GoogleFonts.rajdhani(
                                              textStyle: TextStyle(
                                                color: const Color.fromARGB(255, 255, 255, 255),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          barTouchResponse == null ||
                                          barTouchResponse.spot == null) {
                                        touchedIndex = -1;
                                        return;
                                      }
                                      touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                                    });
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        if (value >= sortedCategories.length || value < 0) {
                                          return const SizedBox.shrink();
                                        }
                                        
                                        final category = sortedCategories[value.toInt()].value;
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            category['name'].toString().substring(0, min(3, category['name'].toString().length)),
                                            style: GoogleFonts.rajdhani(
                                              textStyle: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: false,
                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: const Color.fromARGB(210, 193, 1, 1),
                                      strokeWidth: 0.5,
                                      dashArray: [5, 3],
                                    );
                                  },
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                // Generate bar groups from expense data
                                barGroups: List.generate(
                                  sortedCategories.length,
                                  (index) {
                                    final category = sortedCategories[index].value;
                                    final isSelected = index == touchedIndex;
                                    
                                    return BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: category['total'] * _animation.value,
                                          color: category['color'],
                                          width: isSelected ? 22 : 13,
                                          borderRadius: BorderRadius.circular(9),
                                          backDrawRodData: BackgroundBarChartRodData(
                                            show: true,
                                            toY: sortedCategories.first.value['total'] * 1.1,
                                            color: const Color.fromARGB(169, 25, 13, 13),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Category legend with percentage breakdown
                        if (categoryData.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: PersonaTheme.primaryRed.withOpacity(0.4)), // Reduced opacity
                            ),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: sortedCategories.map((entry) {
                                final data = entry.value;
                                final percentage = widget.expenses.isEmpty ? 0.0 :
                                  (data['total'] / widget.expenses.fold(
                                    0.0,
                                    (sum, expense) => sum + expense.amount
                                  )) * 100;
                                
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: data['color'], width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: data['color'],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        data['name'],
                                        style: GoogleFonts.rajdhani(
                                          textStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: GoogleFonts.rajdhani(
                                          textStyle: TextStyle(
                                            color: data['color'],
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build empty state when no expenses exist
  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PersonaTheme.primaryRed, width: 1), // Reduced border width
        boxShadow: [
          BoxShadow(
            color: PersonaTheme.primaryRed.withOpacity(0.2), // Reduced shadow opacity
            blurRadius: 6, // Reduced blur
            spreadRadius: 1, // Reduced spread
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BELUM ADA PENGELUARAN',
              style: GoogleFonts.rajdhani(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.red,
                      blurRadius: 2, // Reduced blur for better readability
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = MediaQuery.of(context).size.height;
                final contentHeight = min(screenHeight * 0.3, 200.0);
                
                return SizedBox(
                  height: contentHeight,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: PersonaTheme.primaryRed,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tambahkan pengeluaran untuk melihat seberapa boros loe',
                          style: GoogleFonts.rajdhani(
                            textStyle: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 