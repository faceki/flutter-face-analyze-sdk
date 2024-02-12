import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

typedef ResponseCallback = void Function(String jsonString);

class FacekiSDKConfig {
  final String clientId;
  final String clientSecret;
  final ResponseCallback? responseCallBack;
  final bool debugMode;
  String? _token;

  FacekiSDKConfig(
      {required this.clientId,
      required this.clientSecret,
      required this.responseCallBack,
      this.debugMode = false});

  /// Generates or refreshes the authentication token
  Future<void> generateToken() async {
    try {
      // Construct the URL with query parameters
      final uri = Uri.parse("https://sdk.faceki.com/auth/api/access-token")
          .replace(queryParameters: {
        'clientId': clientId,
        'clientSecret': clientSecret,
      });

      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
    
        _token = data['data']
            ['access_token']; // Adjust the key according to your API response
      } else {
        throw Exception('Failed to generate token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating token: $e');
    }
  }

  /// Gets the current token. If no token exists, it attempts to generate one.
  Future<String?> getToken() async {
    if (_token == null) {
      await generateToken();
    }
    return _token;
  }
}
