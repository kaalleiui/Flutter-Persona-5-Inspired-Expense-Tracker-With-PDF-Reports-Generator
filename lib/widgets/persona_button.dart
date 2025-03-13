import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/persona_theme.dart';

class PersonaButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;

  const PersonaButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
  }) : super(key: key);
  
  /// Factory constructor for a Phantom Thief styled button
  factory PersonaButton.phantomThiefStyle({
    Key? key,
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
  }) {
    return PersonaButton(
      key: key,
      text: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      color: PersonaTheme.primaryRed,
    );
  }

  @override
  State<PersonaButton> createState() => _PersonaButtonState();
}

class _PersonaButtonState extends State<PersonaButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    ));

    _glowAnimation = Tween<double>(
      begin: 2.0,
      end: 4.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    if (widget.onPressed != null) {
      widget.onPressed();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? PersonaTheme.primaryRed;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: _isPressed ? color.withOpacity(0.8) : Colors.black87,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  border: Border.all(
                    color: color,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      spreadRadius: _isHovered ? _glowAnimation.value : 1,
                      blurRadius: _isHovered ? 12 : 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (widget.isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      )
                    else
                      Text(
                        widget.text,
                        style: GoogleFonts.rajdhani(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
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
} 