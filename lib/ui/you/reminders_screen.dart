import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/local_date.dart';
import '../../l10n/app_localizations.dart';
import '../../services/file_share.dart';
import '../../services/ics_export.dart';
import '../../state/app_state.dart';
import '../journal/journal_kit.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';

/// The calendar file's words in the user's language (F-018).
CalendarTexts calendarTexts(AppLocalizations l) => CalendarTexts(
  calendarName: l.youCalendarName,
  eventTitle: l.youCalendarEventTitle,
  description: l.youCalendarEventDescription,
);

/// The six daytime check-ins (F-016–F-018).
///
/// * Notifications are opt-in: the switch asks for permission and turns on
///   only when it is granted. Denied or unavailable → the switch stays off,
///   says so honestly, and offers the calendar file instead.
/// * Six rows: prompt title, local time (device clock format, edited with
///   the system time picker), a per-row switch and the source default.
/// * Quiet hours (start/end, clearable).
/// * "Add to calendar (.ics)": the switched-on check-ins for 30 days through
///   the share sheet.
/// Notifications and the calendar carry only prompt titles, never the
/// user's words.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  /// The answer to the last permission request made on this screen.
  ReminderPermission? _permission;
  bool _busy = false;

  Future<void> _toggle(bool on) async {
    final state = context.read<AppState>();
    setState(() => _busy = true);
    try {
      if (on) {
        final result = await state.enableReminders();
        if (mounted) setState(() => _permission = result);
      } else {
        await state.disableReminders();
        if (mounted) setState(() => _permission = null);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<TimeOfDay?> _pickTime(String hhmm, {String? helpText}) {
    final (hour, minute) = parseClock(hhmm);
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      helpText: helpText,
    );
  }

  Future<void> _editTime(ReminderPreference pref, String title) async {
    final state = context.read<AppState>();
    final picked = await _pickTime(pref.time, helpText: title);
    if (picked == null) return;
    await state.setReminder(
      pref.copyWith(time: formatClock(picked.hour, picked.minute)),
    );
  }

  Future<void> _editQuiet({required bool start}) async {
    final state = context.read<AppState>();
    final l = AppLocalizations.of(context);
    final s = state.settings;
    final current = start ? s.quietStart : s.quietEnd;
    final picked = await _pickTime(
      current ?? (start ? '22:00' : '07:00'),
      helpText: start ? l.youRemindersQuietFrom : l.youRemindersQuietUntil,
    );
    if (picked == null) return;
    final value = formatClock(picked.hour, picked.minute);
    final settings = state.settings;
    await state.updateSettings(
      start
          ? settings.copyWith(quietStart: () => value)
          : settings.copyWith(quietEnd: () => value),
    );
  }

  Future<void> _clearQuiet() {
    final state = context.read<AppState>();
    return state.updateSettings(
      state.settings.copyWith(quietStart: () => null, quietEnd: () => null),
    );
  }

  Future<void> _shareCalendar() async {
    final state = context.read<AppState>();
    final files = context.read<FileShare>();
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    try {
      final outcome = await files.shareTextFile(
        kIcsFileName,
        state.calendarExport(calendarTexts(l)),
        kIcsMimeType,
      );
      final message = switch (outcome) {
        ShareOutcome.shared => l.youRemindersCalendarShared,
        ShareOutcome.dismissed => l.youShareDismissed,
        ShareOutcome.unavailable => l.shareFailed,
      };
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l.shareFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final settings = state.settings;
    final enabled = settings.remindersEnabled;
    final prefs = state.reminders;
    final anyOn = prefs.any((r) => r.enabled);
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
    );

    final blocked =
        !enabled &&
        (_permission == ReminderPermission.denied ||
            _permission == ReminderPermission.unavailable);
    final scheduleFailed = enabled && state.reminderError != null;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AreaListView(
          children: [
            ScreenHeader(
              title: l.youRemindersTitle,
              subtitle: l.youRemindersSubtitle,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 16),
            ),
            SectionCard(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    key: const ValueKey('reminders-enabled'),
                    secondary: const Icon(Icons.notifications_none),
                    title: Text(l.youRemindersSwitch),
                    subtitle: Text(
                      enabled
                          ? l.youRemindersSwitchOn
                          : l.youRemindersSwitchOff,
                    ),
                    value: enabled,
                    onChanged: _busy ? null : _toggle,
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: p.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.youRemindersPrivacy,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (blocked || scheduleFailed) ...[
              const SizedBox(height: 12),
              _Notice(
                key: const ValueKey('reminders-blocked'),
                title: scheduleFailed
                    ? null
                    : _permission == ReminderPermission.unavailable
                    ? l.youRemindersUnavailableTitle
                    : l.youRemindersDeniedTitle,
                body: scheduleFailed
                    ? l.youRemindersScheduleFailed
                    : _permission == ReminderPermission.unavailable
                    ? l.youRemindersUnavailableBody
                    : l.youRemindersDeniedBody,
                actions: [
                  if (scheduleFailed ||
                      _permission == ReminderPermission.denied)
                    TextLinkButton(
                      label: l.tryAgain,
                      icon: Icons.refresh,
                      onPressed: _busy ? null : () => _toggle(true),
                    ),
                  TextLinkButton(
                    key: const ValueKey('reminders-calendar-instead'),
                    label: l.youRemindersCalendarInstead,
                    icon: Icons.event_outlined,
                    onPressed: anyOn ? _shareCalendar : null,
                  ),
                ],
              ),
            ],
            AreaSectionLabel(l.youRemindersTimesTitle),
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 12),
              child: Text(l.youRemindersTimesBody, style: secondary),
            ),
            SectionCard(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, pref) in prefs.indexed) ...[
                    if (i > 0)
                      Divider(color: p.border, indent: 16, endIndent: 16),
                    _CheckinRow(
                      pref: pref,
                      title:
                          state.content.prompt(pref.promptId)?.title ??
                          pref.promptId,
                      defaultTime: state.content
                          .prompt(pref.promptId)
                          ?.defaultTime,
                      onEditTime: _editTime,
                      onChanged: (p) => state.setReminder(p),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.bedtime_outlined,
              title: l.youRemindersQuietTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.youRemindersQuietBody, style: secondary),
                  const SizedBox(height: 8),
                  _QuietRow(
                    key: const ValueKey('quiet-start'),
                    label: l.youRemindersQuietFrom,
                    value: settings.quietStart,
                    onTap: () => _editQuiet(start: true),
                  ),
                  _QuietRow(
                    key: const ValueKey('quiet-end'),
                    label: l.youRemindersQuietUntil,
                    value: settings.quietEnd,
                    onTap: () => _editQuiet(start: false),
                  ),
                  if ((settings.quietStart == null) !=
                      (settings.quietEnd == null))
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: p.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l.youRemindersQuietIncomplete,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (settings.quietStart != null || settings.quietEnd != null)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextLinkButton(
                        key: const ValueKey('quiet-clear'),
                        label: l.youRemindersQuietClear,
                        icon: Icons.close,
                        onPressed: _clearQuiet,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              icon: Icons.event_outlined,
              title: l.youRemindersCalendarTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.youRemindersCalendarBody, style: secondary),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    key: const ValueKey('reminders-calendar'),
                    label: l.youRemindersCalendarButton,
                    icon: Icons.ios_share,
                    expand: true,
                    onPressed: anyOn ? _shareCalendar : null,
                  ),
                  if (!anyOn) ...[
                    const SizedBox(height: 8),
                    Text(
                      l.youRemindersCalendarNone,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One check-in: title + on/off switch, then its time and the source default.
class _CheckinRow extends StatelessWidget {
  const _CheckinRow({
    required this.pref,
    required this.title,
    required this.defaultTime,
    required this.onEditTime,
    required this.onChanged,
  });

  final ReminderPreference pref;
  final String title;
  final String? defaultTime;
  final Future<void> Function(ReminderPreference, String) onEditTime;
  final ValueChanged<ReminderPreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final time = formatHhmm(context, pref.time);
    final source = defaultTime == null
        ? null
        : formatHhmm(context, defaultTime!);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MergeSemantics(
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: l.youRemindersRowLabel(title, time),
                    excludeSemantics: true,
                    child: Text(title, style: theme.textTheme.titleSmall),
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  key: ValueKey('reminder-switch-${pref.promptId}'),
                  value: pref.enabled,
                  onChanged: (v) => onChanged(pref.copyWith(enabled: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Semantics(
                label: l.youRemindersChangeTime(title, time),
                button: true,
                excludeSemantics: true,
                child: OutlinedButton.icon(
                  key: ValueKey('reminder-time-${pref.promptId}'),
                  onPressed: () => onEditTime(pref, title),
                  icon: const Icon(Icons.schedule, size: 18),
                  label: Text(time),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(48, 44),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
              if (source != null)
                Text(
                  l.youRemindersSourceDefault(source),
                  style: theme.textTheme.bodySmall,
                ),
              if (defaultTime != null && pref.time != defaultTime)
                TextLinkButton(
                  key: ValueKey('reminder-default-${pref.promptId}'),
                  label: l.youRemindersUseDefault(source!),
                  onPressed: () => onChanged(pref.copyWith(time: defaultTime)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuietRow extends StatelessWidget {
  const _QuietRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final shown = value == null
        ? l.youRemindersQuietNotSet
        : formatHhmm(context, value!);
    return Semantics(
      button: true,
      label: '$label: $shown',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 4,
              vertical: 8,
            ),
            child: Row(
              children: [
                Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
                const SizedBox(width: 8),
                Flexible(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      shown,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: value == null ? p.textSecondary : p.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: p.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// An honest warning box with practical next steps.
class _Notice extends StatelessWidget {
  const _Notice({
    super.key,
    required this.body,
    required this.actions,
    this.title,
  });

  final String? title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 8),
        decoration: BoxDecoration(
          color: p.warningContainer,
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
          border: Border.all(color: p.warning),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  color: p.onWarningContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title ?? body,
                    style:
                        (title == null
                                ? theme.textTheme.bodyMedium
                                : theme.textTheme.titleSmall)
                            ?.copyWith(color: p.onWarningContainer),
                  ),
                ),
              ],
            ),
            if (title != null) ...[
              const SizedBox(height: 6),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: p.textPrimary,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Wrap(spacing: 8, runSpacing: 0, children: actions),
          ],
        ),
      ),
    );
  }
}
