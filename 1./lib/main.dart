import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
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
  bool _offer = false;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final _localrenderer = RTCVideoRenderer();
  final _remoterenderer = RTCVideoRenderer();
  final sdpController = TextEditingController();

  @override
  dispose() async* {
    _localrenderer.dispose();
    _remoterenderer.dispose();

    // RTCPeerConnection pc =
    //     await createPeerConnection();

    sdpController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    initRenderers();
    _createPeerConnection().then((pc) {
      _peerConnection = pc;
    });
    super.initState();
  }

  // Future<RTCPeerConnection> _createPeerConnection(
  //   Map<String, dynamic> configuration,
  //   [Map<String, dynamic> constraints = const {}]) async {
  //   return RTCFactoryNative.instance
  //     .createPeerConnection(configuration, constraints);
  // }
  _createPeerConnection() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"}
      ]
    };
    final Map<String, dynamic> offerSdpConstraints = {
      "mandoatory": {
        "OfferToReciveAudio": true,
        "OfferToRecivVideo": true,
      },
      "optional": []
    };
    _localStream = await _getUserMedia();

    RTCPeerConnection pc =
        await createPeerConnection(configuration, offerSdpConstraints);

    pc.addStream(_localStream!);

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        print(jsonEncode({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMLineIndex': e.sdpMLineIndex.toString(),
        }));
      }
    };

    pc.onConnectionState = (e) {
      print(e);
    };

    pc.onAddStream = (stream) {
      print('addstream${stream.id}');
      _remoterenderer.srcObject = stream;
    };
    return pc;
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
    return stream;
  }

  _createOffer() async {
    RTCSessionDescription description =
        await _peerConnection!.createOffer({'offerToReciveVideo': 1});

    var session = parse(description.sdp.toString());
    print(jsonEncode(session));
    _offer = true;

    _peerConnection?.setLocalDescription(description);
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
            onTap: _createOffer,
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
