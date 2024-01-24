import 'dart:async';
import 'dart:collection';
import 'dart:core';
import 'dart:io';

class ProcessScheduler {
  final Queue<ProcessWrap> _processQueue = Queue();
  ProcessWrap? _currentProcess;
  int _getProcessId = 0;
  final StreamController<int> _streamController =
      StreamController<int>.broadcast();
  static final instance = ProcessScheduler._();
  ProcessScheduler._();

  void addProcess(ProcessWrap process) {
    _processQueue.add(process);
    if (_currentProcess == null) {
      _startNextProcess();
    }
    print(currentState());
    _streamController.add(_processQueue.length);
  }

  void removeProcess(ProcessWrap process) {
    if (_currentProcess == process) {
      process.kill();
      _currentProcess = null;
      _startNextProcess();
    } else {
      _processQueue.remove(process);
    }
    print(currentState());
    _streamController.add(_processQueue.length);
  }

  int getProcessId() {
    return _getProcessId++;
  }

  void _startNextProcess() {
    if (_currentProcess == null) {
      if (_processQueue.isNotEmpty) {
        _currentProcess = _processQueue.removeFirst();
        _currentProcess!.start();
        print(currentState());
        _streamController.add(_processQueue.length);
        _currentProcess!.waitOnDone.then((value) {
          _currentProcess = null;
          _startNextProcess();
        });
      }
    }
  }

  String currentState() {
    String state = _currentProcess?.name ?? 'idle';
    return "ProcessScheduler: $state with Queue ${_processQueue.map((e) => e.name).toList()}";
  }

  Stream<int> get queueLengthStream => _streamController.stream;
}

class ProcessWrap implements Process {
  final Completer<Process> _processAwaiter = Completer<Process>();
  final String executable;
  List<String> arguments;
  final String? workingDirectory;
  final Map<String, String>? environment;
  final bool includeParentEnvironment;
  final bool runInShell;
  final ProcessStartMode mode;
  final int id = ProcessScheduler.instance.getProcessId();
  Process? _process;

  ProcessWrap(this.executable, this.arguments,
      {this.workingDirectory,
      this.environment,
      this.includeParentEnvironment = true,
      this.runInShell = false,
      this.mode = ProcessStartMode.normal}) {
    ProcessScheduler.instance.addProcess(this);
  }

  void start() async {
    if (!hasStarted()) {
      print('started $name');
      _process = await Process.start(
        executable,
        arguments,
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
        runInShell: runInShell,
        mode: mode,
      );
      _processAwaiter.complete(_process);
    }
  }

  bool hasStarted() {
    return _process != null;
  }

  Future<void> get waitForReady async => await _processAwaiter.future;
  Future<void> get waitOnDone async => await exitCode;

  @override
  Future<int> get exitCode async {
    if (hasStarted()) {
      return _process!.exitCode;
    }
    Process p = await _processAwaiter.future;
    return p.exitCode;
  }

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    if (hasStarted()) {
      return _process!.kill(signal);
    }
    return false;
  }

  /// Only valid if the process has started.
  @override
  int get pid {
    if (hasStarted()) {
      return _process!.pid;
    }
    throw StateError('Process has not started yet.');
  }

  @override
  Stream<List<int>> get stderr => _handleStream((p) => p.stderr);

  @override
  IOSink get stdin {
    if (hasStarted()) {
      return _process!.stdin;
    }
    throw StateError('Process has not started yet.');
  }

  @override
  Stream<List<int>> get stdout => _handleStream((p) => p.stdout);

  Stream<List<int>> _handleStream(
      Stream<List<int>> Function(Process) selectStream) {
    if (hasStarted()) {
      return selectStream(_process!);
    }
    StreamController<List<int>> controller = StreamController<List<int>>();
    _waitForStream(controller, selectStream);
    return controller.stream;
  }

  void _waitForStream(StreamController<List<int>> controller,
      Stream<List<int>> Function(Process) selectStream) async {
    Process p = await _processAwaiter.future;
    selectStream(p).listen((event) {
      controller.add(event);
    }, onDone: () {
      controller.close();
    });
  }

  @override
  String toString() {
    return 'ProcessWrap{executable: $executable, arguments: $arguments, workingDirectory: $workingDirectory, environment: $environment, includeParentEnvironment: $includeParentEnvironment, runInShell: $runInShell, mode: $mode, _process: $_process}';
  }

  String get name => "$id ${arguments.join(' ')}";
}
