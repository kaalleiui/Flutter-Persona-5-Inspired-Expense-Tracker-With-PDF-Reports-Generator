// screens/report_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

import '../models/expense.dart';
import '../models/category.dart';
import '../theme/persona_theme.dart';
import '../widgets/expense_chart.dart';
import '../widgets/persona_stats_card.dart';
import '../widgets/persona_button.dart';
import '../widgets/expense_list.dart';

// Report screen that displays expense reports and allows PDF export
class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  String _timeFrame = 'Semua';
  final List<String> _timeFrames = ['Semua', 'Hari Ini', 'Mingguan', 'Bulanan'];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late NumberFormat currencyFormat;
  bool _isGeneratingPDF = false;
  
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID');
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Get expenses filtered by selected time frame
  List<Expense> _getFilteredExpenses() {
    final expenseBox = Hive.box<Expense>('expenses');
    final now = DateTime.now();
    
    if (_timeFrame == 'Hari Ini') {
      return expenseBox.values.where((expense) {
        final expenseDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
        final today = DateTime(now.year, now.month, now.day);
        return expenseDate.isAtSameMomentAs(today);
      }).toList();
    }
    if (_timeFrame == 'Mingguan') {
      final weekAgo = now.subtract(const Duration(days: 7));
      return expenseBox.values.where((expense) {
        return expense.date.isAfter(weekAgo);
      }).toList();
    }
    if (_timeFrame == 'Bulanan') {
      return expenseBox.values.where((expense) {
        return expense.date.month == now.month &&
               expense.date.year == now.year;
      }).toList();
    }
    
    return expenseBox.values.toList();
  }

  // Calculate total per category for reports
  Map<String, double> _getCategoryTotals() {
    final expenses = _getFilteredExpenses();
    final categoryBox = Hive.box<Category>('categories');
    final categoryTotals = <String, double>{};
    
    for (var expense in expenses) {
      final category = categoryBox.get(expense.categoryId);
      if (category != null) {
        categoryTotals.update(
          category.name,
          (value) => value + expense.amount,
          ifAbsent: () => expense.amount,
        );
      }
    }
    
    return categoryTotals;
  }

  // Get Indonesian time frame label for UI and reports
  String _getTimeFrameInIndonesian() {
    switch (_timeFrame) {
      case 'Hari Ini':
        return 'Harian';
      case 'Mingguan':
        return 'Mingguan';
      case 'Bulanan':
        return 'Bulanan';
      default:
        return 'Semua Data';
    }
  }

  // Generate PDF report to share
  Future<void> _generatePDF() async {
    try {
      setState(() => _isGeneratingPDF = true);
      
      final expenses = _getFilteredExpenses();
      final totalAmount = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
      final categoryTotals = _getCategoryTotals();
      final timeFrameLabel = _getTimeFrameInIndonesian();
      
      // Get additional financial data for enhanced report
      final settingsBox = Hive.box('settings');
      final double currentBalance = settingsBox.get('balance', defaultValue: 0.0);
      
      // Calculate date ranges for report
      final now = DateTime.now();
      DateTime startDate;
      
      switch (_timeFrame) {
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          // Default to all time, using the earliest expense date or 1 year ago
          startDate = expenses.isEmpty 
              ? DateTime(now.year - 1, now.month, now.day)
              : expenses.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
      }
      
      // Get chronologically sorted expenses for analysis
      final sortedExpenses = [...expenses]..sort((a, b) => a.date.compareTo(b.date));
      
      // Calculate statistics
      final dailyAverage = totalAmount / max(1, now.difference(startDate).inDays);
      final double maxExpense = expenses.isEmpty ? 0 : expenses.map((e) => e.amount).reduce(max);
      final double minExpense = expenses.isEmpty ? 0 : expenses.map((e) => e.amount).reduce(min);
      
      // Group expenses by day for trend analysis
      final dailyExpenses = <DateTime, double>{};
      for (var expense in expenses) {
        final day = DateTime(expense.date.year, expense.date.month, expense.date.day);
        dailyExpenses[day] = (dailyExpenses[day] ?? 0) + expense.amount;
      }
      
      // Extract dates with highest and lowest spending
      final highestSpendingDate = dailyExpenses.entries.isEmpty 
          ? null 
          : dailyExpenses.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      final lowestSpendingDate = dailyExpenses.entries.isEmpty 
          ? null 
          : dailyExpenses.entries.reduce((a, b) => a.value < b.value ? a : b).key;
      
      // Create PDF document
      final pdf = pw.Document();
      final font = await PdfGoogleFonts.rajdhaniMedium();
      final boldFont = await PdfGoogleFonts.rajdhaniBold();
      
      // Add a cover page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 1, color: PdfColors.grey800),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.SizedBox(height: 40),
                  pw.Text(
                    'LAPORAN KEUANGAN',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 28,
                      color: PdfColors.black,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    timeFrameLabel.toUpperCase(),
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 20,
                      color: PdfColors.red900,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 40),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      border: pw.Border.all(width: 1, color: PdfColors.red900),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'Periode Laporan:',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 14,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          '${DateFormat('dd MMMM yyyy', 'id_ID').format(startDate)} - ${DateFormat('dd MMMM yyyy', 'id_ID').format(now)}',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 14,
                          ),
                        ),
                        pw.SizedBox(height: 20),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Total Pengeluaran:',
                                  style: pw.TextStyle(
                                    font: font,
                                    fontSize: 12,
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  currencyFormat.format(totalAmount),
                                  style: pw.TextStyle(
                                    font: boldFont,
                                    fontSize: 16,
                                    color: PdfColors.red900,
                                  ),
                                ),
                              ],
                            ),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  'Saldo Saat Ini:',
                                  style: pw.TextStyle(
                                    font: font,
                                    fontSize: 12,
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  currencyFormat.format(currentBalance),
                                  style: pw.TextStyle(
                                    font: boldFont,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Dibuat pada: ',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now()),
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
      
      // Add summary page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                pw.Header(
                  level: 0,
                      child: pw.Text(
                        'RINGKASAN KEUANGAN',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 20,
                        ),
                      ),
                  ),
                  pw.SizedBox(height: 20),
                  
                  // Financial Overview Section
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 0.5, color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Penjelasan Keuangan Lu',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 16,
                          ),
                        ),
                        pw.Divider(color: PdfColors.grey300),
                        pw.SizedBox(height: 8),
                        pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                              'Total Pengeluaran:',
                    style: pw.TextStyle(
                              font: font,
                              fontSize: 12,
                    ),
                  ),
                  pw.Text(
                              currencyFormat.format(totalAmount),
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 12,
                                color: PdfColors.red900,
                    ),
                  ),
                ],
              ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Saldo Saat Ini:',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 12,
                              ),
                            ),
                            pw.Text(
                              currencyFormat.format(currentBalance),
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Pengeluaran Rata-rata/Hari:',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 12,
                              ),
                            ),
                            pw.Text(
                              currencyFormat.format(dailyAverage),
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (expenses.isNotEmpty) ...[
                          pw.SizedBox(height: 8),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Pengeluaran Tertinggi:',
                                style: pw.TextStyle(
                                  font: font,
                                  fontSize: 12,
                                ),
                              ),
                              pw.Text(
                                currencyFormat.format(maxExpense),
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 8),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Pengeluaran Terendah:',
                                style: pw.TextStyle(
                                  font: font,
                                  fontSize: 12,
                                ),
                              ),
                              pw.Text(
                                currencyFormat.format(minExpense),
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
              pw.SizedBox(height: 20),
                  
                  // Spending Analysis Section
                  if (expenses.isNotEmpty) ...[
                pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.5, color: PdfColors.grey400),
                          borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                              'Analisis Pengeluaran',
                    style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 16,
                          ),
                          ),
                          pw.Divider(color: PdfColors.grey300),
                          pw.SizedBox(height: 8),
                          if (highestSpendingDate != null) ...[
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                    pw.Text(
                                  'Hari dengan Pengeluaran Tertinggi:',
                                  style: pw.TextStyle(
                                    font: font,
                                    fontSize: 12,
                                  ),
                                ),
                    pw.Text(
                                  DateFormat('dd MMM yyyy', 'id_ID').format(highestSpendingDate),
                    style: pw.TextStyle(
                                    font: boldFont,
                                    fontSize: 12,
                                  ),
                                  ),
                              ],
                            ),
                                pw.SizedBox(height: 4),
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      'Total Pengeluaran:',
                                      style: pw.TextStyle(
                                        font: font,
                                        fontSize: 12,
                                      ),
                                    ),
                                    pw.Text(
                                      currencyFormat.format(dailyExpenses[highestSpendingDate]),
                                      style: pw.TextStyle(
                                        font: boldFont,
                                        fontSize: 12,
                                        color: PdfColors.red900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              pw.SizedBox(height: 12),
                              if (lowestSpendingDate != null && dailyExpenses[lowestSpendingDate]! > 0) ...[
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      'Hari dengan Pengeluaran Terendah:',
                                      style: pw.TextStyle(
                                        font: font,
                                        fontSize: 12,
                                      ),
                                    ),
                                    pw.Text(
                                      DateFormat('dd MMM yyyy', 'id_ID').format(lowestSpendingDate),
                                      style: pw.TextStyle(
                                        font: boldFont,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                pw.SizedBox(height: 4),
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      'Total Pengeluaran:',
                                      style: pw.TextStyle(
                                        font: font,
                                        fontSize: 12,
                                      ),
                                    ),
                                    pw.Text(
                                      currencyFormat.format(dailyExpenses[lowestSpendingDate]),
                                      style: pw.TextStyle(
                                        font: boldFont,
                                        fontSize: 12,
                                        color: PdfColors.green800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              pw.SizedBox(height: 12),
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    'Jumlah Transaksi:',
                                    style: pw.TextStyle(
                                      font: font,
                                      fontSize: 12,
                                    ),
                                  ),
                                  pw.Text(
                                    '${expenses.length}',
                                    style: pw.TextStyle(
                                      font: boldFont,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 4),
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    'Rata-Rata per Transaksi:',
                                    style: pw.TextStyle(
                                      font: font,
                                      fontSize: 12,
                                    ),
                                  ),
                                  pw.Text(
                                    currencyFormat.format(totalAmount / expenses.length),
                                    style: pw.TextStyle(
                                      font: boldFont,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      
              pw.SizedBox(height: 20),
                  
                  // Category Breakdown Section
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 0.5, color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Rincian Kategori',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 16,
                          ),
                        ),
                        pw.Divider(color: PdfColors.grey300),
                        pw.SizedBox(height: 8),
                        
                        // Create table for category breakdown
                        pw.Table(
                          border: pw.TableBorder.all(
                            color: PdfColors.grey300,
                            width: 0.5,
                          ),
                          children: [
                            // Table header
                            pw.TableRow(
                              decoration: pw.BoxDecoration(
                                color: PdfColors.grey200,
                              ),
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    'Kategori',
                                    style: pw.TextStyle(
                                      font: boldFont,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    'Jumlah',
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      font: boldFont,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    'Persentase',
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      font: boldFont,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Sort categories by total amount
                            ...categoryTotals.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                                final category = entry.value.key;
                                final amount = entry.value.value;
                                final percentage = totalAmount > 0 
                                    ? (amount / totalAmount) * 100 
                                    : 0;
                      
                                return pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        category,
                                        style: pw.TextStyle(
                                          font: font,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        currencyFormat.format(amount),
                                        textAlign: pw.TextAlign.right,
                                        style: pw.TextStyle(
                                          font: boldFont,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        textAlign: pw.TextAlign.right,
                                        style: pw.TextStyle(
                                          font: font,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList()
                              ..sort((a, b) {
                                // Get the amount text from the second column
                                final amountA = double.tryParse((a.children[1] as pw.Padding)
                                  .child.toString().replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
                                final amountB = double.tryParse((b.children[1] as pw.Padding)
                                  .child.toString().replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
                                return amountB.compareTo(amountA); // Sort in descending order
                              }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
      
      // Add transaction details page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                pw.Header(
                      level: 0,
                      child: pw.Text(
                        'DETAIL TRANSAKSI',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    
                    // If no expenses, show a message
                    if (expenses.isEmpty)
                      pw.Container(
                        padding: const pw.EdgeInsets.all(20),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey100,
                          border: pw.Border.all(width: 0.5, color: PdfColors.grey400),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'Tidak ada transaksi untuk periode ini',
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 14,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ),
                      )
                    else
                pw.Table(
                        border: pw.TableBorder.all(
                          color: PdfColors.grey400,
                          width: 0.5,
                        ),
                  children: [
                          // Table header
                    pw.TableRow(
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey200,
                            ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                                  'Tanggal',
                                  style: pw.TextStyle(
                                    font: boldFont,
                                    fontSize: 10,
                                  ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                                  'Deskripsi',
                                  style: pw.TextStyle(
                                    font: boldFont,
                                    fontSize: 10,
                                  ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                                  'Kategori',
                                  style: pw.TextStyle(
                                    font: boldFont,
                                    fontSize: 10,
                                  ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                                  'Jumlah',
                                  style: pw.TextStyle(
                                    font: boldFont,
                                    fontSize: 10,
                                  ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                      
                    // Sort expenses by date (newest first)
                    ...sortedExpenses
                      .reversed
                      .map((expense) {
                        final category = Hive.box<Category>('categories')
                            .get(expense.categoryId);
                    
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    DateFormat('dd/MM/yyyy', 'id_ID').format(expense.date),
                                    style: pw.TextStyle(
                                      font: font,
                                      fontSize: 9,
                                    ),
                                  ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    expense.description,
                                    style: pw.TextStyle(
                                      font: font,
                                      fontSize: 9,
                                    ),
                                  ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    category?.name ?? 'Tidak Ada Kategori',
                                    style: pw.TextStyle(
                                      font: font,
                                      fontSize: 9,
                                    ),
                                  ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              currencyFormat.format(expense.amount),
                                    style: pw.TextStyle(
                                      font: boldFont,
                                      fontSize: 9,
                                    ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      );
                      }).toList(),
                    ],
                  ),
                
                pw.SizedBox(height: 20),
                
                // Footer with timestamp
                pw.Footer(
                  margin: const pw.EdgeInsets.only(top: 20),
                  title: pw.Text(
                    'Dibuat pada: ${DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now())}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    
    // Share the PDF
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'laporan_keuangan.pdf');
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'PDF berhasil dibuat',
          style: GoogleFonts.rajdhani(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Gagal membuat PDF: ${e.toString()}',
          style: GoogleFonts.rajdhani(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  } finally {
    if (mounted) {
      setState(() => _isGeneratingPDF = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final expenses = _getFilteredExpenses();
    final total = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final categoryTotals = _getCategoryTotals();
    
    return Scaffold(
      backgroundColor: PersonaTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Laporan Keuangan',
          style: GoogleFonts.rajdhani(
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: PersonaTheme.primaryRed),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTimeFrameSelector(),
                            const SizedBox(height: 16.0),
                            _buildPeriodIndicator(),
                            const SizedBox(height: 24.0),
                            _buildStatsCards(expenses, total, categoryTotals),
                            const SizedBox(height: 32.0),
                            if (expenses.isNotEmpty) ...[
                              _buildExpenseChart(expenses),
                              const SizedBox(height: 32.0),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (expenses.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: ExpenseList(
                          expenses: expenses,
                          onDelete: _deleteExpense,
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildNoDataMessage(),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      sliver: SliverToBoxAdapter(
                        child: PersonaButton(
                          text: _isGeneratingPDF ? 'Generating PDF...' : 'Generate PDF Report',
                          onPressed: _isGeneratingPDF ? () {} : () => _generatePDF(),
                          icon: Icons.picture_as_pdf,
                          isLoading: _isGeneratingPDF,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
            child: Row(
              children: [
                Container(
                  height: 20,
                  width: 3,
                  decoration: BoxDecoration(
                    color: PersonaTheme.primaryRed,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Pilih Periode',
                  style: GoogleFonts.rajdhani(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: PersonaTheme.cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PersonaTheme.primaryRed.withOpacity(0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _timeFrames.map((frame) {
                final isSelected = _timeFrame == frame;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      onTap: () => setState(() => _timeFrame = frame),
                      borderRadius: BorderRadius.circular(8.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: isSelected ? PersonaTheme.primaryRed : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : PersonaTheme.primaryRed.withOpacity(0.5),
                            width: 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: PersonaTheme.primaryRed.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ] : [],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTimeFrameIcon(frame),
                              size: 18,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              frame,
                              style: GoogleFonts.rajdhani(
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.white70,
                                  letterSpacing: 1,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodIndicator() {
    final now = DateTime.now();
    DateTime startDate;
    
    if (_timeFrame == 'Hari Ini') {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (_timeFrame == 'Mingguan') {
      startDate = now.subtract(const Duration(days: 7));
    } else if (_timeFrame == 'Bulanan') {
      startDate = DateTime(now.year, now.month, 1);
    } else {
      startDate = now.subtract(const Duration(days: 30));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: PersonaTheme.cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: PersonaTheme.primaryRed.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PersonaTheme.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.date_range,
              color: PersonaTheme.primaryRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getPeriodLabel(startDate, now),
              style: GoogleFonts.rajdhani(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(List<Expense> expenses, double total, Map<String, double> categoryTotals) {
    final now = DateTime.now();
    DateTime startDate;
    
    if (_timeFrame == 'Hari Ini') {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (_timeFrame == 'Mingguan') {
      startDate = now.subtract(const Duration(days: 7));
    } else if (_timeFrame == 'Bulanan') {
      startDate = DateTime(now.year, now.month, 1);
    } else {
      startDate = now.subtract(const Duration(days: 30));
    }
    
    final daysDifference = max(1, now.difference(startDate).inDays);
    final dailyAverage = total / daysDifference;
    
    String topCategory = "Tidak Ada";
    double topCategoryAmount = 0;
    if (categoryTotals.isNotEmpty) {
      final entry = categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
      topCategory = entry.key;
      topCategoryAmount = entry.value;
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PersonaStatsCard(
                title: 'Total Pengeluaran',
                value: currencyFormat.format(total),
                icon: Icons.payments_outlined,
                isPositive: false,
                animationOrder: 0,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: PersonaStatsCard(
                title: 'Rata-rata Harian',
                value: currencyFormat.format(dailyAverage),
                icon: Icons.calendar_today,
                isPositive: true,
                animationOrder: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(
              child: PersonaStatsCard(
                title: 'Kategori Tertinggi',
                value: '$topCategory\n${currencyFormat.format(topCategoryAmount)}',
                icon: Icons.category,
                isPositive: false,
                animationOrder: 2,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: PersonaStatsCard(
                title: 'Jumlah Transaksi',
                value: '${expenses.length}\nTransaksi',
                icon: Icons.receipt_long,
                isPositive: true,
                animationOrder: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpenseChart(List<Expense> expenses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Row(
            children: [
              Container(
                height: 24,
                width: 3,
                decoration: BoxDecoration(
                  color: PersonaTheme.primaryRed,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Grafik Pengeluaran',
                style: GoogleFonts.rajdhani(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PersonaTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: PersonaTheme.primaryRed.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ExpenseChart(
            expenses: expenses,
            timeFrame: _timeFrame,
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataMessage() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: PersonaTheme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: PersonaTheme.primaryRed.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: PersonaTheme.primaryRed.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PersonaTheme.primaryRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: PersonaTheme.primaryRed,
              size: 48,
            ),
          ),
          const SizedBox(height: 24.0),
          Text(
            'Tidak ada data pengeluaran',
            style: GoogleFonts.rajdhani(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            'untuk periode yang dipilih',
            style: GoogleFonts.rajdhani(
              textStyle: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
                letterSpacing: 1,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),
          PersonaButton(
            onPressed: () => Navigator.pop(context),
            text: 'Tambah Pengeluaran Baru',
            icon: Icons.add_circle_outline,
          ),
        ],
      ),
    );
  }

  // Helper method to get appropriate icon for time frame
  IconData _getTimeFrameIcon(String timeFrame) {
    switch (timeFrame) {
      case 'Hari Ini':
        return Icons.today;
      case 'Mingguan':
        return Icons.view_week;
      case 'Bulanan':
        return Icons.calendar_month;
      default:
        return Icons.all_inclusive;
    }
  }
  
  // Helper method to get period label
  String _getPeriodLabel(DateTime startDate, DateTime endDate) {
    final dateFormat = DateFormat('d MMM yyyy', 'id_ID');
    
    if (_timeFrame == 'Hari Ini') {
      return 'Hari ini: ${dateFormat.format(startDate)}';
    } else if (_timeFrame == 'Mingguan') {
      return 'Periode: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';
    } else if (_timeFrame == 'Bulanan') {
      return 'Bulan ${DateFormat('MMMM yyyy', 'id_ID').format(startDate)}';
    } else {
      return 'Semua data pengeluaran';
    }
  }

  Future<void> _deleteExpense(Expense expense) async {
    final expenseBox = Hive.box<Expense>('expenses');
    try {
      await expenseBox.delete(expense.key);
      setState(() {}); // Refresh the UI
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pengeluaran berhasil dihapus',
            style: GoogleFonts.rajdhani(
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: PersonaTheme.primaryRed,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'BATAL',
            textColor: Colors.white,
            onPressed: () async {
              await expenseBox.put(expense.key, expense);
              setState(() {}); // Refresh the UI
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus pengeluaran: ${e.toString()}',
            style: GoogleFonts.rajdhani(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}