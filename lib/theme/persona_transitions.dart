import 'package:flutter/material.dart';
import 'persona_theme.dart';

/// A collection of Persona 5-inspired transitions and animations for the app
class PersonaTransitions {
  /// Creates a stylized page route transition in the Persona 5 style
  /// Use this for main menu transitions between screens
  static PageRouteBuilder<T> createPersonaRoute<T>({
    required Widget page,
    String? transitionLabel,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Sequential animations for Persona effect
        final slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOutQuint),
        ));
        
        final scaleAnimation = Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
        ));
        
        final opacityAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.1, 0.7, curve: Curves.easeIn),
        ));
        
        Widget transitionChild = child;
        
        // Add transition label if provided
        if (transitionLabel != null) {
          final labelOpacityAnimation = Tween<double>(
            begin: 1.0,
            end: 0.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
          ));
          
          transitionChild = Stack(
            children: [
              child,
              // Animated transition label
              FadeTransition(
                opacity: labelOpacityAnimation,
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: -0.1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: PersonaTheme.primaryRed,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(5, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            transitionLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        
        return FadeTransition(
          opacity: opacityAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [PersonaTheme.primaryRed.withOpacity(0.5), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                blendMode: BlendMode.srcATop,
                child: transitionChild,
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Creates a stylized Persona 5 sliding animation for widgets
  static Widget slideInAnimation({
    required Widget child,
    required AnimationController controller,
    Offset? beginOffset,
    Duration? delay,
  }) {
    final Animation<Offset> slideAnimation = Tween<Offset>(
      begin: beginOffset ?? const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: delay != null 
          ? controller.drive(CurveTween(curve: Interval(delay.inMilliseconds / 1000, 1.0)))
          : controller,
      curve: Curves.easeOutCubic,
    ));
    
    final Animation<double> fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: delay != null 
          ? controller.drive(CurveTween(curve: Interval(delay.inMilliseconds / 1000, 1.0)))
          : controller,
      curve: Curves.easeIn,
    ));
    
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
  
  /// Creates a flashy "All-Out Attack" animation for achievements
  static Widget allOutAttackAnimation({
    required BuildContext context,
    required AnimationController controller,
    required String victoryText,
  }) {
    final slashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeInOutQuint),
    ));
    
    final textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0.4, 0.7, curve: Curves.elasticOut),
    ));
    
    final fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
    ));
    
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Background
            Container(color: Colors.black),
            
            // Slashes
            Opacity(
              opacity: slashAnimation.value,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                painter: SlashPainter(progress: slashAnimation.value),
              ),
            ),
            
            // Victory text
            Opacity(
              opacity: textAnimation.value * (1 - fadeOutAnimation.value),
              child: Center(
                child: Transform.scale(
                  scale: 0.5 + (textAnimation.value * 0.5),
                  child: Transform.rotate(
                    angle: (1 - textAnimation.value) * 0.2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      decoration: BoxDecoration(
                        color: PersonaTheme.primaryRed,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        victoryText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom painter for slashing effect
class SlashPainter extends CustomPainter {
  final double progress;
  
  SlashPainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PersonaTheme.primaryRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0 * progress
      ..strokeCap = StrokeCap.round;
    
    // Draw several slash lines
    final slashCount = 6;
    for (int i = 0; i < slashCount; i++) {
      final startProgress = i / slashCount;
      final endProgress = (i + 1) / slashCount;
      
      if (progress > startProgress) {
        final currentProgress = (progress - startProgress) / (endProgress - startProgress);
        final clampedProgress = currentProgress.clamp(0.0, 1.0);
        
        final startX = size.width * (i % 2 == 0 ? 0.0 : 1.0);
        final endX = size.width * (i % 2 == 0 ? 1.0 : 0.0);
        final startY = size.height * (i / slashCount);
        final endY = size.height * ((i + 1) / slashCount);
        
        final endPoint = Offset(
          startX + (endX - startX) * clampedProgress,
          startY + (endY - startY) * clampedProgress,
        );
        
        canvas.drawLine(Offset(startX, startY), endPoint, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(SlashPainter oldDelegate) => progress != oldDelegate.progress;
} 