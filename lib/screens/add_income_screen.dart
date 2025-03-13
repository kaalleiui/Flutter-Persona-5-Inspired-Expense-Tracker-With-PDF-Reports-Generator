import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/income.dart';
import '../theme/persona_theme.dart';
import '../widgets/persona_input.dart';
import '../widgets/persona_button.dart';
import '../utils/thousands_separator.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({Key? key}) : super(key: key);

  @override
  _AddIncomeScreenState createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: PersonaTheme.primaryRed,
              onPrimary: Colors.white,
              surface: PersonaTheme.cardColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitIncome() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        // Parse amount from formatted string
        final amountText = _amountController.text.replaceAll('.', '');
        final amount = double.parse(amountText);
        
        // Create new income
        final income = Income(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: amount,
          description: _descriptionController.text,
          date: _selectedDate,
        );
        
        // Save to Hive
        final box = Hive.box<Income>('income');
        box.add(income).then((_) {
          // Update balance
          final settingsBox = Hive.box('settings');
          final currentBalance = settingsBox.get('balance', defaultValue: 0.0);
          return settingsBox.put('balance', currentBalance + amount);
        }).then((_) {
          // Show success and pop
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Pendapatan berhasil disimpan',
                  style: GoogleFonts.rajdhani(),
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            Navigator.pop(context);
          }
        }).catchError((e) {
          // Show error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Gagal menyimpan pendapatan: ${e.toString()}',
                  style: GoogleFonts.rajdhani(),
                ),
                backgroundColor: Colors.red[700],
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }).whenComplete(() {
          if (mounted) {
            setState(() {
              _isSubmitting = false;
            });
          }
        });
      } catch (e) {
        // Show error for synchronous operations (parsing)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menyimpan pendapatan: ${e.toString()}',
                style: GoogleFonts.rajdhani(),
              ),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PersonaTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Tambah Pendapatan',
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PersonaInput(
              label: 'Jumlah',
              hint: 'Masukkan jumlah pendapatan',
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ThousandsSeparatorInputFormatter(),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah tidak boleh kosong';
                }
                final amount = double.tryParse(value.replaceAll('.', ''));
                if (amount == null || amount <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            PersonaInput(
              label: 'Deskripsi',
              hint: 'Masukkan deskripsi pendapatan',
              controller: _descriptionController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Deskripsi tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PersonaTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PersonaTheme.primaryRed.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tanggal',
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
                      style: GoogleFonts.rajdhani(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            PersonaButton(
              text: _isSubmitting ? 'Menyimpan...' : 'Simpan Pendapatan',
              onPressed: () {
                if (!_isSubmitting) {
                  _submitIncome();
                }
              },
              icon: Icons.save,
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
} 