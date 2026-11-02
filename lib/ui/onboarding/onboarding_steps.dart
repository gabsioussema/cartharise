/// The five welcome pages, in order (PLAN.md §8, F-001–F-004, F-043; evolve
/// plan Step 1 › A). Features are introduced on first use instead (one-line
/// hints on Today). Pure Dart, so the navigation rules are unit-tested.
library;

enum OnboardingStep {
  /// Emblem, wordmark, tagline, bronze rule and the one-line promise.
  brand,

  /// The source credit (title, author, links, independence notice), what
  /// this is and isn't (not therapy) and the 18+ confirmation.
  limits,

  /// One day or at my own pace.
  pace,

  /// Optional name.
  name,

  /// Where the data lives; Start.
  privacy;

  /// The brand page (hero surface, swipeable).
  bool get isIntro => this == brand;

  /// 1-based position among all pages.
  int get position => index + 1;

  OnboardingStep? get next => this == privacy ? null : values[index + 1];

  OnboardingStep? get previous => this == brand ? null : values[index - 1];

  static const length = 5;

  /// Whether the user may move on from this step. Only [limits] gates
  /// (the 18+ confirmation is required to finish, D-11).
  bool canAdvance({required bool adultConfirmed}) =>
      this != limits || adultConfirmed;
}
