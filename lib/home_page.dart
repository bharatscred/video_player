import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  Duration currentVideoPosition = Duration.zero;
  int _currentIndex = 0;
  final List<int> _timeStampsInSec = [5, 10];

  void _updateIndex() {
    _currentIndex += 1;
  }

  void _changeVideoRange() {
    if (_currentIndex < 2) {
      _videoController.seekTo(Duration(seconds: _timeStampsInSec[_currentIndex]));
      _videoController.play();
      _updateIndex();
    }
  }

  Future<void> _loopVideo(
      {required VideoPlayerController controller, required int endTimeInSec}) async {
    if (controller.value.position.inMilliseconds >= (endTimeInSec - 0.5) * 1000 &&
        controller.value.position.inMilliseconds < endTimeInSec * 1000) {
      controller.seekTo(Duration(seconds: endTimeInSec-1));
      controller.pause();
      await Future.delayed(Duration.zero);
      controller.play();
    }
  }

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/video.mp4');
    _initializeVideoPlayerFuture = _videoController.initialize();

    _videoController.addListener(() {
      _loopVideo(controller: _videoController, endTimeInSec: 5);
      _loopVideo(controller: _videoController, endTimeInSec: 10);
      _loopVideo(controller: _videoController, endTimeInSec: 15);
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Video Player Demo")),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                _videoController.play();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Container()),
                    Expanded(
                      flex: 4,
                      child: AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              _currentIndex = 0;
                              _videoController.seekTo(Duration.zero);
                              _videoController.play();
                            },
                            icon: const Icon(Icons.replay),
                          ),
                          IconButton(
                            onPressed: () {
                              _videoController.pause();
                            },
                            icon: const Icon(Icons.pause),
                          ),
                          IconButton(
                            onPressed: () {
                              _videoController.play();
                            },
                            icon: const Icon(Icons.play_arrow),
                          ),
                          IconButton(
                            onPressed: () {
                              _changeVideoRange();
                            },
                            icon: const Icon(Icons.arrow_forward_rounded),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            _videoController.position.then((value) {
                              setState(() {
                                currentVideoPosition = value!;
                              });
                            });
                            return Text(currentVideoPosition.toString());
                          },
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}
