import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'confidant.g.dart';

@HiveType(typeId: 3)
class Confidant {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int rank; // 1-10 rank system like in Persona 5

  @HiveField(3)
  final String description;

  @HiveField(4)
  final int iconCode;

  @HiveField(5)
  final int colorValue;

  @HiveField(6)
  final List<String> abilities; // Financial abilities unlocked at this rank

  @HiveField(7)
  final int pointsToNextRank; // Points needed to rank up

  @HiveField(8)
  final int currentPoints; // Current points accumulated

  Confidant({
    required this.id,
    required this.name,
    required this.rank,
    required this.description,
    required this.iconCode,
    required this.colorValue,
    required this.abilities,
    required this.pointsToNextRank,
    this.currentPoints = 0,
  });

  Confidant copyWith({
    String? id,
    String? name,
    int? rank,
    String? description,
    int? iconCode,
    int? colorValue,
    List<String>? abilities,
    int? pointsToNextRank,
    int? currentPoints,
  }) {
    return Confidant(
      id: id ?? this.id,
      name: name ?? this.name,
      rank: rank ?? this.rank,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      abilities: abilities ?? this.abilities,
      pointsToNextRank: pointsToNextRank ?? this.pointsToNextRank,
      currentPoints: currentPoints ?? this.currentPoints,
    );
  }

  double get progressPercentage => 
    pointsToNextRank > 0 ? (currentPoints / pointsToNextRank).clamp(0.0, 1.0) : 1.0;

  String get formattedProgress => 
    '${(progressPercentage * 100).toStringAsFixed(0)}%';
    
  bool get canRankUp => currentPoints >= pointsToNextRank && rank < 10;
  
  /// Get a title based on the confidant's role
  String get title {
    switch (id) {
      case 'savings':
        return 'Financial Advisor';
      case 'budget':
        return 'Budget Specialist';
      case 'debt':
        return 'Debt Strategist';
      default:
        return 'Financial Ally';
    }
  }
  
  /// Get a short description for the confidant
  String get shortDescription {
    if (rank >= 10) {
      return 'Mastered • All abilities unlocked';
    } else {
      return 'Rank $rank • ${abilities.length - rank} abilities locked';
    }
  }
}

@HiveType(typeId: 4)
class ConfidantSystem {
  @HiveField(0)
  final List<Confidant> confidants;

  @HiveField(1)
  final String activeConfidantId;

  @HiveField(2)
  final int totalSavings; // Total amount saved through the system

  @HiveField(3)
  final int totalDaysStreak; // Consecutive days of positive financial behavior

  ConfidantSystem({
    required this.confidants,
    required this.activeConfidantId,
    this.totalSavings = 0,
    this.totalDaysStreak = 0,
  });

  ConfidantSystem copyWith({
    List<Confidant>? confidants,
    String? activeConfidantId,
    int? totalSavings,
    int? totalDaysStreak,
  }) {
    return ConfidantSystem(
      confidants: confidants ?? this.confidants,
      activeConfidantId: activeConfidantId ?? this.activeConfidantId,
      totalSavings: totalSavings ?? this.totalSavings,
      totalDaysStreak: totalDaysStreak ?? this.totalDaysStreak,
    );
  }

  Confidant? get activeConfidant => 
    confidants.firstWhere((c) => c.id == activeConfidantId, orElse: () => confidants.first);

  // Get all unlocked abilities across all confidants
  List<String> get allUnlockedAbilities {
    final abilities = <String>[];
    for (final confidant in confidants) {
      if (confidant.rank > 0) {
        for (int i = 0; i < confidant.rank && i < confidant.abilities.length; i++) {
          abilities.add(confidant.abilities[i]);
        }
      }
    }
    return abilities;
  }
  
  /// Create a default confidant system with initial confidants
  static ConfidantSystem defaultSystem() {
    return ConfidantSystem(
      confidants: [
        Confidant(
          id: 'savings',
          name: 'Savings Master',
          rank: 1,
          description: 'Helps you save money more effectively',
          iconCode: Icons.savings.codePoint,
          colorValue: 0xFF1E88E5,
          abilities: [
            'Automatic savings suggestions',
            'Savings goals visualization',
            'Interest rate calculator',
            'Emergency fund planner',
            'Investment opportunities',
            'Retirement planning',
            'Tax optimization',
            'Wealth management',
            'Financial independence tracker',
            'Legacy planning',
          ],
          pointsToNextRank: 1000,
        ),
        Confidant(
          id: 'budget',
          name: 'Budget Guru',
          rank: 1,
          description: 'Helps you manage your budget wisely',
          iconCode: Icons.account_balance_wallet.codePoint,
          colorValue: 0xFF43A047,
          abilities: [
            'Basic budget templates',
            'Expense categorization',
            'Monthly spending analysis',
            'Budget vs. actual comparison',
            'Discretionary spending alerts',
            'Custom budget periods',
            'Multi-category budgeting',
            'Financial goal integration',
            'Predictive budget planning',
            'Life event budget adjustment',
          ],
          pointsToNextRank: 1000,
        ),
        Confidant(
          id: 'debt',
          name: 'Debt Slayer',
          rank: 1,
          description: 'Helps you eliminate debt faster',
          iconCode: Icons.money_off.codePoint,
          colorValue: 0xFFE53935,
          abilities: [
            'Debt overview dashboard',
            'Interest cost calculator',
            'Snowball/avalanche methods',
            'Payment reminders',
            'Refinancing opportunities',
            'Debt consolidation analysis',
            'Credit score improvement tips',
            'Negotiation strategies',
            'Debt-free celebration planner',
            'Wealth building transition',
          ],
          pointsToNextRank: 1000,
        ),
      ],
      activeConfidantId: 'savings',
    );
  }
  
  /// Set the active confidant
  void setActiveConfidant(String confidantId) {
    // This is a helper method for the provider pattern
    // In our implementation, we'll use the Hive box directly
  }
} 