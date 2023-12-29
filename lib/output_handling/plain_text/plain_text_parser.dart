import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/string_list_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/output_builder.dart';

import '../../widget_assets/link_text.dart';
import '../output_parser.dart';
import '../parsed_output.dart';

class PlainTextParser extends OutputParser {
  PlainTextParser(super.lines);

  @override
  ParsedPlainText parse(AppLocalizations wingetLocale) {
    lines.trim();
    if(lines.isEmpty){
      return ParsedPlainText([]);
    }
    return ParsedPlainText(lines.trim(),
        lastIsSuccessMessage: isSuccessMessage(lines.last, wingetLocale));
  }

  bool isSuccessMessage(String line, AppLocalizations locale) {
    return (line == locale.installSuccessful ||
        line == locale.uninstallSuccessful);
  }
}

class ParsedPlainText extends ParsedOutput {
  List<String> lines;
  bool lastIsSuccessMessage;

  ParsedPlainText(this.lines, {this.lastIsSuccessMessage = false});

  @override
  OutputBuilder? widgetRepresentation() {
    if (lines.isEmpty) {
      return null;
    }
    return QuickOutputBuilder((context) {
      return Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for ((int, String) line in lines.indexed)
              (line.$1 == lines.length - 1 && lastIsSuccessMessage)
                  ? InfoBar(
                      title: Text(line.$2),
                      severity: InfoBarSeverity.success,
                    )
                  : LinkText(line: line.$2),
          ].withSpaceBetween(height: 10),
        ),
      );
    });
  }

  @override
  String toString() {
    return "ParsedPlainText{$lines}";
  }
}
