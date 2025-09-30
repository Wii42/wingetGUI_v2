import 'package:collection/collection.dart';

import '../../winget_process/winget_process_scheduler.dart';
import '../winget_client.dart';
import '../winget_command.dart';

mixin ProcessSchedulerMixin on WingetClient{
  @override
  Stream<int> runningCommandsLength(CmdRunningCommands cmd) {
    return ProcessScheduler.instance.queueLengthStream;
  }

  @override
  Future<void> cancelTask(int taskId) {
    ProcessWrap? p = ProcessScheduler.instance.runningProcesses
        .firstWhereOrNull((a) => a.id == taskId);
    if (p != null) {
      ProcessScheduler.instance.removeProcess(p);
    }
    return Future.value();
  }

  @override
  Future<void> cancelAllTasks() {
    return ProcessScheduler.instance.killAllProcesses();
  }
}