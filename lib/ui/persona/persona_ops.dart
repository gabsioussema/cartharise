import '../../domain/campaign.dart';
import '../../domain/persona.dart';
import '../../state/app_state.dart';
import '../campaign/campaign_ops.dart';

/// Persona operations on top of [AppState.mutate] (PLAN.md §4: feature
/// extensions live in the feature's folder).
extension PersonaOps on AppState {
  /// The user's persona, or null before they create one.
  Persona? get persona => data.persona;

  /// Decorative extras open to the user now: with the game layer on, the
  /// ones they keep (`AppData.avatarUnlocked`: chosen with a reward pick,
  /// kept from wearing, or opened by an earlier version — it never
  /// shrinks); every extra with the game layer off. Progress alone opens
  /// nothing: it gives picks ([picksLeft]).
  Set<Unlockable> get avatarUnlocks =>
      settings.game ? data.avatarUnlocked : Unlockable.values.toSet();

  /// Whether extra [u] is the user's: open, kept for good, or worn by the
  /// saved avatar (never taken away).
  bool ownsExtra(Unlockable u) =>
      avatarUnlocks.contains(u) || (persona?.avatar.uses(u) ?? false);

  /// Whether [part] can be chosen: free parts always; an extra once chosen
  /// with a pick (or kept), or if the saved avatar already wears it (never
  /// taken away). Locked = not chosen and no pick spent on it.
  bool canUse(Enum part) {
    final needed = requirementOf(part);
    return needed == null || ownsExtra(needed);
  }

  /// Reward picks the Campaign has given so far, spent or not
  /// ([rewardPicksEarned]: route stops after Carthage + achievements).
  int get picksEarned => rewardPicksEarned(campaign);

  /// Reward picks still to spend ([rewardPicksLeft]); 0 with the game
  /// layer off (every extra is open then).
  int get picksLeft =>
      settings.game ? rewardPicksLeft(campaign, data.avatarUnlocked) : 0;

  /// The extras a pick can buy, the suggested one first ([rewardOptions]):
  /// every extra not kept and not worn. Empty with the game layer off.
  List<Unlockable> get rewardChoices => settings.game
      ? rewardOptions(campaign, {
          ...data.avatarUnlocked,
          ...wornBy(persona?.avatar),
        })
      : const [];

  /// The extra to preselect in "Choose your reward" (the milestone's own
  /// [unlockSource] extra when it is still free), or null.
  Unlockable? get suggestedPick {
    final choices = rewardChoices;
    return choices.isEmpty ? null : choices.first;
  }

  /// Spends one reward pick on [extra]: it is the user's for good from now
  /// on. Only with the game layer on and a pick left ([StateError]
  /// otherwise), and only for an extra not already owned ([ArgumentError]).
  Future<void> chooseReward(Unlockable extra) {
    if (!settings.game) {
      throw StateError('The Campaign is off: every extra is open already');
    }
    if (ownsExtra(extra)) {
      throw ArgumentError.value(extra, 'extra', 'is already the user\'s');
    }
    if (picksLeft <= 0) throw StateError('No reward pick left to spend');
    return mutate(
      (d) => d.copyWith(avatarUnlocked: {...d.avatarUnlocked, extra}),
    );
  }

  /// Saves the avatar and motto (the motto exactly as typed, at most
  /// [kPersonaMottoMax] characters). Every extra the saved avatar wore, and
  /// every extra [avatar] wears, is kept for good: changing the look never
  /// takes one away. An extra the user doesn't own yet cannot be worn
  /// ([ArgumentError]; choose it with a pick first).
  Future<void> savePersona(Avatar avatar, {String motto = ''}) {
    if (motto.length > kPersonaMottoMax) {
      throw ArgumentError.value(motto, 'motto', 'too long');
    }
    for (final u in wornBy(avatar)) {
      if (!ownsExtra(u)) {
        throw ArgumentError.value(u, 'avatar', 'wears an extra not owned yet');
      }
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
