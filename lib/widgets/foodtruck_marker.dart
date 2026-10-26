import 'package:flutter/material.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';
import 'package:foodtruck_app/theme/colors.dart';

class FoodtruckMarkerIcon extends StatelessWidget {
  const FoodtruckMarkerIcon({
    super.key,
    required this.foodtruck,
    this.size = 48,
  });

  final FoodTruck foodtruck;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: foodtruck.name,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: foodtruck.markerColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: FoodtrackColors.noirBrule.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(foodtruck.logoIcon, size: size * 0.52, color: Colors.white),
      ),
    );
  }
}

class FoodtruckMapPin extends StatelessWidget {
  const FoodtruckMapPin({super.key, required this.foodtruck});

  final FoodTruck foodtruck;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 61,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          FoodtruckMarkerIcon(foodtruck: foodtruck, size: 48),
          CustomPaint(
            size: const Size(14, 10),
            painter: _PinTipPainter(foodtruck.markerColor),
          ),
        ],
      ),
    );
  }
}

class _PinTipPainter extends CustomPainter {
  const _PinTipPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawShadow(path, color.withValues(alpha: 0.3), 3, false);
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_PinTipPainter oldDelegate) => oldDelegate.color != color;
}
