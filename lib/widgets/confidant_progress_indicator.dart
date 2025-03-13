import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/confidant.dart';

class ConfidantProgressIndicator extends StatelessWidget {
  final Confidant confidant;

  const ConfidantProgressIndicator({
    Key? key,
    required this.confidant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If confidant is at max rank, show a special indicator
    if (confidant.rank >= 10) {
      return _buildMaxRankIndicator();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PROGRESS TO RANK ${confidant.rank + 1}',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
            Text(
              '${confidant.currentPoints}/${confidant.pointsToNextRank} POINTS',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(confidant.colorValue),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Background track
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.grey.shade800,
                  width: 1,
                ),
              ),
            ),
            // Progress fill
            FractionallySizedBox(
              widthFactor: confidant.progressPercentage,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(confidant.colorValue),
                      Color(confidant.colorValue).withOpacity(0.7),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Color(confidant.colorValue).withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          confidant.formattedProgress,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(confidant.colorValue),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMaxRankIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(confidant.colorValue).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color(confidant.colorValue),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: Color(confidant.colorValue),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'MAXIMUM RANK ACHIEVED',
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(confidant.colorValue),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
} 