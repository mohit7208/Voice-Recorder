import 'package:ext_storage/ext_storage.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voicerecorder/colors/coolors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_recorder/audio_recorder.dart';

import 'dart:math';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'dart:async';

class RecordingScreen extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  RecordingScreen({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();
  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  Recording _recording = new Recording();
  bool _isRecording = false;
  Random random = new Random();
  TextEditingController _controller = new TextEditingController();
  String path;
  String filename;
  int num;
  String recordPath;
  String savepath;

  @override
  Widget build(BuildContext context) {
    var timerService = TimerService.of(context);

    Widget child;
    if (num == 1) {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Recording File Name:",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            filename == null ? '' : filename,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else if (num == 2) {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Recording stopped, file saved ",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "$filename",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Press the mic button",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            " to start recording",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: AnimatedBuilder(
                animation: timerService, // listen to ChangeNotifier
                builder: (context, child) {
                  // this part is rebuilt whenever notifyListeners() is called
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        ' ${timerService.currentDuration}',
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 140.0),
              child: Align(
                alignment: Alignment.center,
                child: child,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 50.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      _isRecording = !_isRecording;
                    });

                    // Request permissions.
                    Map<PermissionGroup, PermissionStatus> permissions =
                        await PermissionHandler().requestPermissions([
                      PermissionGroup.microphone,
                      PermissionGroup.storage,
                    ]);
                    if (permissions[PermissionGroup.microphone] !=
                        PermissionStatus.granted) {
                      showSnackBarMessage(
                          context, 'some error message about the microphone');
                      return;
                    }
                    if (permissions[PermissionGroup.storage] !=
                        PermissionStatus.granted) {
                      showSnackBarMessage(
                          context, 'some error message about storage');
                      return;
                    }
                    if (_isRecording) {
                      _start();
                      setState(() {
                        num = 1;
                        timerService.reset();
                        timerService.start();
                      });
                    } else {
                      _stop();
                      setState(() {
                        num = 2;
                        timerService.stop();
                      });
                    }
                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : Colors.teal[400],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5.0)),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.keyboard_voice,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _start() async {
    try {
      if (await AudioRecorder.hasPermissions) {
        savepath =
            (await ExtStorage.getExternalStorageDirectory()) + "/Recordings/";
        FileUtils.mkdir([savepath]);

        setState(() {
          DateFormat dateFormat = DateFormat("yyyy_MM_dd HH_mm_ss");
          String formatedDate = dateFormat.format(DateTime.now());
          filename = "Recording_" + formatedDate;
          recordPath = savepath;
          path = savepath + filename;
        });

        await AudioRecorder.start(
            path: path, audioOutputFormat: AudioOutputFormat.AAC);
        print("Start recording: $path");

        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    var recording = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    File file = widget.localFileSystem.file(recording.path);
    print("  File length: ${await file.length()}");
    setState(() {
      _recording = recording;
      _isRecording = isRecording;
    });
    _controller.text = recording.path;
  }

  showSnackBarMessage(BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(new SnackBar(content: Text(message)));
  }
}

class TimerService extends ChangeNotifier {
  Stopwatch _watch;
  Timer _timer;

  Duration get currentDuration => _currentDuration;
  Duration _currentDuration = Duration.zero;

  bool get isRunning => _timer != null;

  TimerService() {
    _watch = Stopwatch();
  }

  void _onTick(Timer timer) {
    _currentDuration = _watch.elapsed;

    // notify all listening widgets
    notifyListeners();
  }

  void start() {
    if (_timer != null) return;

    _timer = Timer.periodic(Duration(seconds: 1), _onTick);
    _watch.start();

    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _watch.stop();
    _currentDuration = _watch.elapsed;

    notifyListeners();
  }

  void reset() {
    stop();
    _watch.reset();
    _currentDuration = Duration.zero;

    notifyListeners();
  }

  static TimerService of(BuildContext context) {
    var provider = context.inheritFromWidgetOfExactType(TimerServiceProvider)
        as TimerServiceProvider;
    return provider.service;
  }
}

class TimerServiceProvider extends InheritedWidget {
  const TimerServiceProvider({Key key, this.service, Widget child})
      : super(key: key, child: child);

  final TimerService service;

  @override
  bool updateShouldNotify(TimerServiceProvider old) => service != old.service;
}
