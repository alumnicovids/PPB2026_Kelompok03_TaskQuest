import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../providers/character_provider.dart';
import '../../../core/constants/app_constants.dart';

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

class _LevelUpScreenState extends State<LevelUpScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Particle> _particles = [];
  final Random _random = Random();
  StreamSubscription<GyroscopeEvent>? _sensorSubscription;

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

    // Initialize particles
    for (int i = 0; i < 75; i++) {
      _particles.add(_generateParticle(const Size(400, 800)));
    }

    // Subscribe to gyroscope for phone rotation detection
    _sensorSubscription = gyroscopeEventStream().listen((GyroscopeEvent event) {
      if (mounted) {
        setState(() {
          // Angular velocities (rad/s) are used as a physical force/wind vector
          // event.y represents horizontal rotation (tilting left/right)
          // event.x represents vertical rotation (tilting forward/backward)
          _tiltX = event.y * 6.0;
          _tiltY = event.x * 6.0;
        });
      }
    });
  }

  Particle _generateParticle(Size size) {
    return Particle(
      x: _random.nextDouble() * (size.width > 0 ? size.width : 400),
      y: _random.nextDouble() * (size.height > 0 ? size.height : 800),
      vx: (_random.nextDouble() - 0.5) * 2.5,
      vy: -(_random.nextDouble() * 2.0 + 0.5),
      size: _random.nextDouble() * 7 + 3,
      color: Colors.amber[300 + _random.nextInt(3) * 100] ?? Colors.amber,
      alpha: _random.nextDouble() * 0.7 + 0.3,
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
      // Gyroscope angular velocity acts as a wind force affecting particle drift
      particle.x += particle.vx + _tiltX;
      particle.y += particle.vy + _tiltY;

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

    // Decay the gyroscope tilt force gradually back to zero when movement stops
    _tiltX *= 0.92;
    _tiltY *= 0.92;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final characterProvider = Provider.of<CharacterProvider>(context);
    final character = characterProvider.character;

    final String className = character?.classType ?? 'knight';
    final String capitalizedClass = className.isNotEmpty
        ? '${className[0].toUpperCase()}${className.substring(1)}'
        : 'Knight';
    final int level = character?.level ?? 1;
    final int appearanceStage = character?.appearanceStage ?? 1;

    IconData classIcon;
    switch (className.toLowerCase()) {
      case 'mage':
        classIcon = Icons.auto_stories_rounded;
        break;
      case 'archer':
        classIcon = Icons.gps_fixed_rounded;
        break;
      case 'assassin':
        classIcon = Icons.bolt_rounded;
        break;
      default:
        classIcon = Icons.shield_rounded;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1915), // Sleek dark theme
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
                      color: const Color(0xFF262420).withAlpha(220),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFC15F3C).withAlpha(100),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC15F3C).withAlpha(50),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Class/Level Icon Wrapper with glowing effect
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC15F3C).withAlpha(30),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFC15F3C),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              '${AppConstants.supabaseUrl}/storage/v1/object/public/character-avatars/${className.toLowerCase()}_stage$appearanceStage.png',
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  classIcon,
                                  size: 70,
                                  color: const Color(0xFFC15F3C),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'LEVEL UP!',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFC15F3C),
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$capitalizedClass Hero',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEDEAE0),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Level $level · Stage $appearanceStage',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFE0A98C),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your character has evolved and unlocked new potential!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFEDE9DE),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.screen_rotation,
                              color: Colors.amberAccent,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Rotate / Tilt your phone to swirl the magical leveling energy!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amberAccent,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton(
                          onPressed: () {
                            context.go('/dashboard');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC15F3C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'CONTINUE QUEST',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              fontSize: 14,
                            ),
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
