import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonaCategoryTag extends StatefulWidget {
  final String name;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const PersonaCategoryTag({
    Key? key,
    required this.name,
    required this.icon,
    required this.color,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  State<PersonaCategoryTag> createState() => _PersonaCategoryTagState();
}

class _PersonaCategoryTagState extends State<PersonaCategoryTag> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    ));

    _glowAnimation = Tween<double>(
      begin: 1.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PersonaCategoryTag oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          widget.onTap();
          if (!widget.isSelected) {
            _controller.forward();
          }
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _isHovered ? _scaleAnimation.value : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  border: Border.all(
                    color: widget.color,
                    width: widget.isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      spreadRadius: widget.isSelected ? _glowAnimation.value : 0,
                      blurRadius: widget.isSelected ? 8 : 0,
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color.withOpacity(widget.isSelected ? 0.2 : 0.1),
                      Colors.black87,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.color,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.name,
                      style: GoogleFonts.rajdhani(
                        textStyle: TextStyle(
                          color: widget.isSelected ? widget.color : Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
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