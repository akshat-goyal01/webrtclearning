import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
//import 'package:permission_handler/permission_handler.dart';

//import 'package:webrtc/get_user_media.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Webrtc Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _localrenderer = RTCVideoRenderer();
  final _remoterenderer = RTCVideoRenderer();
  final sdpController = TextEditingController();

  @override
  void dispose() {
    _localrenderer.dispose();
    _remoterenderer.dispose();
    sdpController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    initRenderers();
    _getUserMedia();
    super.initState();
  }

  initRenderers() async {
    await _localrenderer.initialize();
    await _remoterenderer.initialize();
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstrains = {
      'audio': false,
      'video': {
        'facingmode': 'user',
      }
    };
    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstrains);

    _localrenderer.srcObject = stream;
    // _localrenderer.mirror = true;
    RTCVideoView(
      _localrenderer,
      mirror: true,
    );
  }

  SizedBox videoRenderers() => SizedBox(
      height: 300,
      child: Row(children: [
        Flexible(
          child: Container(
            key: const Key('local'),
            margin: const EdgeInsets.all(5.0),
            decoration: const BoxDecoration(color: Colors.black),
            child: RTCVideoView(_localrenderer),
          ),
        ),
        Flexible(
          child: Container(
            key: const Key('local'),
            margin: const EdgeInsets.all(5.0),
            decoration: const BoxDecoration(color: Colors.black),
            child: RTCVideoView(_remoterenderer),
          ),
        ),
      ]));
  Row offerandAnsButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: null,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              color: Colors.grey,
              child: const Text("Offer"),
            ),
          ),
          GestureDetector(
            onTap: null,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              color: Colors.grey,
              child: const Text("Answer"),
            ),
          ),
        ],
      );

  Padding sdpCandidateTF() => Padding(
        padding: const EdgeInsets.all(15),
        child: TextField(
          controller: sdpController,
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          maxLength: TextField.noMaxLength,
        ),
      );

  Row sdpCandidateButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: null, //_setRemoteDescription,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              color: Colors.grey,
              child: const Text("Set remote desc"),
            ),
          ),
          GestureDetector(
            onTap: null, //_setCandidate,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              color: Colors.grey,
              child: const Text("Set candidate"),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // ignore: avoid_unnecessary_containers
      body: Container(
        child: Column(children: [
          videoRenderers(),
          offerandAnsButtons(),
          sdpCandidateTF(),
          sdpCandidateButtons(),
        ]),
      ),
    );
  }
}
