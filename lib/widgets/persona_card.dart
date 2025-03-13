import 'package:flutter/material.dart';
import '../theme/persona_theme.dart';

class PersonaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double elevation;
  final VoidCallback? onTap;

  const PersonaCard({
    Key? key,
    required this.child,
    this.padding,
    this.color,
    this.elevation = 4.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      decoration: PersonaTheme.getAngularDecoration(
        color: color ?? const Color.fromARGB(255, 255, 57, 77),
      ),
      padding: padding ?? const EdgeInsets.all(16.0),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
} 