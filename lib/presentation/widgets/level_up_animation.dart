import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LevelUpParticle {
  Offset position;
  final Offset velocity;
  final double size;
  double opacity;
  final Color color;
  final bool isRune;

  LevelUpParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.color,
    this.isRune = false,
  });
}

class LevelUpAnimationWidget extends StatefulWidget {
  final int newLevel;
  final int xpGained;
  final VoidCallback onAnimationEnd;

  const LevelUpAnimationWidget({
    super.key,
    required this.newLevel,
    required this.xpGained,
    required this.onAnimationEnd,
  });

  @override
  State<LevelUpAnimationWidget> createState() => LevelUpAnimationWidgetState();
}

// Public state so parent can call applyGyroTilt via GlobalKey
class LevelUpAnimationWidgetState extends State<LevelUpAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _textController;
  late AnimationController _ringController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _textFadeAnim;
  late Animation<double> _ringScaleAnim;
  late Animation<double> _ringOpacityAnim;

  final List<LevelUpParticle> _particles = [];
  final Random _random = Random();
  Offset _gyroTilt = Offset.zero;

  static const _particleColors = [
    AppColors.ancientGold,
    AppColors.paleGold,
    AppColors.burnishedGold,
    AppColors.parchmentWhite,
    AppColors.questGold,
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Center medallion scale
    _scaleAnim = Tween<double>(begin: 0.1, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // Overall fade out at end
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    // XP text fade in
    _textFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    // Gold ring expanding outward
    _ringScaleAnim = Tween<double>(begin: 0.0, end: 2.5).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );
    _ringOpacityAnim = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    _spawnParticles();
    _controller.forward();
    _textController.forward();
    _ringController.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationEnd();
      }
    });
  }

  void _spawnParticles() {
    for (int i = 0; i < 55; i++) {
      _particles.add(
        LevelUpParticle(
          position: Offset(
            0.25 + _random.nextDouble() * 0.5,
            0.25 + _random.nextDouble() * 0.5,
          ),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 0.009,
            (_random.nextDouble() - 0.5) * 0.009,
          ),
          size: 3.0 + _random.nextDouble() * 11.0,
          opacity: 0.6 + _random.nextDouble() * 0.4,
          color: _particleColors[_random.nextInt(_particleColors.length)],
          isRune: _random.nextDouble() > 0.72,
        ),
      );
    }
  }

  void applyGyroTilt(double x, double y) {
    if (mounted) {
      setState(() {
        _gyroTilt = Offset(x * 0.012, y * 0.012);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _textController, _ringController]),
      builder: (context, _) {
        for (final p in _particles) {
          p.position = Offset(
            (p.position.dx + p.velocity.dx + _gyroTilt.dx).clamp(0.02, 0.98),
            (p.position.dy + p.velocity.dy + _gyroTilt.dy).clamp(0.02, 0.98),
          );
        }

        return FadeTransition(
          opacity: _fadeAnim,
          child: Stack(
            children: [
              // Dark overlay
              Container(
                color: AppColors.dungeonBlack.withAlpha(210),
              ),

              // Gold particle canvas
              CustomPaint(
                painter: _MedievalParticlePainter(
                  particles: _particles,
                  progress: _controller.value,
                ),
                size: Size.infinite,
              ),

              // Expanding gold ring
              Center(
                child: ScaleTransition(
                  scale: _ringScaleAnim,
                  child: Opacity(
                    opacity: _ringOpacityAnim.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.ancientGold,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Center medallion
              Center(
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.burnishedGold.withAlpha(60),
                          AppColors.weatheredStone.withAlpha(200),
                          AppColors.dungeonBlack.withAlpha(220),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.ancientGold,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ancientGold.withAlpha(100),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.goldShimmerGradient.createShader(bounds),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.goldShimmerGradient.createShader(bounds),
                          child: const Text(
                            'LEVEL UP!',
                            style: TextStyle(
                              fontFamily: 'Cinzel',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Level ${widget.newLevel}',
                          style: const TextStyle(
                            fontFamily: 'Cinzel',
                            color: AppColors.parchmentWhite,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // XP gained text
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _textFadeAnim,
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.goldShimmerGradient.createShader(bounds),
                        child: Text(
                          '+${widget.xpGained} XP',
                          style: const TextStyle(
                            fontFamily: 'Cinzel',
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Appearance Unlocked!',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.fadedInk,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MedievalParticlePainter extends CustomPainter {
  final List<LevelUpParticle> particles;
  final double progress;

  const _MedievalParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final alpha = (p.opacity * 255 * (1 - progress)).round().clamp(0, 255);
      final paint = Paint()
        ..color = p.color.withAlpha(alpha)
        ..style = PaintingStyle.fill;

      final cx = p.position.dx * size.width;
      final cy = p.position.dy * size.height;
      final radius = p.size * (1 - progress * 0.4);

      if (p.isRune) {
        // Draw a small diamond rune shape
        final path = Path();
        path.moveTo(cx, cy - radius);
        path.lineTo(cx + radius * 0.6, cy);
        path.lineTo(cx, cy + radius);
        path.lineTo(cx - radius * 0.6, cy);
        path.close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawCircle(Offset(cx, cy), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_MedievalParticlePainter oldDelegate) => true;
}
