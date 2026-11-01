/// Small value types exposed by [AppState]. Pure Dart.
library;

/// Where the latest change is in its way to storage (F-055).
enum SaveStatus {
  /// Nothing changed since the app opened.
  idle,
  saving,
  saved,

  /// The latest write failed: show it honestly with Retry / Export a copy.
  failed,
}

/// How far the user is in one reset phase. Counts only — never a judgement.
class PhaseProgress {
  const PhaseProgress({
    required this.answered,
    required this.skipped,
    required this.total,
  });

  /// Prompts with written words.
  final int answered;

  /// Prompts the user chose to skip (and hasn't answered since).
  final int skipped;
  final int total;

  /// Neither answered nor skipped yet.
  int get open => total - answered - skipped;

  /// Every prompt was answered or deliberately skipped.
  bool get finished => total > 0 && open == 0;

  /// answered / total, 0 when the phase is empty.
  double get fraction => total == 0 ? 0 : answered / total;

  @override
  bool operator ==(Object other) =>
      other is PhaseProgress &&
      other.answered == answered &&
      other.skipped == skipped &&
      other.total == total;

  @override
  int get hashCode => Object.hash(answered, skipped, total);

  @override
  String toString() =>
      'PhaseProgress($answered answered, $skipped skipped of $total)';
}
