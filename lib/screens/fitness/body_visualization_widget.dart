import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';

class BodyVisualizationWidget extends StatelessWidget {
  final Map<String, int> muscleGroups; // muscle -> intensity (nombre de séries)

  const BodyVisualizationWidget({
    super.key,
    required this.muscleGroups,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Vue de face
          Expanded(
            child: _buildBodyView(context, isFront: true),
          ),
          // Vue de dos
          Expanded(
            child: _buildBodyView(context, isFront: false),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyView(BuildContext context, {required bool isFront}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            isFront ? 'Face' : 'Dos',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Expanded(
          child: CustomPaint(
            painter: BodyPainter(
              muscleGroups: muscleGroups,
              isFront: isFront,
            ),
            child: Container(),
          ),
        ),
      ],
    );
  }
}

class BodyPainter extends CustomPainter {
  final Map<String, int> muscleGroups;
  final bool isFront;

  BodyPainter({
    required this.muscleGroups,
    required this.isFront,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final headRadius = size.width / 8;
    
    // Dessiner la tête
    _drawHead(canvas, centerX, headRadius * 1.5, headRadius);
    
    if (isFront) {
      // Vue de face
      _drawFrontBody(canvas, size, centerX, headRadius);
    } else {
      // Vue de dos
      _drawBackBody(canvas, size, centerX, headRadius);
    }
    
    // Légende d'intensité
    _drawLegend(canvas, size);
  }

  void _drawHead(Canvas canvas, double x, double y, double radius) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(x, y), radius, paint);
    
    // Contour
    final outlinePaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(Offset(x, y), radius, outlinePaint);
  }

  void _drawFrontBody(Canvas canvas, Size size, double centerX, double headRadius) {
    final double neckY = headRadius * 2.5;
    final double shoulderY = headRadius * 3;
    final double chestY = headRadius * 4.5;
    final double waistY = headRadius * 6.5;
    final double hipY = headRadius * 8;
    final double kneeY = headRadius * 11;
    final double ankleY = headRadius * 14;
    
    // Pectoraux
    _drawMuscleGroup(
      canvas,
      'pectoraux',
      [
        Offset(centerX - headRadius * 1.5, shoulderY),
        Offset(centerX - headRadius * 0.5, chestY),
        Offset(centerX + headRadius * 0.5, chestY),
        Offset(centerX + headRadius * 1.5, shoulderY),
      ],
    );
    
    // Deltoïdes antérieurs (épaules avant)
    _drawMuscleGroup(
      canvas,
      'deltoïdes',
      [
        Offset(centerX - headRadius * 2, shoulderY - headRadius * 0.3),
        Offset(centerX - headRadius * 1.5, shoulderY),
        Offset(centerX - headRadius * 1.3, chestY - headRadius * 0.5),
        Offset(centerX - headRadius * 2.2, chestY - headRadius * 0.3),
      ],
    );
    _drawMuscleGroup(
      canvas,
      'deltoïdes',
      [
        Offset(centerX + headRadius * 2, shoulderY - headRadius * 0.3),
        Offset(centerX + headRadius * 1.5, shoulderY),
        Offset(centerX + headRadius * 1.3, chestY - headRadius * 0.5),
        Offset(centerX + headRadius * 2.2, chestY - headRadius * 0.3),
      ],
    );
    
    // Abdominaux
    _drawMuscleGroup(
      canvas,
      'abdominaux',
      [
        Offset(centerX - headRadius * 0.8, chestY),
        Offset(centerX + headRadius * 0.8, chestY),
        Offset(centerX + headRadius * 1, waistY),
        Offset(centerX - headRadius * 1, waistY),
      ],
    );
    
    // Biceps
    _drawMuscleGroup(
      canvas,
      'biceps',
      [
        Offset(centerX - headRadius * 2, chestY),
        Offset(centerX - headRadius * 1.8, waistY),
        Offset(centerX - headRadius * 2.2, waistY),
        Offset(centerX - headRadius * 2.4, chestY),
      ],
    );
    _drawMuscleGroup(
      canvas,
      'biceps',
      [
        Offset(centerX + headRadius * 2, chestY),
        Offset(centerX + headRadius * 1.8, waistY),
        Offset(centerX + headRadius * 2.2, waistY),
        Offset(centerX + headRadius * 2.4, chestY),
      ],
    );
    
    // Quadriceps
    _drawMuscleGroup(
      canvas,
      'quadriceps',
      [
        Offset(centerX - headRadius * 1.2, hipY),
        Offset(centerX - headRadius * 0.3, hipY),
        Offset(centerX - headRadius * 0.5, kneeY),
        Offset(centerX - headRadius * 1.3, kneeY),
      ],
    );
    _drawMuscleGroup(
      canvas,
      'quadriceps',
      [
        Offset(centerX + headRadius * 1.2, hipY),
        Offset(centerX + headRadius * 0.3, hipY),
        Offset(centerX + headRadius * 0.5, kneeY),
        Offset(centerX + headRadius * 1.3, kneeY),
      ],
    );
  }

