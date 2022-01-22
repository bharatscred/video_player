import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VideoPlayerController videoController;
  Duration currentVideoPosition = Duration.zero;
  int currentIndex = 0;
  // List<int> timeStamps = []

  void _updateIndex() {
    if (currentIndex < 2) {

    }
  }

  Future<void> _loopVideo(
      {required VideoPlayerController controller, required int endTimeInSec}) async {
    if (controller.value.position.inMilliseconds <= (endTimeInSec-1) * 1000 && controller.value.position.inMilliseconds < endTimeInSec * 1000) {
      controller.seekTo(controller.value.position - const Duration(milliseconds: 1500));
      controller.pause();
      await Future.delayed(Duration.zero);
      controller.play();
    }
  }

  @override
  void initState() {
    super.initState();
    videoController = VideoPlayerController.asset('assets/video.mp4');
    videoController.initialize().then((_) {
      videoController.play();
    });

    videoController.addListener(() {
      _loopVideo(controller: videoController, endTimeInSec: 5);
      _loopVideo(controller: videoController, endTimeInSec: 10);
      _loopVideo(controller: videoController, endTimeInSec: 15);
    });
  }

  @override
  void dispose() {
    videoController.dispose();
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Container()),
              Expanded(
                flex: 4,
                child: AspectRatio(
                  aspectRatio: videoController.value.aspectRatio,
                  child: VideoPlayer(videoController),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        videoController.seekTo(Duration.zero);
                        videoController.play();
                      },
                      icon: const Icon(Icons.replay),
                    ),
                    IconButton(
                      onPressed: () {
                        videoController.pause();
                      },
                      icon: const Icon(Icons.pause),
                    ),
                    IconButton(
                      onPressed: () {
                        videoController.play();
                      },
                      icon: const Icon(Icons.play_arrow),
                    ),
                    IconButton(
                      onPressed: () {
                        // videoController.play();
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
                      videoController.position.then((value) {
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
          ),
        ),
      ),
    );
  }
}
