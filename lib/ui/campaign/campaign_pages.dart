import 'package:flutter/material.dart';

import '../../domain/content.dart';
import 'battle_log_screen.dart';
import 'chapters_screen.dart';
import 'collection_screen.dart';
import 'make_it_yours_screen.dart';
import 'notice_screen.dart';
import 'route_screen.dart';
import 'try_screen.dart';

/// The Campaign's own pages, opened from the hub (and from elsewhere through
/// `AppNav.openCampaignPage`).
enum CampaignPage {
  /// The Playground's "Notice": cards that open a question or a lesson.
  notice,

  /// The Playground's "Try": one tiny experiment at a time.
  tryIt,

  /// The avatar, the motto and "Choose your reward".
  makeItYours,

  /// Hannibal's route, the strategist's map and the 30-day practice.
  route,

  /// Act I: the five chapters of the one-day reset.
  chapters,

  /// The monthly boss and its battle log.
  battleLog,

  /// Keepsakes: experiments tried, achievements, extras chosen.
  collection,
}

/// The screen for [page].
Widget campaignPageScreen(CampaignPage page) => switch (page) {
  CampaignPage.notice => const NoticeScreen(),
  CampaignPage.tryIt => const TryScreen(),
  CampaignPage.makeItYours => const MakeItYoursScreen(),
  CampaignPage.route => const CampaignRouteScreen(),
  CampaignPage.chapters => const ChaptersScreen(),
  CampaignPage.battleLog => const BattleLogScreen(),
  CampaignPage.collection => const CollectionScreen(),
};

/// Pushes [screen] above the shell (full screen, like other detail pages).
Future<void> pushCampaignScreen(BuildContext context, Widget screen) =>
    Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => screen));

/// Opens "Try" at [chapter]'s first experiment not tried yet.
Future<void> openTryFor(BuildContext context, CampaignChapter chapter) =>
    pushCampaignScreen(context, TryScreen(chapter: chapter));
