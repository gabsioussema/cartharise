import 'package:flutter/material.dart';

import '../../domain/app_data.dart';
import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';

/// What each Compass field is called and how it is explained (F-023).
class CompassFieldCopy {
  const CompassFieldCopy({
    required this.title,
    required this.help,
    required this.hint,
    required this.icon,
    this.glyph,
  });

  final String title;

  /// The one-line explanation under the title.
  final String help;
  final String hint;

  /// Monochrome, tinted with the accent token.
  final IconData icon;

  /// The visual system's glyph for this field's idea, shown instead of
  /// [icon] where a widget fits (Boundaries: the shelter).
  final CarthaGlyph? glyph;

  /// The field's mark: its [glyph] when it has one, else its [icon].
  Widget mark(BuildContext context, {double size = 24}) => glyph == null
      ? Icon(icon, color: CarthaPalette.of(context).accent, size: size)
      : GlyphIcon(glyph!, size: size);

  static CompassFieldCopy of(AppLocalizations l, CompassField field) =>
      switch (field) {
        CompassField.antiVision => CompassFieldCopy(
          title: l.compassFieldAntiVision,
          help: l.compassFieldAntiVisionHelp,
          hint: l.compassFieldAntiVisionHint,
          icon: Icons.do_not_disturb_on_outlined,
        ),
        CompassField.vision => CompassFieldCopy(
          title: l.compassFieldVision,
          help: l.compassFieldVisionHelp,
          hint: l.compassFieldVisionHint,
          icon: Icons.wb_twilight_outlined,
        ),
        CompassField.yearGoal => CompassFieldCopy(
          title: l.compassFieldYearGoal,
          help: l.compassFieldYearGoalHelp,
          hint: l.compassFieldYearGoalHint,
          icon: Icons.flag_outlined,
        ),
        CompassField.monthProject => CompassFieldCopy(
          title: l.compassFieldMonthProject,
          help: l.compassFieldMonthProjectHelp,
          hint: l.compassFieldMonthProjectHint,
          icon: Icons.calendar_month_outlined,
        ),
        CompassField.dailyLevers => CompassFieldCopy(
          title: l.compassFieldDailyLevers,
          help: l.compassFieldDailyLeversHelp,
          hint: l.compassFieldDailyLeversHint,
          icon: Icons.bolt_outlined,
        ),
        CompassField.constraints => CompassFieldCopy(
          title: l.compassFieldConstraints,
          help: l.compassFieldConstraintsHelp,
          hint: l.compassFieldConstraintsHint,
          icon: Icons.shield_outlined,
          glyph: CarthaGlyph.boundaries,
        ),
      };
}

/// Why a Compass version exists, in the user's words.
String compassVersionReason(AppLocalizations l, CompassVersionReason r) =>
    switch (r) {
      CompassVersionReason.manual => l.compassVersionReasonManual,
      CompassVersionReason.beforeImport => l.compassVersionReasonBeforeImport,
      CompassVersionReason.beforeRestore => l.compassVersionReasonBeforeRestore,
    };
