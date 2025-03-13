import 'package:flutter/material.dart';
import '../theme/persona_theme.dart';

class PersonaToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;
  final Color? activeColor;

  const PersonaToggle({
    Key? key,
    required this.value,
    required this.onChanged,
    this.label,
    this.activeColor,
  }) : super(key: key);

  @override
  State<PersonaToggle> createState() => _PersonaToggleState();
}

class _PersonaToggleState extends State<PersonaToggle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0 * 3.14159, // 360 degrees in radians
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    ));

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PersonaToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? PersonaTheme.primaryRed;
    
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 52,
                height: 28,
                decoration: BoxDecoration(
                  color: Color.lerp(Colors.black87, activeColor, _animation.value),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: activeColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withOpacity(0.3 * _animation.value),
                      spreadRadius: 1,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 2 + (20 * _animation.value),
                      top: 2,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: activeColor.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.close,
                              size: 12,
                              color: Color.lerp(
                                activeColor,
                                Colors.black87,
                                _animation.value,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (widget.label != null) ...[
            const SizedBox(width: 8),
            Text(
              widget.label!,
              style: TextStyle(
                color: widget.value ? activeColor : Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 