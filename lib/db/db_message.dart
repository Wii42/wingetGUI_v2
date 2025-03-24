import 'package:winget_gui/l10n/generated/app_localizations.dart';

typedef LocalizedString = String Function(AppLocalizations);

class DBMessage {
  final DBStatus status;
  final LocalizedString? message;

  DBMessage(this.status, {this.message});
}

enum DBStatus { loading, ready, error }
