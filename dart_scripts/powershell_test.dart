import 'dart:io';

import 'package:winget_gui/helpers/log_stream.dart';

void main() async {
  Logger log = Logger('Powershell Test');
  LogStream.instance.toStdOut();
  ProcessResult p = await Process.run('powershell', ['Get-AppxPackage']);
  log.info(p.stdout);
}
