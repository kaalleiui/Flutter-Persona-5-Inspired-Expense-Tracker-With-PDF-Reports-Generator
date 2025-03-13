import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/confidant.dart';
import '../theme/persona_theme.dart';
import '../widgets/all_out_attack.dart';
import '../widgets/persona_button.dart';
import '../widgets/confidant_progress_indicator.dart';

class ConfidantScreen extends StatefulWidget {
  const ConfidantScreen({Key? key}) : super(key: key);

  @override
  State<ConfidantScreen> createState() => _ConfidantScreenState();
}

class _ConfidantScreenState extends State<ConfidantScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  
  final _confidantBox = Hive.box<ConfidantSystem>('confidant_system');
  final _pageScrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutExpo,
    ));
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _pageScrollController.dispose();
    super.dispose();
  }
  
  ConfidantSystem get confidantSystem => _confidantBox.getAt(0) ?? ConfidantSystem.defaultSystem();
  
  void _setActiveConfidant(String confidantId) {
    _confidantBox.putAt(0, confidantSystem.copyWith(
      activeConfidantId: confidantId,
    ));
  }
  
  void _addPointsToConfidant(String confidantId, int points) {
    final system = confidantSystem;
    final updatedConfidants = system.confidants.map((c) {
      if (c.id == confidantId) {
        final newPoints = c.currentPoints + points;
        final canLevelUp = newPoints >= c.pointsToNextRank && c.rank < 10;
        
        return c.copyWith(
          rank: canLevelUp ? c.rank + 1 : c.rank,
          currentPoints: canLevelUp ? 0 : newPoints,
          pointsToNextRank: canLevelUp ? c.pointsToNextRank + 500 : c.pointsToNextRank,
        );
      }
      return c;
    }).toList();

    _confidantBox.putAt(0, system.copyWith(confidants: updatedConfidants));
    _showRankUpEffectIfNeeded(confidantId);
  }
  
  void _showRankUpEffectIfNeeded(String confidantId) {
    final confidant = confidantSystem.confidants.firstWhere((c) => c.id == confidantId);
    if (confidant.currentPoints == 0 && confidant.rank > 1) {
      AllOutAttackOverlay.show(
        context,
        duration: const Duration(seconds: 2),
        child: _RankUpNotification(confidant: confidant),
      );
    }
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
          'CONFIDANTS',
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
      body: ValueListenableBuilder<Box<ConfidantSystem>>(
        valueListenable: _confidantBox.listenable(),
        builder: (context, box, _) {
          final system = box.getAt(0) ?? ConfidantSystem.defaultSystem();
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (system.activeConfidant != null)
                      _buildActiveConfidantCard(system.activeConfidant!),
                    const SizedBox(height: 24),
                    _buildConfidantList(
                      system.confidants,
                      system.activeConfidantId,
                    ),
                    const SizedBox(height: 24),
                    _buildSystemStats(system),
                    if (system.activeConfidant != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: ElevatedButton(
                          onPressed: () => _addPointsToConfidant(
                            system.activeConfidant!.id, 
                            250,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PersonaTheme.primaryRed,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            shadowColor: PersonaTheme.primaryRed.withOpacity(0.3),
                          ),
                          child: Text(
                            'SIMULATE ACHIEVEMENT',
                            style: GoogleFonts.rajdhani(
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveConfidantCard(Confidant confidant) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(confidant.colorValue).withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildConfidantHeader(confidant),
          const SizedBox(height: 16),
          ConfidantProgressIndicator(confidant: confidant),
          const SizedBox(height: 16),
          _buildConfidantAbilities(confidant),
        ],
      ),
    );
  }

  Widget _buildConfidantHeader(Confidant confidant) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(confidant.colorValue),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            IconData(confidant.iconCode, fontFamily: 'MaterialIcons'),
            size: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                confidant.name.toUpperCase(),
                style: GoogleFonts.rajdhani(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: Color(confidant.colorValue),
                ),
              ),
              Text(
                'Rank ${confidant.rank} • ${confidant.title}',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfidantAbilities(Confidant confidant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ABILITIES UNLOCKED',
          style: GoogleFonts.rajdhani(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          confidant.rank.clamp(0, confidant.abilities.length),
          (index) => _buildAbilityRow(
            ability: confidant.abilities[index],
            isUnlocked: true,
            color: Color(confidant.colorValue),
          ),
        ),
        if (confidant.rank < confidant.abilities.length)
          _buildAbilityRow(
            ability: confidant.abilities[confidant.rank],
            isUnlocked: false,
            color: Colors.grey,
          ),
      ],
    );
  }

  Widget _buildAbilityRow({
    required String ability,
    required bool isUnlocked,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isUnlocked ? Icons.check_circle : Icons.lock,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ability,
              style: TextStyle(
                color: isUnlocked ? Colors.white : Colors.grey,
                fontSize: 14,
                fontStyle: isUnlocked ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidantList(List<Confidant> confidants, String activeConfidantId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT CONFIDANT',
          style: GoogleFonts.rajdhani(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...confidants.map((c) => _buildConfidantListItem(
          confidant: c,
          isActive: c.id == activeConfidantId,
          onTap: () => _setActiveConfidant(c.id),
        )).toList(),
      ],
    );
  }

  Widget _buildConfidantListItem({
    required Confidant confidant,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isActive 
                  ? Color(confidant.colorValue).withOpacity(0.15)
                  : Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive 
                    ? Color(confidant.colorValue)
                    : Colors.grey.shade800,
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildConfidantRankBadge(confidant),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        confidant.name,
                        style: GoogleFonts.rajdhani(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        confidant.shortDescription,
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Icon(
                    Icons.radio_button_checked,
                    color: Color(confidant.colorValue),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfidantRankBadge(Confidant confidant) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(confidant.colorValue),
      ),
      alignment: Alignment.center,
      child: Text(
        '${confidant.rank}',
        style: GoogleFonts.rajdhani(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildSystemStats(ConfidantSystem system) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: PersonaTheme.primaryRed.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SYSTEM OVERVIEW',
            style: GoogleFonts.rajdhani(
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(label: 'Total Savings', value: format.format(system.totalSavings)),
          _buildStatRow(label: 'Current Streak', value: '${system.totalDaysStreak} days'),
          _buildStatRow(
            label: 'Active Benefits', 
            value: '${system.allUnlockedAbilities.length} unlocked',
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.rajdhani(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankUpNotification extends StatelessWidget {
  final Confidant confidant;

  const _RankUpNotification({required this.confidant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(confidant.colorValue), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars_rounded,
            color: Color(confidant.colorValue),
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'CONFIDANT RANK UP!',
            style: GoogleFonts.rajdhani(
              color: Color(confidant.colorValue),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${confidant.name} has reached Rank ${confidant.rank}!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}