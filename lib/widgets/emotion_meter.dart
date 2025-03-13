import 'package:flutter/material.dart';

class EmotionMeter extends StatelessWidget {
  final double total;
  final double maxAmount;

  const EmotionMeter({
    Key? key,
    required this.total,
    required this.maxAmount,
  }) : super(key: key);

  String _getEmotionIcon() {
    final percentage = (total / maxAmount).clamp(0.0, 1.0);
    
    if (percentage < 0.3) {
      return '😊'; // Happy
    } else if (percentage < 0.6) {
      return '😐'; // Neutral
    } else if (percentage < 0.8) {
      return '😟'; // Worried
    } else {
      return '😰'; // Stressed
    }
  }

  Color _getEmotionColor() {
    final percentage = (total / maxAmount).clamp(0.0, 1.0);
    
    if (percentage < 0.3) {
      return Colors.green;
    } else if (percentage < 0.6) {
      return Colors.yellow;
    } else if (percentage < 0.8) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _getEmotionColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getEmotionIcon(),
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
} 