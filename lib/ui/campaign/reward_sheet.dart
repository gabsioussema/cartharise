import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../persona/avatar_view.dart';
import '../persona/builder_options.dart';
import '../persona/persona_copy.dart';
import '../persona/persona_ops.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'campaign_ops.dart';

/// The avatar part an extra puts on (its banner, garment colour, headwear
/// or carried item): `requirementOf(extraPart(u)) == u`.
Enum extraPart(Unlockable u) => switch (u) {
  Unlockable.sigilPath => Sigil.path,
  Unlockable.garmentSage => GarmentColor.sage,
  Unlockable.headwearCirclet => Headwear.circlet,
  Unlockable.accessoryCompass => Accessory.compass,
  Unlockable.sigilStar => Sigil.star,
  Unlockable.headwearLaurel => Headwear.laurel,
  Unlockable.accessoryScroll => Accessory.scroll,
  Unlockable.sigilCompass => Sigil.compass,
  Unlockable.garmentIndigo => GarmentColor.indigo,
  Unlockable.garmentCrimson => GarmentColor.crimson,
  Unlockable.accessoryAmulet => Accessory.amulet,
  Unlockable.garmentBronze => GarmentColor.bronze,
  Unlockable.sigilLaurel => Sigil.laurel,
};

/// [avatar] wearing extra [u] — a preview only; nothing is saved.
Avatar avatarWearing(Avatar avatar, Unlockable u) => switch (extraPart(u)) {
  final Sigil s => avatar.copyWith(sigil: s),
  final GarmentColor c => avatar.copyWith(garmentColor: c),
  final Headwear h => avatar.copyWith(headwear: h),
  final Accessory a => avatar.copyWith(accessory: a),
  _ => avatar,
};

/// The kind of extra [u] is, as the builder names its category ("Banner",
/// "Carry", "Headwear", "Colour").
String extraKind(AppLocalizations l, Unlockable u) => switch (extraPart(u)) {
  Sigil() => l.personaCategorySigil,
  GarmentColor() => l.personaCategoryGarmentColor,
  Headwear() => l.personaCategoryHeadwear,
  Accessory() => l.personaCategoryAccessory,
  _ => '',
};

/// "Choose your reward": spends one reward pick on the extra the user
/// picks, previewed on their own avatar (the suggested extra first and
/// preselected). Says honestly when the choice didn't reach the phone's
/// storage. With the Campaign off, or no pick left, it explains instead.
Future<void> showRewardSheet(BuildContext context) async {
  final state = context.read<AppState>();
  final messenger = ScaffoldMessenger.maybeOf(context);
  final chosen = await showModalBottomSheet<Unlockable>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // Reduced motion (device or Settings › Motion): no slide.
    sheetAnimationStyle: motionEnabled(context)
        ? null
        : AnimationStyle.noAnimation,
    builder: (_) => const RewardSheet(),
  );
  if (chosen == null || !context.mounted) return;
  final l = AppLocalizations.of(context);
  messenger?.hideCurrentSnackBar();
  if (state.saveStatus == SaveStatus.failed) {
    messenger?.showSnackBar(SnackBar(content: Text(l.campaignNotSavedYet)));
    return;
  }
  messenger?.showSnackBar(
    SnackBar(
      content: Text(l.campaignRewardChosen(unlockableName(l, chosen))),
      action: SnackBarAction(
        label: l.campaignRewardWear,
        onPressed: () {
          if (context.mounted) AppNav.openPersonaBuilder(context);
        },
      ),
    ),
  );
}

class RewardSheet extends StatefulWidget {
  const RewardSheet({super.key});

  @override
  State<RewardSheet> createState() => _RewardSheetState();
}

class _RewardSheetState extends State<RewardSheet> {
  Unlockable? _selected;
  bool _busy = false;

  Future<void> _choose(Unlockable extra) async {
    final state = context.read<AppState>();
    setState(() => _busy = true);
    try {
      await state.chooseReward(extra);
    } on Object {
      // The pick or the extra changed meanwhile (e.g. the game was turned
      // off): nothing was spent; the sheet shows what is true now.
      if (mounted) setState(() => _busy = false);
      return;
    }
    if (mounted) Navigator.of(context).pop(extra);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final choices = state.rewardChoices;
    final picks = state.picksLeft;
    final title = Semantics(
      header: true,
      child: Text(l.campaignRewardTitle, style: theme.textTheme.titleLarge),
    );
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
    );

    if (!state.gameEnabled || picks == 0 || choices.isEmpty) {
      final next = nextPickReason(l, state.campaign);
      return SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            title,
            const SizedBox(height: 8),
            Text(
              !state.gameEnabled
                  ? l.campaignRewardGameOff
                  : choices.isEmpty
                  ? l.campaignExtrasAll
                  : l.campaignRewardNone,
              key: const ValueKey('reward-unavailable'),
              style: secondary,
            ),
            if (state.gameEnabled && choices.isNotEmpty && next != null) ...[
              const SizedBox(height: 4),
              Text(next, style: secondary),
            ],
            const SizedBox(height: 16),
            SecondaryButton(
              label: l.close,
              expand: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }

    final suggested = choices.first;
    final selected = choices.contains(_selected) ? _selected! : suggested;
    final base = state.persona?.avatar ?? const Avatar();
    final name = unlockableName(l, selected);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                title,
                const SizedBox(height: 4),
                Text(l.campaignRewardPicks(picks), style: secondary),
                const SizedBox(height: 16),
                Center(
                  child: AvatarView(
                    key: const ValueKey('reward-preview'),
                    avatar: avatarWearing(base, selected),
                    size: 112,
                    semanticLabel: l.campaignRewardPreviewLabel(name),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _OptionGrid(
                  label: l.campaignRewardTitle,
                  children: [
                    for (final u in choices)
                      BuilderOptionTile(
                        key: ValueKey('reward-option-${u.name}'),
                        label: unlockableName(l, u),
                        swatch: optionSwatch(extraPart(u)),
                        selected: u == selected,
                        // The kind tells the two "Compass" extras apart.
                        note: u == suggested
                            ? l.campaignRewardSuggested(extraKind(l, u))
                            : extraKind(l, u),
                        preview: AvatarView(
                          avatar: avatarWearing(base, u),
                          size: kOptionPortrait,
                          showSigil: extraPart(u) is Sigil,
                          excludeFromSemantics: true,
                        ),
                        onTap: _busy
                            ? null
                            : () => setState(() => _selected = u),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: p.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
              child: PrimaryButton(
                key: const ValueKey('reward-confirm'),
                label: l.campaignRewardChoose(name),
                icon: Icons.check,
                expand: true,
                busy: _busy,
                onPressed: () => _choose(selected),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The options as rows of equal tiles, wider as the text grows (2–5 per
/// row), each row as tall as its tallest tile.
class _OptionGrid extends StatelessWidget {
  const _OptionGrid({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minTile = 92 * math.min(scale, 1.6);
          final columns = (constraints.maxWidth / minTile).floor().clamp(2, 5);
          const gap = 8.0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var row = 0; row < children.length; row += columns) ...[
                if (row > 0) const SizedBox(height: gap),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = row; i < row + columns; i++) ...[
                        if (i > row) const SizedBox(width: gap),
                        Expanded(
                          child: i < children.length
                              ? children[i]
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
