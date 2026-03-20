import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

const primaryGreen = Color(0xFFC8DC32);
const accentGreen = Color(0xFFC8DC32);

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

  void startHideTimer() {
    hideTimer?.cancel();

    hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => showControls = false);
    });
  }

  void toggleControls() {
    setState(() => showControls = !showControls);
    if (showControls) startHideTimer();
  }

  void playPause() {
    controller.value.isPlaying ? controller.pause() : controller.play();
    setState(() {});
    startHideTimer();
  }

  void forward() {
    controller.seekTo(
        controller.value.position + const Duration(seconds: 10));
  }

  void rewind() {
    controller.seekTo(
        controller.value.position - const Duration(seconds: 10));
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
                  : const CircularProgressIndicator(color: primaryGreen),
            ),

            /// LOADER
            if (controller.value.isBuffering)
              const CircularProgressIndicator(color: primaryGreen),

            /// OVERLAY
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

            /// CONTROLS UI
            if (showControls)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// 🔝 TOP BAR (GLASS)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12),

                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),

                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),

                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),

                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),

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
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// 🎯 CENTER CONTROLS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      IconButton(
                        icon: const Icon(Icons.replay_10,
                            color: Colors.white, size: 36),
                        onPressed: rewind,
                      ),

                      const SizedBox(width: 20),

                      /// 🔥 PLAY BUTTON
                      GestureDetector(
                        onTap: playPause,

                        child: Container(
                          padding: const EdgeInsets.all(22),

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [primaryGreen, accentGreen],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryGreen.withOpacity(0.6),
                                blurRadius: 25,
                              )
                            ],
                          ),

                          child: Icon(
                            controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      IconButton(
                        icon: const Icon(Icons.forward_10,
                            color: Colors.white, size: 36),
                        onPressed: forward,
                      ),
                    ],
                  ),

                  /// ⏱ PROGRESS BAR
                  Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),

                          child: VideoProgressIndicator(
                            controller,
                            allowScrubbing: true,

                            colors: const VideoProgressColors(
                              playedColor: primaryGreen,
                              bufferedColor: Colors.white38,
                              backgroundColor: Colors.white24,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                          children: [

                            Text(
                              formatDuration(controller.value.position),
                              style: const TextStyle(
                                  color: Colors.white70),
                            ),

                            Text(
                              formatDuration(controller.value.duration),
                              style: const TextStyle(
                                  color: Colors.white70),
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