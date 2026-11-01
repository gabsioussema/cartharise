import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../widgets/stub_screen.dart';

/// STUB (Foundation) — Reset agent. Owner replaces the body and keeps the class name
/// and constructor (PLAN.md §6).
class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) => StubScreen(
    title:
        context.read<AppState>().content.lesson(lessonId)?.title ??
        AppLocalizations.of(context).stubComingSoonTitle,
    pushed: true,
  );
}
