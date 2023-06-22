import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/content/content_holder.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/history_entry.dart';
import 'package:winget_gui/widget_assets/scroll_list_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'content/content_snapshot.dart';

class HistoryTab extends PaneItem {
  HistoryTab._({
    required super.icon,
    required super.body,
    super.title,
  });

  factory HistoryTab(ContentHolder contentHolder, AppLocalizations local) {
    return HistoryTab._(
      title: Text(local.history),
      icon: const Icon(FluentIcons.history),
      body: ScrollListWidget(
        title: 'History',
        listElements: [
          for (ContentSnapshot snapshot in contentHolder.stack.asList.reversed)
            HistoryEntry(snapshot: snapshot, content: contentHolder.content)
        ].withSpaceBetween(height: 10),
      ),
    );
  }
}
