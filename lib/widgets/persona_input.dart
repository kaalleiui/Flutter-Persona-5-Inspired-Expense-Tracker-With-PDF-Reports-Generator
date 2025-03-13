import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/persona_theme.dart';

class PersonaInput extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;

  const PersonaInput({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.inputFormatters,
    this.keyboardType,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.focusNode,
    this.onChanged,
  }) : super(key: key);

  @override
  State<PersonaInput> createState() => _PersonaInputState();
}

class _PersonaInputState extends State<PersonaInput> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 2.0,
      end: 4.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    widget.focusNode?.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (widget.focusNode?.hasFocus ?? false) {
      setState(() => _isFocused = true);
      _controller.forward();
    } else {
      setState(() => _isFocused = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: PersonaTheme.primaryRed.withOpacity(0.2),
                spreadRadius: _isFocused ? _glowAnimation.value : 0,
                blurRadius: _isFocused ? 12 : 0,
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            validator: widget.validator,
            inputFormatters: widget.inputFormatters,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            style: GoogleFonts.rajdhani(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              prefixIcon: widget.prefix,
              suffixIcon: widget.suffix,
              filled: true,
              fillColor: Colors.black87,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: PersonaTheme.primaryRed,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: PersonaTheme.primaryRed,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: PersonaTheme.primaryRed.withOpacity(0.8),
                  width: 3,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.red.shade800,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.red.shade800,
                  width: 3,
                ),
              ),
              labelStyle: GoogleFonts.rajdhani(
                textStyle: TextStyle(
                  color: _isFocused ? PersonaTheme.primaryRed : Colors.white70,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              hintStyle: GoogleFonts.rajdhani(
                textStyle: const TextStyle(
                  color: Colors.white38,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 