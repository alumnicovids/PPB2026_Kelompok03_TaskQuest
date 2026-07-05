import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sensors_plus/sensors_plus.dart';

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double alpha;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.alpha,
  });
}

class LevelUpScreen extends StatefulWidget {
  const LevelUpScreen({super.key});

  @override
  State<LevelUpScreen> createState() => _LevelUpScreenState();
}

class _LevelUpScreenState extends State<LevelUpScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Particle> _particles = [];
  final Random _random = Random();
  StreamSubscription<AccelerometerEvent>? _sensorSubscription;

  // Sensor state values (interpolated tilt)
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Initalize particles
    for (int i = 0; i < 60; i++) {
      _particles.add(_generateParticle(const Size(400, 800)));
    }

    // Subscribe to accelerometer for phone tilt detection
    _sensorSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (mounted) {
        setState(() {
          // Smooth out sensor values: on Android, x is positive when tilted left, y is positive when tilted backward
          _tiltX = -event.x * 2.0; // horizontal force
          _tiltY = event.y * 2.0;  // vertical force
        });
      }
    });
  }

  Particle _generateParticle(Size size) {
    return Particle(
      x: _random.nextDouble() * (size.width > 0 ? size.width : 400),
      y: _random.nextDouble() * (size.height > 0 ? size.height : 800),
      vx: (_random.nextDouble() - 0.5) * 2,
      vy: -(_random.nextDouble() * 1.5 + 0.5),
      size: _random.nextDouble() * 6 + 3,
      color: Colors.amber[300 + _random.nextInt(3) * 100] ?? Colors.amber,
      alpha: _random.nextDouble() * 0.6 + 0.4,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _sensorSubscription?.cancel();
    super.dispose();
  }

  void _updateParticles(Size size) {
    for (final particle in _particles) {
      // Accelerometer tilt influences particle velocity
      particle.x += particle.vx + _tiltX * 0.1;
      particle.y += particle.vy + _tiltY * 0.1;

      // Wrap-around screen bounds
      if (particle.x < 0) {
        particle.x = size.width;
      } else if (particle.x > size.width) {
        particle.x = 0;
      }

      if (particle.y < 0) {
        particle.y = size.height;
        particle.x = _random.nextDouble() * size.width;
      } else if (particle.y > size.height) {
        particle.y = 0;
        particle.x = _random.nextDouble() * size.width;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1A), // Sleek dark theme
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          _updateParticles(size);
          return Stack(
            children: [
              // Interactive Particle Layer
              CustomPaint(
                size: size,
                painter: ParticlePainter(particles: _particles),
              ),

              // Glassmorphic Content overlay
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Container(
                    padding: const EdgeInsets.all(28.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(120),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFC15F3C).withAlpha(100),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC15F3C).withAlpha(40),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Level Up Graphic
                        const Icon(
                          Icons.workspace_premium_rounded,
                          size: 90,
                          color: Color(0xFFC15F3C),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'LEVEL UP!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFC15F3C),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your character has gained new powers!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFEDE9DE),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Rotate / Tilt your phone to swirl the magical leveling energy!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amberAccent,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton(
                          onPressed: () {
                            context.go('/dashboard');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC15F3C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'CONTINUE QUEST',
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withAlpha((particle.alpha * 255).round())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
