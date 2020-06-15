import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:voicerecorder/colors/coolors.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:voicerecorder/audio.dart';
import 'package:chewie_audio/chewie_audio.dart';

import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

class RecordingList extends StatefulWidget {
  @override
  _RecordingListState createState() => _RecordingListState();
}

class _RecordingListState extends State<RecordingList> {
  String _openResult = 'Unknown';
  String path;
  String directoryPath;
  List<dynamic> file = new List<dynamic>();

  @override
  void initState() {
    super.initState();
    _listofFiles();
  }

  void _listofFiles() async {
    path = (await ExtStorage.getExternalStorageDirectory()) + "/Recordings/";
    setState(() {
      file = Directory("$path")
          .listSync(); //use your folder name insted of resume.
      directoryPath = path;
    });
    print("Dirctory Path is $directoryPath");
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  itemCount: file.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      elevation: 2.0,
                      child: GestureDetector(
                        onTap: () {
                          // openFile(
                          //     directoryPath + file[index].path.split('/').last);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Audio(
                                  file: file[index],
                                ),
                              ));
                        },
                        child: ListTile(
                          leading: Icon(
                            Icons.play_circle_filled,
                            color: Colors.blue[800],
                            size: 40.0,
                          ),
                          title: Text(file[index].path.split('/').last),
                          // subtitle: Text(file[index].toString()),
                        ),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
      // Stack(
      //   children: <Widget>[
      //     Align(
      //       alignment: Alignment.bottomCenter,
      //       child: GestureDetector(
      //         onTap: () {
      //           _settingModalBottomSheet(context);
      //           print(directoryPath);
      //         },
      //         child: Container(
      //           width: width,
      //           height: 45.0,
      //           decoration: BoxDecoration(color: Colors.teal[600]),
      //           child: Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceAround,
      //             children: <Widget>[
      //               Icon(Icons.music_note, color: Colors.white),
      //               Text(
      //                 "MediaPlayer",
      //                 style: TextStyle(fontSize: 20.0, color: Colors.white),
      //               ),
      //               Text(
      //                 "Now Playing",
      //                 style: TextStyle(fontSize: 20.0, color: Colors.white),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Future<void> openFile(String filePath) async {
    final result = await OpenFile.open(filePath);

    setState(() {
      _openResult = "type=${result.type}  message=${result.message}";
    });
  }
}

class TimeAgo {
  String getTimeAgo(var duration) {
    var durInSecs = DateTime.now().difference(duration).inSeconds;
    var durInMins = DateTime.now().difference(duration).inSeconds;
    var durInHours = DateTime.now().difference(duration).inSeconds;
    var durInDays = DateTime.now().difference(duration).inSeconds;

    print('Dur in secs $durInSecs');
    print('Dur in mins $durInMins');
    print('Dur in hours $durInHours');
    print('Dur in days $durInDays');
  }
}
