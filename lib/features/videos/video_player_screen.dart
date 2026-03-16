import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

const gold = Color(0xFFD5EB45);

class VideoPlayerScreen extends StatefulWidget {
  final String url;

  const VideoPlayerScreen({super.key, required this.url});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {

  late VideoPlayerController controller;

  bool showControls = true;
  Timer? hideTimer;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {});
        controller.play();
        startHideTimer();
      });

    controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  /// Auto hide controls
  void startHideTimer() {
    hideTimer?.cancel();

    hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showControls = false;
        });
      }
    });
  }

  void toggleControls() {
    setState(() {
      showControls = !showControls;
    });

    if (showControls) startHideTimer();
  }

  void playPause() {

    setState(() {
      controller.value.isPlaying
          ? controller.pause()
          : controller.play();
    });

    startHideTimer();
  }

  void forward() {
    final pos = controller.value.position;
    controller.seekTo(pos + const Duration(seconds: 10));
  }

  void rewind() {
    final pos = controller.value.position;
    controller.seekTo(pos - const Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      body: GestureDetector(
        onTap: toggleControls,

        child: Stack(
          alignment: Alignment.center,
          children: [

            /// VIDEO
            Center(
              child: controller.value.isInitialized
                  ? AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              )
                  : const CircularProgressIndicator(color: gold),
            ),

            /// BUFFER LOADING
            if (controller.value.isBuffering)
              const Center(
                child: CircularProgressIndicator(color: gold),
              ),

            /// CONTROLS
            AnimatedOpacity(
              opacity: showControls ? 1 : 0,
              duration: const Duration(milliseconds: 300),

              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                      Colors.black87
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            /// CONTROL LAYOUT
            if (showControls)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// TOP BAR
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [

                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),

                          const Spacer(),

                          const Text(
                            "Workout Video",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),

                          const Spacer(),
                        ],
                      ),
                    ),
                  ),

                  /// CENTER CONTROLS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      IconButton(
                        icon: const Icon(Icons.replay_10,
                            color: Colors.white, size: 40),
                        onPressed: rewind,
                      ),

                      const SizedBox(width: 20),

                      GestureDetector(
                        onTap: playPause,

                        child: Container(
                          padding: const EdgeInsets.all(18),

                          decoration: const BoxDecoration(
                            color: gold,
                            shape: BoxShape.circle,
                          ),

                          child: Icon(
                            controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 36,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      IconButton(
                        icon: const Icon(Icons.forward_10,
                            color: Colors.white, size: 40),
                        onPressed: forward,
                      ),
                    ],
                  ),

                  /// PROGRESS BAR
                  Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      children: [

                        VideoProgressIndicator(
                          controller,
                          allowScrubbing: true,

                          colors: const VideoProgressColors(
                            playedColor: gold,
                            bufferedColor: Colors.white38,
                            backgroundColor: Colors.white24,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [

                            Text(
                              formatDuration(controller.value.position),
                              style:
                              const TextStyle(color: Colors.white70),
                            ),

                            Text(
                              formatDuration(controller.value.duration),
                              style:
                              const TextStyle(color: Colors.white70),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  String formatDuration(Duration d) {

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));

    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    hideTimer?.cancel();
    controller.dispose();
    super.dispose();
  }
}