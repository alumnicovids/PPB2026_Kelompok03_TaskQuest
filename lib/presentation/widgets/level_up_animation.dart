import 'dart:math';
import 'package:flutter/material.dart';

class LevelUpParticle {
  Offset position;
  final Offset velocity;
  final double size;
  double opacity;
  final Color color;

  LevelUpParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.color,
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
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _textFadeAnim;

  final List<LevelUpParticle> _particles = [];
  final Random _random = Random();
  Offset _gyroTilt = Offset.zero;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _scaleAnim = Tween<double>(
      begin: 0.2,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _textFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _spawnParticles();
    _controller.forward();
    _textController.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationEnd();
      }
    });
  }

  void _spawnParticles() {
    const colors = [
      Color(0xFFC15F3C),
      Color(0xFFE0A98C),
      Color(0xFFC48A2D),
      Color(0xFF4E7A51),
      Color(0xFFF4F3EE),
    ];
    for (int i = 0; i < 40; i++) {
      _particles.add(
        LevelUpParticle(
          position: Offset(
            0.3 + _random.nextDouble() * 0.4,
            0.3 + _random.nextDouble() * 0.4,
          ),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 0.008,
            (_random.nextDouble() - 0.5) * 0.008,
          ),
          size: 4.0 + _random.nextDouble() * 10.0,
          opacity: 0.7 + _random.nextDouble() * 0.3,
          color: colors[_random.nextInt(colors.length)],
        ),
      );
    }
  }

  void applyGyroTilt(double x, double y) {
    if (mounted) {
      setState(() {
        _gyroTilt = Offset(x * 0.01, y * 0.01);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _textController]),
      builder: (context, _) {
        for (final p in _particles) {
          p.position = Offset(
            (p.position.dx + p.velocity.dx + _gyroTilt.dx).clamp(0.05, 0.95),
            (p.position.dy + p.velocity.dy + _gyroTilt.dy).clamp(0.05, 0.95),
          );
        }

        return FadeTransition(
          opacity: _fadeAnim,
          child: Stack(
            children: [
              Container(color: Colors.black.withAlpha(180)),
              CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  progress: _controller.value,
                ),
                size: Size.infinite,
              ),
              Center(
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC15F3C),
                        width: 3,
                      ),
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFC15F3C).withAlpha(80),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFE0A98C),
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'LEVEL UP!',
                          style: TextStyle(
                            color: Color(0xFFC15F3C),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Level ${widget.newLevel}',
                          style: const TextStyle(
                            color: Color(0xFFEDEAE0),
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _textFadeAnim,
                  child: Text(
                    '+${widget.xpGained} XP',
                    style: const TextStyle(
                      color: Color(0xFFC48A2D),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
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

class _ParticlePainter extends CustomPainter {
  final List<LevelUpParticle> particles;
  final double progress;

  const _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withAlpha((p.opacity * 255 * (1 - progress)).round())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(p.position.dx * size.width, p.position.dy * size.height),
        p.size * (1 - progress * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
