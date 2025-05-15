import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? videoTitle;

  const FullScreenVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.videoTitle,
  }) : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      String playbackUrl = widget.videoUrl;

      // Convert any Cloudflare URL to proper format
      if (widget.videoUrl.contains('cloudflarestream.com')) {
        if (widget.videoUrl.contains('/watch')) {
          playbackUrl =
              widget.videoUrl.replaceAll('/watch', '/manifest/video.m3u8');
        } else if (!widget.videoUrl.contains('.m3u8') &&
            !widget.videoUrl.contains('.mpd') &&
            !widget.videoUrl.contains('.mp4')) {
          playbackUrl = "$playbackUrl/manifest/video.m3u8";
        }
      }

      debugPrint("Using playback URL: $playbackUrl");

      _videoPlayerController = VideoPlayerController.network(
        playbackUrl,
        formatHint: playbackUrl.endsWith('.m3u8')
            ? VideoFormat.hls
            : (playbackUrl.endsWith('.mpd')
                ? VideoFormat.dash
                : VideoFormat.other),
      );

      // Add a listener to detect play/pause events and log the timestamp
      _videoPlayerController.addListener(() {
        final position = _videoPlayerController.value.position;
        if (_videoPlayerController.value.isPlaying) {
          debugPrint("Video is playing at timestamp: ${position.inSeconds}s");
        } else {
          debugPrint("Video is paused at timestamp: ${position.inSeconds}s");
        }
      });

      await _videoPlayerController.initialize();

      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          looping: false,
          errorBuilder: (context, errorMsg) {
            return Center(
              child: Column(
                children: [
                  Text('Error: $errorMsg'),
                  Text('URL: $playbackUrl'),
                  ElevatedButton(
                    onPressed: _retryPlayer,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          },
        );
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error initializing player: $e");
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _retryPlayer() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : Chewie(controller: _chewieController!),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Video Playback Failed',
                style: TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            Text('URL: ${widget.videoUrl}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _retryPlayer,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
