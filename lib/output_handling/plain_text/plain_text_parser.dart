import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/string_list_extension.dart';
import 'package:winget_gui/output_handling/output_builder.dart';

import '../../widget_assets/link_text.dart';
import '../output_parser.dart';

class PlainTextParser extends OutputParser {
  PlainTextParser(super.lines);

  @override
  FutureOr<OutputBuilder>? parse(AppLocalizations wingetLocale) {
    lines.trim();
    if (lines.isEmpty) {
      return null;
    }
    return QuickOutputBuilder(
      (context) => Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (String line in lines) LinkText(line: line),
          ],
        ),
      ),
    );
  }
}