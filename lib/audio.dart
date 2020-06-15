import 'dart:io';

import 'package:chewie_audio/chewie_audio.dart';
import 'package:chewie_audio/src/chewie_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Audio extends StatefulWidget {
  Audio({this.file});

  final File file;
  @override
  State<StatefulWidget> createState() {
    return _ChewieDemoState();
  }
}

class _ChewieDemoState extends State<Audio> {
  TargetPlatform _platform;
  VideoPlayerController _videoPlayerController1;
  ChewieAudioController _chewieAudioController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController1 = VideoPlayerController.file(widget.file);

    _chewieAudioController = ChewieAudioController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _chewieAudioController.dispose();
    super.dispose();
  }

  // debugShowCheckedModeBanner: false,
      // theme: ThemeData.light().copyWith(
      //   platform: _platform ?? Theme.of(context).platform,
      // ),

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Icon(
                        Icons.arrow_back,
                        size: 47,
                      ),
                    ),
                  )),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    widget.file.path.split('/').last,
                    style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: ChewieAudio(
                      controller: _chewieAudioController,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                          onPressed: () {
                            setState(() {
                              _chewieAudioController.dispose();
                              _videoPlayerController1.pause();
                              _videoPlayerController1
                                  .seekTo(Duration(seconds: 0));
                              _chewieAudioController = ChewieAudioController(
                                videoPlayerController: _videoPlayerController1,
                                autoPlay: true,
                                looping: false,
                              );
                            });
                          },
                          child: Container(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      
    );
  }
}
