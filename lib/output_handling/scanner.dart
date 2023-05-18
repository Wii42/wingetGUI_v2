import 'package:winget_gui/output_handling/responsibility.dart';

abstract class Scanner {
  List<Responsibility> respList;

  Scanner(this.respList);
  void markResponsibleLines();
}