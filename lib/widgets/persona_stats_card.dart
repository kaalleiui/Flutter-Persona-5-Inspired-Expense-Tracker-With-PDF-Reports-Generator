import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/persona_theme.dart';

/// A stylized stats card in Persona 5 style for displaying financial data
class PersonaStatsCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? cardColor;
  final bool isPositive;
  final VoidCallback? onTap;
  final int animationOrder;
  
  const PersonaStatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.cardColor,
    this.isPositive = true,
    this.onTap,
    this.animationOrder = 0,
  }) : super(key: key);
  
  @override
  State<PersonaStatsCard> createState() => _PersonaStatsCardState();
}

class _PersonaStatsCardState extends State<PersonaStatsCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Delay animation based on order
    final delay = Duration(milliseconds: widget.animationOrder * 150);
    Future.delayed(delay, () {
      if (mounted) {
        _animationController.forward();
      }
    });
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutQuint),
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final cardColor = widget.cardColor ?? PersonaTheme.primaryRed;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(_slideAnimation.value, 0),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PersonaTheme.secondaryBlack,
                        cardColor.withOpacity(0.2),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: PersonaTheme.cardRadius,
                    border: Border.all(
                      color: cardColor.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cardColor.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Add decorative diagonal line in Persona style
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          height: 4,
                          width: 80,
                          decoration: BoxDecoration(
                            color: cardColor.withOpacity(0.8),
                          ),
                        ),
                      ),
                      
                      // Main card content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Row(
                          children: [
                            // Icon with animated container
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: PersonaTheme.secondaryBlack,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: cardColor.withOpacity(0.6),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: cardColor.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.icon,
                                color: cardColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Title and value
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.title.toUpperCase(),
                                    style: GoogleFonts.rajdhani(
                                      textStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                        color: PersonaTheme.textGrey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.value,
                                    style: GoogleFonts.rajdhani(
                                      textStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        color: PersonaTheme.textWhite,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Trend indicator for financial stats
                            Icon(
                              widget.isPositive
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              color: widget.isPositive
                                  ? Colors.green.shade400
                                  : PersonaTheme.primaryRed,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
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

/// A group of stats cards with staggered animations
class PersonaStatsGroup extends StatelessWidget {
  final List<PersonaStatsCard> cards;
  final String? groupTitle;
  
  const PersonaStatsGroup({
    Key? key,
    required this.cards,
    this.groupTitle,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (groupTitle != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  height: 20,
                  width: 4,
                  decoration: BoxDecoration(
                    color: PersonaTheme.primaryRed,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  groupTitle!.toUpperCase(),
                  style: GoogleFonts.rajdhani(
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: PersonaTheme.textWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Card list with automatic animation ordering
        ...List.generate(
          cards.length,
          (index) => cards[index],
        ),
      ],
    );
  }
} 