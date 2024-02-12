import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:js' as js;
import 'config.dart';
import 'package:http/http.dart' as http;

// A unique identifier for the camera view.
const String viewType = 'faceki-camera-view';

@JS()
external String captureImagePromise();

class FacekiFaceAnalyzeSDK extends StatefulWidget {
  final FacekiSDKConfig config;

  FacekiFaceAnalyzeSDK({Key? key, required this.config}) : super(key: key);

  @override
  _FacekiFaceAnalyzeSDKState createState() => _FacekiFaceAnalyzeSDKState();
}

class _FacekiFaceAnalyzeSDKState extends State<FacekiFaceAnalyzeSDK> {
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Generate token when the widget initializes
    widget.config.generateToken().catchError((error) {
      // Handle any errors here
      print("Error generating token: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    // Register the camera view
    ui.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final videoElement = html.VideoElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'cover'
          ..autoplay = true
          ..controls = false;

        // Define the video constraints for high-resolution
        final Map<String, dynamic> constraints = {
          'video': {
            'width': 1280, // Your desired width
            'height': 720, // Your desired height
          }
        };

        // Use the constraints with named parameters
        html.window.navigator
            .getUserMedia(video: constraints['video'])
            .then((mediaStream) {
          videoElement.srcObject = mediaStream;
          videoElement.play();
        }).catchError((error) {
          print(error);
        });

        return videoElement;
      },
    );

    List<Widget> stackChildren = [
      Positioned.fill(child: HtmlElementView(viewType: viewType)),
      Center(
          child:
              CustomPaint(size: Size.infinite, painter: OvalOverlayPainter())),
      Positioned(
        bottom: 150,
        child: Text('Fit your face in the middle',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      Positioned(
        bottom: 80,
        child: FloatingActionButton(
          onPressed: () => captureImage(),
          child: Icon(Icons.camera),
          backgroundColor: Colors.lightBlue,
        ),
      ),
      Positioned(
        bottom: 30,
        child: Text('Powered by FACEKI',
            style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
    ];

    // Conditionally add a loading overlay
    if (_isUploading) {
      stackChildren.add(
        Positioned.fill(
          child: Container(
            color: Colors.black45,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   title: Text('Take a Selfie'),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      // ),
      body: Stack(
        alignment: Alignment.center,
        children: stackChildren,
      ),
    );
  }

  Future<void> captureImage() async {
    try {
      final completer = Completer<dynamic>();

      js.context.callMethod('captureImagePromise', [
        (result) => completer.complete(result),
      ]);
      setState(() {
        _isUploading = true; // Start loading
      });

      var value = await completer.future;
      await widget.config.generateToken();
      final String base64String = value.split(',').last;
      final Uint8List imageBytes = base64.decode(base64String);
      final token = await widget.config.getToken();
      final responseString = await uploadImage(imageBytes, 'image.jpg', token!);
      if (responseString != null) {
        final responseJson = json.decode(responseString);
        widget.config.responseCallBack!(responseString);

        if (widget.config.debugMode) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Face Analyze Result'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Min Age: ${responseJson['result']['minAge']}'),
                      Text('Max Age: ${responseJson['result']['maxAge']}'),
                      Text('Gender: ${responseJson['result']['gender']}'),
                      Text(
                          'Liveness Score: ${responseJson['result']['livenessScore']}'),
                      // Add more fields as needed
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }

      setState(() {
        _isUploading = false; // Stop loading
      });
    } catch (e) {
      setState(() {
        _isUploading = false; // Stop loading
      });
      print('Error capturing image: $e');
    }
  }
}

Future<String?> uploadImage(
    Uint8List imageBytes, String fileName, String token) async {
  var uri = Uri.parse(
      'https://sdk.faceki.com/api/v3/kyc_verification/analyzeFace');
  var request = http.MultipartRequest('POST', uri)
    ..headers['Authorization'] = 'Bearer $token'
    ..files.add(http.MultipartFile.fromBytes(
      'selfie', // The field name for the file in the API
      imageBytes,
      filename: fileName,
      contentType:
          MediaType('image', 'jpeg'), // Set the content type for the file
    ));
  var response = await request.send();
  if (response.statusCode == 200) {
    final responseString = await response.stream.bytesToString();
    return responseString;
  } else {
    return null;
  }
}

class OvalOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Define the oval's bounding rectangle
    // The oval will fit within this rectangle
    final Rect ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8, // 80% of the width for the oval's width
      height: size.height * 0.5, // 50% of the height for the oval's height
    );

    // Draw the oval
    canvas.drawOval(ovalRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
