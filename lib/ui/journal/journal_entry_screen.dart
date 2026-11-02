import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../state/attachment_ops.dart';
import '../media/attachment_strip.dart';
import '../theme/cartha_theme.dart';
import '../voice/dictate_button.dart';
import '../widgets/widgets.dart';
import 'journal_kit.dart';

/// One free-form journal note (F-032): optional title, body autosaved while
/// typing (debounced, flushed when leaving or when the app goes to the
/// background), written/edited timestamps and delete with confirmation.
///
/// A new note ([entryId] null) is only created once something is typed (or
/// a photo or voice note is added), so opening and closing the editor never
/// leaves an empty note behind. Words are saved exactly as typed.
///
/// Media (step 2): photos and voice notes under the note
/// ([AttachmentStrip]); selected words can be pinned as the Journal's
/// pinned memory (**Pin** in the selection menu or the app bar), exactly as
/// written.
class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({super.key, this.entryId});

  /// Null = a new note.
  final String? entryId;

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  late final AppState _state;
  late final TextEditingController _title;
  late final TextEditingController _body;
  late final Autosaver _autosave;
  final _bodyFocus = FocusNode();

  /// The saved note's id; null until a new note is first saved.
  String? _id;
  Future<JournalEntry>? _creating;
  bool _missing = false;
  bool _deleted = false;

  @override
  void initState() {
    super.initState();
    _state = context.read<AppState>();
    _id = widget.entryId;
    final entry = _id == null ? null : _state.journalEntryById(_id!);
    _missing = _id != null && entry == null;
    _title = TextEditingController(text: entry?.title ?? '');
    _body = TextEditingController(text: entry?.body ?? '');
    _autosave = Autosaver(_save);
  }

  @override
  void dispose() {
    _autosave.dispose();
    _title.dispose();
    _body.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  bool get _hasText =>
      _title.text.trim().isNotEmpty || _body.text.trim().isNotEmpty;

  void _changed() {
    _autosave.schedule();
    setState(() {});
  }

  Future<void> _save() async {
    if (_missing || _deleted) return;
    // Read the fields now: the screen may be closing.
    final title = _title.text.trim().isEmpty ? null : _title.text;
    final body = _body.text;
    final hasText = _hasText;
    if (_id == null && _creating != null) await _creating;
    if (_deleted) return;
    final id = _id;
    if (id == null) {
      if (!hasText) return;
      final creating = _state.addJournalEntry(title: title, body: body);
      _creating = creating;
      _id = (await creating).id;
      if (mounted) setState(() {});
      return;
    }
    final current = _state.journalEntryById(id);
    if (current == null) return;
    if (current.title == title && current.body == body) return;
    await _state.updateJournalEntry(
      JournalEntry(
        id: id,
        title: title,
        body: body,
        createdAt: current.createdAt,
      ),
    );
  }

  /// Puts a photo or recording on this note, creating the note first when
  /// nothing was typed yet (with whatever is in the fields now). False when
  /// that couldn't be saved on the phone yet.
  Future<bool> _addToNote(Attachment attachment) async {
    if (_id == null && _creating != null) await _creating;
    final id = _id;
    if (id != null) {
      await _state.addAttachment(AttachmentHolder.journal, id, attachment);
    } else {
      _autosave.cancel();
      final creating = _state.addJournalEntry(
        title: _title.text.trim().isEmpty ? null : _title.text,
        body: _body.text,
        attachments: [attachment],
      );
      _creating = creating;
      _id = (await creating).id;
      if (mounted) setState(() {});
    }
    return _state.saveStatus != SaveStatus.failed;
  }

  /// The selected words of [c], without the spaces around them (still the
  /// user's exact words), or null.
  static String? _selected(TextEditingController c) {
    final sel = c.selection;
    if (!sel.isValid || sel.isCollapsed) return null;
    final words = sel.textInside(c.text).trim();
    return words.isEmpty ? null : words;
  }

  /// Pins the selected words as the Journal's pinned memory, exactly as
  /// written (saved first, so the pin quotes the saved note).
  Future<void> _pinSelection() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    void say(String text) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text(text)));
    }

    final words = _selected(_body) ?? _selected(_title);
    if (words == null) {
      say(l.mediaPinSelectFirst);
      return;
    }
    _autosave.cancel();
    await _save();
    final id = _id;
    if (id == null) {
      say(l.mediaPinSelectFirst);
      return;
    }
    try {
      await _state.pinMemory(
        kind: PinnedKind.passage,
        sourceId: id,
        excerpt: words,
      );
    } on ArgumentError {
      say(l.mediaPinNotFound);
      return;
    }
    say(
      _state.saveStatus == SaveStatus.failed
          ? l.mediaPinnedNotSaved
          : l.mediaPinned,
    );
  }

  /// The selection menu, with **Pin** first while words are selected.
  Widget _selectionMenu(BuildContext context, EditableTextState editable) {
    final l = AppLocalizations.of(context);
    final items = [...editable.contextMenuButtonItems];
    if (!_missing && !editable.textEditingValue.selection.isCollapsed) {
      items.insert(
        0,
        ContextMenuButtonItem(
          label: l.mediaPinWords,
          onPressed: () {
            ContextMenuController.removeAny();
            _pinSelection();
          },
        ),
      );
    }
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editable.contextMenuAnchors,
      buttonItems: items,
    );
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final hasMedia =
        _id != null &&
        (_state.journalEntryById(_id!)?.attachments.isNotEmpty ?? false);
    final ok = await confirmDialog(
      context,
      title: l.journalEntryDeleteTitle,
      body: hasMedia ? l.mediaNoteDeleteBody : l.journalEntryDeleteBody,
      action: l.delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    _autosave.cancel();
    _deleted = true;
    if (_creating != null) await _creating;
    final id = _id;
    if (id != null) await _state.deleteJournalEntry(id);
    messenger.showSnackBar(SnackBar(content: Text(l.journalEntryDeleted)));
    if (mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final entry = context.select<AppState, JournalEntry?>(
      (s) => _id == null ? null : s.journalEntryById(_id!),
    );
    final canDelete = !_missing && (_id != null || _hasText);
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!_missing)
            IconButton(
              key: const ValueKey('journal-entry-pin'),
              tooltip: l.mediaPinWordsTooltip,
              icon: const Icon(Icons.push_pin_outlined),
              onPressed: _pinSelection,
            ),
          if (canDelete)
            IconButton(
              key: const ValueKey('journal-entry-delete'),
              tooltip: l.journalEntryDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _missing
            ? AreaListView(
                children: [
                  EmptyState(
                    icon: Icons.menu_book_outlined,
                    title: l.journalEntryMissingTitle,
                    body: l.journalEntryMissingBody,
                  ),
                ],
              )
            : AreaListView(
                children: [
                  ScreenHeader(
                    title: widget.entryId == null
                        ? l.journalEntryNewTitle
                        : l.journalEntryTitle,
                    subtitle: l.journalEntryPrivacy,
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 16),
                  ),
                  TextField(
                    key: const ValueKey('journal-entry-title'),
                    controller: _title,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    style: theme.textTheme.titleMedium,
                    decoration: InputDecoration(
                      labelText: l.journalEntryTitleField,
                    ),
                    contextMenuBuilder: _selectionMenu,
                    onChanged: (_) => _changed(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const ValueKey('journal-entry-body'),
                    controller: _body,
                    focusNode: _bodyFocus,
                    autofocus: widget.entryId == null,
                    minLines: 8,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l.journalEntryBodyField,
                      hintText: l.journalEntryBodyHint,
                      alignLabelWithHint: true,
                    ),
                    contextMenuBuilder: _selectionMenu,
                    onChanged: (_) => _changed(),
                  ),
                  DictateButton(
                    key: const ValueKey('journal-entry-dictate'),
                    controller: _body,
                    focusNode: _bodyFocus,
                    onInserted: (_) => _changed(),
                    recordInstead: _addToNote,
                  ),
                  const SizedBox(height: 8),
                  AttachmentStrip(
                    holder: AttachmentHolder.journal,
                    entryId: _id,
                    createWith: _addToNote,
                    onWriteInstead: _bodyFocus.requestFocus,
                  ),
                  const SizedBox(height: 12),
                  const SaveIndicator(),
                  if (entry != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      l.journalEntryWritten(
                        formatDayTime(context, entry.createdAt),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                    if (entry.editedAt != null)
                      Text(
                        l.journalEntryEdited(
                          formatDayTime(context, entry.editedAt!),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                  ],
                ],
              ),
      ),
    );
  }
}
