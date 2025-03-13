import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';
import '../theme/persona_theme.dart';
import '../widgets/expense_chart.dart';
import '../widgets/expense_list.dart';
import '../widgets/persona_button.dart';
import '../widgets/persona_input.dart';
import '../widgets/persona_stats_card.dart';
import '../widgets/persona_toggle.dart';
import '../utils/thousands_separator.dart';
import 'add_expense_screen.dart';
import 'add_income_screen.dart';
import 'confidant_screen.dart';
import 'report_screen.dart';

// Main home screen that displays the dashboard with balance, expense chart and list
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Time frame filter options for expenses
  String _selectedTimeFrame = 'Semua';
  final List<String> _timeFrames = ['Semua', 'Hari Ini', 'Mingguan', 'Bulanan'];
  final _settingsBox = Hive.box('settings');
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    // Initialize animations for negative balance warning effect
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Set initial timeframe to "Semua"
    _selectedTimeFrame = _timeFrames[0];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // Get current balance from Hive storage
  double get balance {
    return _settingsBox.get('balance', defaultValue: 0.0);
  }

  // Filter expenses based on selected time frame
  List<Expense> _filterExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    switch (_selectedTimeFrame) {
      case 'Hari Ini':
        return expenses.where((expense) {
          return expense.date.year == now.year &&
              expense.date.month == now.month &&
              expense.date.day == now.day;
        }).toList();
      case 'Minggu':
        final weekAgo = now.subtract(const Duration(days: 7));
        return expenses.where((expense) => expense.date.isAfter(weekAgo)).toList();
      case 'Bulan':
        return expenses.where((expense) {
          return expense.date.year == now.year &&
              expense.date.month == now.month;
        }).toList();
      default:
        return expenses;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'HITUNG KEBOROSAN',
          style: GoogleFonts.rajdhani(
            textStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: PersonaTheme.primaryRed.withOpacity(0.5),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf, size: 24),
            color: Colors.white70,
            onPressed: () => _navigateToScreen(ReportScreen()),
          ),
          IconButton(
            icon: Icon(Icons.people, size: 24),
            color: Colors.white70,
            onPressed: () => _navigateToScreen(ConfidantScreen()),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('settings').listenable(),
        builder: (context, Box settingsBox, _) {
          return ValueListenableBuilder(
            valueListenable: Hive.box<Expense>('expenses').listenable(),
            builder: (context, Box<Expense> expenseBox, _) {
              final expenses = _filterExpenses(expenseBox.values.toList());
              final currentBalance = balance;
              final isNegative = currentBalance < 0;
              
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          // Balance Card
                          _buildBalanceCard(currentBalance, isNegative),
                          SizedBox(height: 24),
                          // Time Frame Filter
                          _buildTimeFrameFilter(),
                          SizedBox(height: 24),
                          // Add Expense Button
                          _buildAddExpenseButton(),
                          SizedBox(height: 24),
                          // Expense Chart
                          _buildExpenseChart(expenses),
                          SizedBox(height: 24),
                          // Expense List Header
                          _buildExpenseListHeader(),
                        ],
                      ),
                    ),
                  ),
                  // Expense List
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: ExpenseList(
                      expenses: expenses,
                      onDelete: _handleDeleteExpense,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(double currentBalance, bool isNegative) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: PersonaTheme.primaryRed.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SALDO SAAT INI',
                  style: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, size: 20),
                  color: Colors.white70,
                  onPressed: _updateBalance,
                ),
              ],
            ),
            SizedBox(height: 8),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Text(
                NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp',
                  decimalDigits: 0,
                ).format(currentBalance),
                key: ValueKey<double>(currentBalance),
                style: GoogleFonts.rajdhani(
                  textStyle: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: isNegative ? PersonaTheme.primaryRed : Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFrameFilter() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _timeFrames.length,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          final timeFrame = _timeFrames[index];
          final isSelected = timeFrame == _selectedTimeFrame;
          return ChoiceChip(
            label: Text(timeFrame.toUpperCase(),
                style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                )),
            selected: isSelected,
            onSelected: (selected) => setState(() => _selectedTimeFrame = timeFrame),
            backgroundColor: Colors.transparent,
            selectedColor: PersonaTheme.primaryRed,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
            ),
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected ? Colors.transparent : Colors.grey[700]!,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddExpenseButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.remove_circle_outline, size: 24),
      label: Text('TAMBAH PENGELUARAN',
          style: GoogleFonts.rajdhani(
              fontWeight: FontWeight.w700, letterSpacing: 1)),
      style: ElevatedButton.styleFrom(
        backgroundColor: PersonaTheme.primaryRed,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        shadowColor: PersonaTheme.primaryRed.withOpacity(0.3),
      ),
      onPressed: () => _navigateToScreen(const AddExpenseScreen()),
    );
  }

  Widget _buildExpenseChart(List<Expense> expenses) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpenseChart(
              expenses: expenses,
              timeFrame: _selectedTimeFrame,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseListHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: PersonaTheme.primaryRed,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'DAFTAR PENGELUARAN',
            style: GoogleFonts.rajdhani(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) => screen,
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  // Update balance dialog
  void _updateBalance() {
    final TextEditingController controller = TextEditingController(
      text: balance.toString(),
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'UPDATE SALDO',
          style: GoogleFonts.rajdhani(
            textStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo Saat Ini: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(balance)}',
              style: GoogleFonts.rajdhani(
                textStyle: TextStyle(
                  color: const Color.fromARGB(247, 255, 255, 255),
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Tambah Saldo',
                labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: PersonaTheme.primaryRed),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                ThousandsSeparatorInputFormatter(),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              'BATAL',
              style: GoogleFonts.rajdhani(
                textStyle: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PersonaTheme.primaryRed,
            ),
            child: Text(
              'TAMBAH',
              style: GoogleFonts.rajdhani(
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onPressed: () {
              final additionalAmount = double.tryParse(
                controller.text.replaceAll('.', ''),
              );
              if (additionalAmount != null) {
                final currentBalance = _settingsBox.get('balance', defaultValue: 0.0);
                _settingsBox.put('balance', currentBalance + additionalAmount);
                Navigator.of(context).pop();
                setState(() {}); // Trigger rebuild to update balance display
              }
            },
          ),
        ],
      ),
    );
  }

  // Handle expense deletion
  void _handleDeleteExpense(Expense expense) {
    final box = Hive.box<Expense>('expenses');
    
    // Find the key for this expense
    final key = box.keys.firstWhere(
      (k) => box.get(k)?.id == expense.id,
      orElse: () => -1,
    );
    
    if (key != -1) {
      box.delete(key);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pengeluaran dihapus',
            style: GoogleFonts.rajdhani(),
          ),
          backgroundColor: PersonaTheme.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}

// Input formatter for adding thousands separators to currency input
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    
    final cleanText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final parsedValue = int.tryParse(cleanText) ?? 0;
    final formattedText = NumberFormat.decimalPattern('id').format(parsedValue);
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
} 