// screens/add_expense_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/expense.dart';
import '../models/category.dart';
import '../theme/persona_theme.dart';
import '../widgets/persona_card.dart';
import '../widgets/persona_button.dart';
import '../widgets/persona_input.dart';
import '../widgets/category_chip.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> 
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _formValidNotifier = ValueNotifier<bool>(false);
  
  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;
  bool _isSubmitting = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupFormListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) => _amountFocusNode.requestFocus());
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();
  }

  void _setupFormListeners() {
    // Update form validity when inputs change
    void updateFormValidity() {
      final amountValid = _amountController.text.isNotEmpty;
      final descriptionValid = _descriptionController.text.isNotEmpty;
      final categoryValid = _selectedCategory != null;
      
      _formValidNotifier.value = amountValid && descriptionValid && categoryValid;
    }
    
    _amountController.addListener(updateFormValidity);
    _descriptionController.addListener(updateFormValidity);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _formValidNotifier.dispose();
    super.dispose();
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
          'TAMBAH PENGELUARAN',
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
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAmountField(),
                      const SizedBox(height: 24),
                      _buildDescriptionField(),
                      const SizedBox(height: 24),
                      _buildDatePicker(),
                      const SizedBox(height: 24),
                      _buildCategorySelector(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'JUMLAH',
          style: GoogleFonts.rajdhani(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          focusNode: _amountFocusNode,
          style: GoogleFonts.rajdhani(
            textStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          decoration: InputDecoration(
            hintText: 'Rp 0',
            hintStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
            prefixText: 'Rp ',
            prefixStyle: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.w800
              ),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            ThousandsSeparatorInputFormatter(),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Jumlah tidak boleh kosong';
            }
            return null;
          },
          onFieldSubmitted: (_) => _descriptionFocusNode.requestFocus(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DESKRIPSI',
          style: GoogleFonts.rajdhani(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          focusNode: _descriptionFocusNode,
          style: GoogleFonts.rajdhani(
            textStyle: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          decoration: InputDecoration(
            hintText: 'buat apaaan aja?',
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Deskripsi tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TANGGAL',
          style: GoogleFonts.rajdhani(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
                  style: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today, color: Colors.white70, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KATEGORI',
          style: GoogleFonts.rajdhani(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          child: ValueListenableBuilder(
            valueListenable: Hive.box<Category>('categories').listenable(),
            builder: (context, Box<Category> box, _) {
              final categories = box.values.toList();
              
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory?.key == category.key;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? PersonaTheme.primaryRed : Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected 
                            ? null 
                            : Border.all(color: Colors.grey[800]!, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            IconData(category.icon, fontFamily: 'MaterialIcons'),
                            color: isSelected ? Colors.white : Colors.white70,
                            size: 24,
                          ),
                          SizedBox(height: 4),
                          Text(
                            category.name,
                            style: GoogleFonts.rajdhani(
                              textStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : Colors.white70,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _formValidNotifier,
      builder: (context, isValid, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isValid && !_isSubmitting ? _submitExpense : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: PersonaTheme.primaryRed,
              disabledBackgroundColor: Colors.grey[800],
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: PersonaTheme.primaryRed.withOpacity(0.3),
            ),
            child: _isSubmitting
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'SIMPAN',
                    style: GoogleFonts.rajdhani(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: PersonaTheme.primaryRed,
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
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

  Future<void> _submitExpense() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        // Parse amount from formatted string
        final amountText = _amountController.text.replaceAll('.', '');
        final amount = double.parse(amountText);
        
        // Create new expense
        final expense = Expense(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: amount,
          description: _descriptionController.text,
          categoryId: _selectedCategory!.key,
          date: _selectedDate,
        );
        
        // Save to Hive
        final box = Hive.box<Expense>('expenses');
        await box.add(expense);
        
        // Update balance
        final settingsBox = Hive.box('settings');
        final currentBalance = settingsBox.get('balance', defaultValue: 0.0);
        await settingsBox.put('balance', currentBalance - amount);
        
        // Show success and pop
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Pengeluaran berhasil disimpan',
                style: GoogleFonts.rajdhani(),
              ),
              backgroundColor: PersonaTheme.primaryRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menyimpan pengeluaran: ${e.toString()}',
                style: GoogleFonts.rajdhani(),
              ),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
}

// Utility class for formatting thousands separator
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = '.';
  
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    // Only process if the text has changed
    if (oldValue.text == newValue.text) {
      return newValue;
    }
    
    // Remove all separators
    final value = newValue.text.replaceAll(separator, '');
    
    // Format with separators
    final formatter = NumberFormat('#,###', 'id_ID');
    final formatted = formatter.format(int.parse(value)).replaceAll(',', separator);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}