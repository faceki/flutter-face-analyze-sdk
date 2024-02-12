import 'package:faceki_faceanalyze_sdk/faceki_faceanalyze_sdk.dart';
import 'package:faceki_faceanalyze_sdk/src/config.dart';
import 'package:flutter/material.dart';

void main() {
  final config = FacekiSDKConfig(
    clientId: 'YouClientID',
    clientSecret: 'YourClientSecret',
    responseCallBack: (jsonString) {
      print(jsonString);
    },
  );

  runApp(MaterialApp(
    home: FacekiFaceAnalyzeSDK(config: config),
  ));
}