  void _drawBackBody(Canvas canvas, Size size, double centerX, double headRadius) {
    final double neckY = headRadius * 2.5;
    final double shoulderY = headRadius * 3;
    final double midBackY = headRadius * 5;
    final double lowerBackY = headRadius * 7;
    final double hipY = headRadius * 8;
    final double kneeY = headRadius * 11;
    
    // Trapèzes
    _drawMuscleGroup(
      canvas,
      'trapèzes',
      [
        Offset(centerX - headRadius * 0.5, neckY),
        Offset(centerX + headRadius * 0.5, neckY),
        Offset(centerX + headRadius * 1.8, shoulderY),
        Offset(centerX - headRadius * 1.8, shoulderY),
      ],
    );
    
    // Dorsaux
    _drawMuscleGroup(
      canvas,
      'dorsaux',
      [
        Offset(centerX - headRadius * 2, shoulderY + headRadius * 0.5),
        Offset(centerX - headRadius * 0.8, shoulderY + headRadius * 0.5),
        Offset(centerX - headRadius * 0.5, midBackY),
        Offset(centerX - headRadius * 2.5, midBackY),
      ],
    );
    _drawMuscleGroup(
      canvas,
      'dorsaux',
      [
        Offset(centerX + headRadius * 2, shoulderY + headRadius * 0.5),
        Offset(centerX + headRadius * 0.8, shoulderY + headRadius * 0.5),
        Offset(centerX + headRadius * 0.5, midBackY),
        Offset(centerX + headRadius * 2.5, midBackY),
      ],
    );
    
    // Lombaires
    _drawMuscleGroup(
      canvas,
      'lombaires',
      [
        Offset(centerX - headRadius * 0.8, midBackY),
        Offset(centerX + headRadius * 0.8, midBackY),
        Offset(centerX + headRadius * 1, lowerBackY),
        Offset(centerX - headRadius * 1, lowerBackY),
      ],
    );
    
    // Fessiers
    _drawMuscleGroup(
      canvas,
      'fessiers',
      [
        Offset(centerX - headRadius * 1.2, lowerBackY),
        Offset(centerX - headRadius * 0.3, lowerBackY),
        Offset(centerX - headRadius * 0.3, hipY),
        Offset(centerX - headRadius * 1.2, hipY),
      ],
    );
    _drawMuscleGroup(
      canvas,
      'fessiers',
      [
        Offset(centerX + headRadius * 1.2, lowerBackY),
        Offset(centerX + headRadius * 0.3, lowerBackY),
        Offset(centerX + headRadius * 0.3, hipY),
        Offset(centerX + headRadius * 1.2, hipY),
      ],
    );
    
    // Ischio-jambiers
    _drawMuscleGroup(
      canvas,
      'ischio',
      [
        Offset(centerX - headRadius * 1.2, hipY),
        Offset(centerX - headRadius * 0.4, hipY),
        Offset(centerX - headRadius * 0.5, kneeY),
        Offset(centerX - headRadius * 1.2, kneeY),
      ],
    );
    _drawMuscleGroup(
      canvas,
      'ischio',
      [
        Offset(centerX + headRadius * 1.2, hipY),
        Offset(centerX + headRadius * 0.4, hipY),
        Offset(centerX + headRadius * 0.5, kneeY),
        Offset(centerX + headRadius * 1.2, kneeY),
      ],
    );
    
    // Triceps
    _drawMuscleGroup(
      canvas,
      'triceps',
      [
        Offset(centerX - headRadius * 2.1, shoulderY + headRadius * 0.8),
        Offset(centerX - headRadius * 1.9, shoulderY + headRadius * 0.8),
        Offset(centerX - headRadius * 1.8, lowerBackY - headRadius * 0.5),
        Offset(centerX - headRadius * 2.2, lowerBackY - headRadius * 0.5),
      ],
    );
    _drawMuscleGroup(
      canvas,
      'triceps',
      [
        Offset(centerX + headRadius * 2.1, shoulderY + headRadius * 0.8),
        Offset(centerX + headRadius * 1.9, shoulderY + headRadius * 0.8),
        Offset(centerX + headRadius * 1.8, lowerBackY - headRadius * 0.5),
        Offset(centerX + headRadius * 2.2, lowerBackY - headRadius * 0.5),
      ],
    );
  }

  void _drawMuscleGroup(Canvas canvas, String muscleKey, List<Offset> points) {
    // Chercher si ce groupe musculaire est travaillé
    int intensity = 0;
    for (var entry in muscleGroups.entries) {
      if (entry.key.toLowerCase().contains(muscleKey.toLowerCase()) ||
          muscleKey.toLowerCase().contains(entry.key.toLowerCase())) {
        intensity = entry.value;
        break;
      }
    }
    
    if (points.length < 3) return;
    
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    
    // Couleur basée sur l'intensité
    Color fillColor = Colors.grey[300]!;
    if (intensity > 0) {
      final baseColor = AppTheme.getMuscleGroupColor(muscleKey);
      final opacity = (intensity / 10).clamp(0.3, 0.9);
      fillColor = baseColor.withOpacity(opacity);
    }
    
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, paint);
    
    // Contour
    final outlinePaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawPath(path, outlinePaint);
  }

  void _drawLegend(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Afficher l'intensité maximale
    int maxIntensity = 0;
    for (var intensity in muscleGroups.values) {
      if (intensity > maxIntensity) maxIntensity = intensity;
    }
    
    if (maxIntensity > 0) {
      textPainter.text = TextSpan(
        text: 'Max: $maxIntensity séries',
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(10, size.height - 20));
    }
  }

  @override
  bool shouldRepaint(covariant BodyPainter oldDelegate) {
    return oldDelegate.muscleGroups != muscleGroups || oldDelegate.isFront != isFront;
  }
}
