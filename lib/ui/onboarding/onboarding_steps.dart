/// The ten onboarding pages, in order (PLAN.md §8, F-001–F-004, F-043).
/// Pure Dart, so the navigation rules are unit-tested.
library;

enum OnboardingStep {
  /// Stacked wordmark, tagline, bronze rule.
  brand,

  /// Carousel 1–4 (board): the four brand scenes.
  understand,
  reset,
  direction,
  steps,

  /// Setup 1: promise and limits, not-therapy note, 18+ confirmation.
  limits,

  /// Setup 2: source credit, links, independence + paraphrase notices.
  credit,

  /// Setup 3: one day or at my own pace.
  pace,

  /// Setup 4: optional name.
  name,

  /// Setup 5: where the data lives; Finish.
  privacy;

  /// The brand page and the carousel (hero surface, swipeable, skippable).
  bool get isIntro => index < limits.index;

  /// One of the four carousel pages.
  bool get isCarousel => index >= understand.index && index <= steps.index;

  /// 1-based position in the carousel, or null.
  int? get carouselPosition => isCarousel ? index - understand.index + 1 : null;

  /// 1-based position in the setup pages, or null.
  int? get setupPosition => isIntro ? null : index - limits.index + 1;

  /// Skip is offered on the intro pages only, and always lands on [limits]:
  /// it never jumps past the 18+ confirmation.
  bool get canSkip => isIntro;

  OnboardingStep? get next => this == privacy ? null : values[index + 1];

  OnboardingStep? get previous => this == brand ? null : values[index - 1];

  static const skipTarget = limits;
  static const carouselLength = 4;
  static const setupLength = 5;

  /// Whether the user may move on from this step. Only [limits] gates
  /// (the 18+ confirmation is required to finish, D-11).
  bool canAdvance({required bool adultConfirmed}) =>
      this != limits || adultConfirmed;
}
