import 'package:flutter/material.dart';

import '../../state/app_state.dart';

/// The one-time invitation to play the Campaign, for users who started with
/// it off (a brand-new profile: `AppSettings.gameInvited` false). Shown by
/// Today and the Campaign hub while [CampaignInviteOps.campaignInvitePending];
/// "Play" and "Not now" both answer it for good
/// ([CampaignInviteOps.answerCampaignInvite]).
///
/// Placeholder: renders nothing until its body lands (it must also render
/// nothing once the invitation is answered).
class CampaignInviteCard extends StatelessWidget {
  const CampaignInviteCard({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// The invitation's state and answer, on top of [AppState.updateSettings].
extension CampaignInviteOps on AppState {
  /// Whether the invitation is still unanswered.
  bool get campaignInvitePending => !settings.gameInvited;

  /// Answers the invitation once and for all: [play] turns the Campaign on;
  /// "Not now" leaves it off (You › The Campaign can turn it on later).
  Future<void> answerCampaignInvite({required bool play}) => updateSettings(
    settings.copyWith(gameInvited: true, game: play ? true : null),
  );
}
