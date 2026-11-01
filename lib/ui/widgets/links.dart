import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

/// Opens [uri] in the browser / external app — the only outbound action in
/// Cartharise (credited source links, help-line directory). On failure shows
/// an honest snackbar with the address so the user can open it themselves.
/// Returns whether the link was opened.
Future<bool> openExternalLink(BuildContext context, Uri uri) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final message = AppLocalizations.of(context).linkOpenFailed(uri.toString());
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Object {
    opened = false;
  }
  if (!opened) {
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }
  return opened;
}
