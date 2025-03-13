import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/category.dart';
import '../theme/persona_theme.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final Function(bool) onSelected;

  const CategoryChip({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Color(category.color).withOpacity(0.3) 
              : Colors.black54,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Color(category.color) 
                : PersonaTheme.primaryRed.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(category.color).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              IconData(
                category.icon,
                fontFamily: 'MaterialIcons',
              ),
              color: isSelected 
                  ? Color(category.color) 
                  : Colors.white70,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: GoogleFonts.rajdhani(
                textStyle: TextStyle(
                  color: isSelected 
                      ? Colors.white 
                      : Colors.white70,
                  fontSize: 14,
                  fontWeight: isSelected 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 