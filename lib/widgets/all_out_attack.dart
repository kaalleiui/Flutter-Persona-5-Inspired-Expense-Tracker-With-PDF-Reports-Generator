import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/persona_theme.dart';
import '../theme/persona_transitions.dart';

/// A Persona 5-style achievement celebration widget
/// that displays a flashy "All-Out Attack" animation
class AllOutAttackOverlay extends StatefulWidget {
  /// The victory text to display
  final String victoryText;
  
  /// How long to show the animation
  final Duration duration;
  
  /// Optional callback when animation completes
  final VoidCallback? onFinished;
  
  /// Optional child widget to display instead of the default animation
  final Widget? child;
  
  const AllOutAttackOverlay({
    Key? key,
    required this.victoryText,
    this.duration = const Duration(seconds: 3),
    this.onFinished,
    this.child,
  }) : super(key: key);

  /// Static method to show the All-Out Attack animation as an overlay
  static Future<void> show(
    BuildContext context, {
    String victoryText = '',
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onFinished,
    Widget? child,
  }) async {
    // Create overlay entry
    final overlayState = Overlay.of(context);
    late final OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => AllOutAttackOverlay(
        victoryText: victoryText,
        duration: duration,
        onFinished: () {
          // Remove the overlay when finished
          overlayEntry.remove();
          onFinished?.call();
        },
        child: child,
      ),
    );
    
    // Add to overlay
    overlayState.insert(overlayEntry);
  }

  @override
  State<AllOutAttackOverlay> createState() => _AllOutAttackOverlayState();
}

class _AllOutAttackOverlayState extends State<AllOutAttackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Auto-start and auto-dismiss
    _controller.forward().then((_) {
      if (widget.onFinished != null) {
        widget.onFinished!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: widget.child != null
          ? Center(child: widget.child)
          : PersonaTransitions.allOutAttackAnimation(
              context: context,
              controller: _controller,
              victoryText: widget.victoryText,
            ),
    );
  }
}

/// A widget that shows a celebratory achievement notification
/// in Persona 5 style when a financial milestone is reached
class AchievementNotification extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isPositive;
  
  const AchievementNotification({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    this.isPositive = true,
  }) : super(key: key);
  
  /// Static method to show the achievement notification as an overlay
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    bool isPositive = true,
    bool showAllOutAttack = false,
  }) async {
    // Create overlay entry
    final overlayState = Overlay.of(context);
    
    // Create achievement notification overlay
    final achievementEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 0,
        right: 0,
        child: SafeArea(
          child: AchievementNotification(
            title: title,
            description: description,
            icon: icon,
            isPositive: isPositive,
          ),
        ),
      ),
    );
    
    // Add notification to overlay
    overlayState.insert(achievementEntry);
    
    // If requested, show All-Out Attack after a delay
    if (showAllOutAttack) {
      await Future.delayed(const Duration(milliseconds: 1000));
      AllOutAttackOverlay.show(
        context, 
        victoryText: title,
      );
    }
    
    // Auto-remove after delay
    await Future.delayed(const Duration(seconds: 4));
    achievementEntry.remove();
  }

  @override
  State<AchievementNotification> createState() => _AchievementNotificationState();
}

class _AchievementNotificationState extends State<AchievementNotification> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _slideAnimation = Tween<double>(
      begin: -100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));
    
    _controller.forward();
    
    // Auto-dismiss after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.isPositive 
        ? Colors.green.shade400 
        : PersonaTheme.primaryRed;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: Offset(_slideAnimation.value, 0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withOpacity(0.6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, 
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: color,
                      size: 26,
                    ),
                  ),
                  title: Text(
                    widget.title,
                    style: GoogleFonts.rajdhani(
                      textStyle: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  subtitle: Text(
                    widget.description,
                    style: GoogleFonts.rajdhani(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.star,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 