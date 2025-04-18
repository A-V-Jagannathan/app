import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:witnessing_data_app/models/firebase/device_data_model.dart';
import 'package:witnessing_data_app/utilities/temp_ipaddr_converter.dart';

class DevicePreview extends StatefulWidget {
  const DevicePreview({
    super.key,
    required this.device,
  });

  final DeviceData device;

  @override
  State<DevicePreview> createState() => _DevicePreviewState();
}

class _DevicePreviewState extends State<DevicePreview> {
  // late final Future<bool> _videoPreview;
  late final FlickManager _videoManager;

  @override
  void initState() {
    super.initState();
    _videoManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
            Uri.http(tempIPToServerPort(widget.device.ipAddress), '/preview')));
  }

  @override
  void dispose() {
    _videoManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.value(true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData) {
              // something went wrong with the preview call
              return const Center(
                  child: Text('Error loading preview...',
                      style: TextStyle(color: Colors.red)));
            }

            if (snapshot.data!) {
              return FlickVideoPlayer(
                flickManager: _videoManager,
                preferredDeviceOrientation: const [
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ],
                preferredDeviceOrientationFullscreen: const [
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ],
                flickVideoWithControls: const FlickVideoWithControls(
                  videoFit: BoxFit.contain,
                  controls: FlickPortraitControls(),
                ),
              );
            } else {
              return PreviewVideoWindow(
                  text: Text('No preview available...',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(color: Colors.red)));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

class PreviewVideoWindow extends StatelessWidget {
  const PreviewVideoWindow({
    super.key,
    required this.text,
  });

  final Text text;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.black, borderRadius: BorderRadius.circular(20)),
        child: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.videocam, color: Colors.white, size: 48),
          const SizedBox(width: 20),
          text,
        ])));
  }
}
