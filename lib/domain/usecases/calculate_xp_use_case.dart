class CalculateXpUseCase {
  int execute({
    required String priority,
    required DateTime deadline,
    required DateTime completedAt,
  }) {
    int baseXp;
    switch (priority.toLowerCase()) {
      case 'low':
        baseXp = 10;
        break;
      case 'medium':
        baseXp = 20;
        break;
      case 'high':
        baseXp = 35;
        break;
      default:
        baseXp = 10;
    }

    double multiplier;
    if (completedAt.isAfter(deadline)) {
      multiplier = 0.5;
    } else {
      final deadlineDate = DateTime(
        deadline.year,
        deadline.month,
        deadline.day,
      );
      final completionDate = DateTime(
        completedAt.year,
        completedAt.month,
        completedAt.day,
      );
      final daysDifference = deadlineDate.difference(completionDate).inDays;

      if (daysDifference == 0) {
        multiplier = 1.5;
      } else if (daysDifference >= 1 && daysDifference <= 3) {
        multiplier = 1.2;
      } else {
        multiplier = 1.0;
      }
    }

    return (baseXp * multiplier).round();
  }
}
