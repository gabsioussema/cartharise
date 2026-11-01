import '../../domain/persona.dart';
import '../../state/app_state.dart';
import '../campaign/campaign_ops.dart';

/// Persona operations on top of [AppState.mutate] (PLAN.md §4: feature
/// extensions live in the feature's folder).
extension PersonaOps on AppState {
  /// The user's persona, or null before they create one.
  Persona? get persona => data.persona;

  /// Decorative extras open to the user now (everything with the game layer
  /// off).
  Set<Unlockable> get avatarUnlocks =>
      unlockedBy(campaign, gameOn: settings.game);

  /// Whether [part] can be chosen: free parts always; unlockable ones once
  /// unlocked, or if the saved avatar already wears it (never taken away).
  bool canUse(Enum part) {
    final needed = requirementOf(part);
    if (needed == null) return true;
    return avatarUnlocks.contains(needed) ||
        (persona?.avatar.uses(needed) ?? false);
  }

  /// Saves the avatar and motto (the motto exactly as typed, at most
  /// [kPersonaMottoMax] characters).
  Future<void> savePersona(Avatar avatar, {String motto = ''}) {
    if (motto.length > kPersonaMottoMax) {
      throw ArgumentError.value(motto, 'motto', 'too long');
    }
    return mutate(
      (d) => d.copyWith(
        persona: () => Persona(avatar: avatar, motto: motto, updatedAt: now()),
      ),
    );
  }

  /// Removes the avatar (back to the emblem).
  Future<void> clearPersona() => mutate((d) => d.copyWith(persona: () => null));
}
