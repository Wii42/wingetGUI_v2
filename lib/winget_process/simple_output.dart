import 'package:fluent_ui/fluent_ui.dart';

import 'task_result_skeleton.dart';

abstract class SimpleOutput<T extends Object> extends TaskResultSkeleton<T> {
  const SimpleOutput({super.key, required super.task});

  @override
  Widget buildPage(AsyncSnapshot<T> streamSnapshot, BuildContext context) {
    return Column(children: outputList(streamSnapshot, context));
  }
}

class SimpleStringOutput extends SimpleOutput<List<String>> with TextListMixin {
  const SimpleStringOutput({super.key, required super.task});
}
