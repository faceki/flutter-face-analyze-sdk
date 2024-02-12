# Faceki Face Analyze SDK for Flutter

The `faceki_faceanalyze_sdk` package allows Flutter web applications to easily integrate Faceki's face analysis capabilities. This package provides a simple interface to capture images from the user's camera and analyze them using Faceki's services.


### Installation

To use the `faceki_faceanalyze_sdk` package in your Flutter project, follow these steps:

1. Add the dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  faceki_faceanalyze_sdk: ^1.0.0
```
Run flutter pub get to install the package.

Copy the camera.js file from the package's web/js directory to your project's web/js directory. This file is necessary for the camera functionality to work.

Include the camera.js script in your project's web/index.html file:

```html
<script src="js/camera.js"></script>
```
### Usage
To use the Faceki Face Analyze SDK in your application, import the package and initialize the FacekiSDKConfig with your client ID and secret. Then, create the FacekiFaceAnalyzeSDK widget with the configuration:

```dart
import 'package:flutter/material.dart';
import 'package:faceki_faceanalyze_sdk/faceki_faceanalyze_sdk.dart';
import 'package:faceki_faceanalyze_sdk/src/config.dart';

void main() {
  final config = FacekiSDKConfig(
    clientId: 'YourClientID',
    clientSecret: 'YourClientSecret',
    responseCallback: (jsonString) {
      print(jsonString);
    },
  );

  runApp(MaterialApp(
    home: FacekiFaceAnalyzeSDK(config: config),
  ));
}
```
### Debugging
To enable debug mode and receive detailed logs, set the debugMode flag to true when creating the FacekiSDKConfig:

```dart
Copy code
final config = FacekiSDKConfig(
  clientId: 'YourClientID',
  clientSecret: 'YourClientSecret',
  debugMode: true,
  responseCallback: (jsonString) {
    print(jsonString);
  },
);
```
#### Data Structure For Response

```
{
  "status": true,
  "code": 200,
  "message": "OK",
  "appVersion": "v3.0.0",
  "result": {
    "minAge": 25,
    "maxAge": 33,
    "gender": "Male",
    "genderConfidence": 100,
    "faceDetectionConfidence": 99.999,
    "livenessScore": 0.999
  }
}
```

### Note
The camera.js file is required for camera access and image capture functionality. Make sure it is included in your web/index.html as described in the Installation section.