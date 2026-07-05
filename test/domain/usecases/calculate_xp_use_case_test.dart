import 'package:flutter_test/flutter_test.dart';
import 'package:taskquest/domain/usecases/calculate_xp_use_case.dart';

void main() {
  late CalculateXpUseCase useCase;

  setUp(() {
    useCase = CalculateXpUseCase();
  });

  group('CalculateXpUseCase Tests', () {
    final deadline = DateTime(2026, 7, 5, 23, 59);

    test('low priority, completed > 3 days before deadline (1.0x)', () {
      final completedAt = DateTime(2026, 7, 1);
      final xp = useCase.execute(
        priority: 'low',
        deadline: deadline,
        completedAt: completedAt,
      );
      expect(xp, equals(10));
    });

    test('medium priority, completed 2 days before deadline (1.2x)', () {
      final completedAt = DateTime(2026, 7, 3);
      final xp = useCase.execute(
        priority: 'medium',
        deadline: deadline,
        completedAt: completedAt,
      );
      expect(xp, equals(24)); // 20 * 1.2 = 24
    });

    test('high priority, completed exactly on deadline day (1.5x clutch)', () {
      final completedAt = DateTime(2026, 7, 5, 12, 0);
      final xp = useCase.execute(
        priority: 'high',
        deadline: deadline,
        completedAt: completedAt,
      );
      expect(xp, equals(53)); // 35 * 1.5 = 52.5 -> round to 53
    });

    test('high priority, completed after deadline (0.5x)', () {
      final completedAt = DateTime(2026, 7, 6);
      final xp = useCase.execute(
        priority: 'high',
        deadline: deadline,
        completedAt: completedAt,
      );
      expect(xp, equals(18)); // 35 * 0.5 = 17.5 -> round to 18
    });
  });
}
