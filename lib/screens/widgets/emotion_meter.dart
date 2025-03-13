import 'package:flutter/material.dart';

class EmotionMeter extends StatelessWidget {
  final double total;
  final double maxAmount;

  const EmotionMeter({Key? key, required this.total, required this.maxAmount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder for the EmotionMeter widget
    return Container(
      height: 50,
      width: 50,
      color: Colors.blue, // Placeholder color
      child: Center(child: Text('$total / $maxAmount')),
    );
  }
}
