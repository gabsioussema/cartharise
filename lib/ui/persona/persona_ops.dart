import '../../domain/persona.dart';
import '../../state/app_state.dart';
import '../campaign/campaign_ops.dart';

/// Persona operations on top of [AppState.mutate] (PLAN.md §4: feature
/// extensions live in the feature's folder).
extension PersonaOps on AppState {
  /// The user's persona, or null before they create one.
  Persona? get persona => data.persona;

  /// Decorative extras open to the user now: what the Campaign opens today
  /// plus every extra kept for good ([AppData.avatarUnlocked], which never
  /// shrinks); everything with the game layer off.
  Set<Unlockable> get avatarUnlocks => settings.game
      ? {...unlockedBy(campaign, gameOn: true), ...data.avatarUnlocked}
      : Unlockable.values.toSet();

  /// Whether extra [u] is the user's: open, kept for good, or worn by the
  /// saved avatar (never taken away).
  bool ownsExtra(Unlockable u) =>
      avatarUnlocks.contains(u) || (persona?.avatar.uses(u) ?? false);

  /// Whether [part] can be chosen: free parts always; unlockable ones once
  /// unlocked, or if the saved avatar already wears it (never taken away).
  bool canUse(Enum part) {
    final needed = requirementOf(part);
    return needed == null || ownsExtra(needed);
  }

  /// Saves the avatar and motto (the motto exactly as typed, at most
  /// [kPersonaMottoMax] characters). Every extra the saved avatar wore, and
  /// every extra [avatar] wears, is kept for good: changing the look never
  /// takes one away.
  Future<void> savePersona(Avatar avatar, {String motto = ''}) {
    if (motto.length > kPersonaMottoMax) {
      throw ArgumentError.value(motto, 'motto', 'too long');
    }
    return mutate(
      (d) => d.copyWith(
        persona: () => Persona(avatar: avatar, motto: motto, updatedAt: now()),
        avatarUnlocked: {
          ...d.avatarUnlocked,
          ...wornBy(d.persona?.avatar),
          ...wornBy(avatar),
        },
      ),
    );
  }

  /// Removes the avatar (back to the emblem). Extras it wore stay the
  /// user's for a new one.
  Future<void> clearPersona() => mutate(
    (d) => d.copyWith(
      persona: () => null,
      avatarUnlocked: {...d.avatarUnlocked, ...wornBy(d.persona?.avatar)},
    ),
  );
}
