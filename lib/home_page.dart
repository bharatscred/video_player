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
  final List<int> _timeStampsInSec = [5, 10, 15]; // Ending time in sec of each part
  var _listenToVidController = true;

  void _updateIndex() {
    _currentIndex += 1;
  }

  Future<void> _seekVideoTo(Duration position) async {
    _videoController.seekTo(position);
    _videoController.play();
  }

  void _changeVideoRange() {
    if (_currentIndex < 2) {
      _seekVideoTo(Duration(seconds: _timeStampsInSec[_currentIndex]));
      _updateIndex();
    }
  }

  void _loopVideoAtPartEnd() async {
    int endTimeInSec = _timeStampsInSec[_currentIndex];
    if (_videoController.value.position.inMilliseconds >= (endTimeInSec - 0.4) * 1000 &&
        _videoController.value.position.inMilliseconds < endTimeInSec * 1000) {
      // print('--------------->>>>>stopper: ${_videoController.value.position.inMilliseconds}');
      _listenToVidController = false;
      _seekVideoTo(Duration(seconds: endTimeInSec-1)).then((_) => _listenToVidController = true);
    }
  }

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network('https://github.com/bharatscred/video_player/blob/02d3c7578c20a10f5449c527926ad7590217707e/assets/video.mp4?raw=true');
    _initializeVideoPlayerFuture = _videoController.initialize();

    _videoController.addListener(() {
      if (!_listenToVidController) return;
      // print('addListener: ${_videoController.value.position.inMilliseconds}');
      _loopVideoAtPartEnd();
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
                        child: VideoPlayer(
                          _videoController,
                        ),
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
