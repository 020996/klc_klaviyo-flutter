import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:klc_klaviyo_flutter/klc_klaviyo_flutter.dart';
import 'package:klc_klaviyo_flutter/models/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// KLC Klaviyo requires Firebase initialization on Android if you use firebase for all platforms you can remove this check and add GoogleService-Info.plist to ios runner project and google-services.json to android app folder
  if (Platform.isAndroid) {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = 'Not initialized';
  String? _pushToken;
  String? _email;

  @override
  void initState() {
    super.initState();
    _setupKlaviyo();
  }

  Future<void> _setupKlaviyo() async {
    // Setup callbacks
    KlcKlaviyoFlutter.ic.onPushTokenReceived = (token) {
      setState(() => _pushToken = token);
      debugPrint('✅ Push token: $token');
    };

    KlcKlaviyoFlutter.ic.onNotificationTapped = (payload) {
      debugPrint('👆 Notification tapped: $payload');
    };

    // Initialize api public key not api private key
    try {
      await KlcKlaviyoFlutter.ic.initialize('API_PUBLIC_KEY_HERE');
      await _requestPush();
      setState(() => _status = 'Initialized ✅');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _setProfile() async {
    await KlcKlaviyoFlutter.ic.setProfile(
      KlaviyoProfile(
        email: 'testios@example.com',
        firstName: 'Test',
        lastName: 'User',
        properties: {'plan': 'premium'},
      ),
    );

    final email = await KlcKlaviyoFlutter.ic.getEmail();
    setState(() => _email = email);
  }

  Future<void> _getToken() async {
    final token = await KlcKlaviyoFlutter.ic.getPushToken();
    setState(() => _pushToken = token);
    debugPrint('✅ Push token: $token');
  }

  Future<void> _trackEvent() async {
    await KlcKlaviyoFlutter.ic.createEvent(
      KlaviyoEvent(
        name: 'Test Event',
        properties: {'source': 'flutter_plugin_test'},
        value: 99.99,
      ),
    );
  }

  Future<void> _requestPush() async {
    try {
      await KlcKlaviyoFlutter.ic.requestPushPermission();
    } catch (e) {
      debugPrint('Push error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Klaviyo Plugin Test')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Status: $_status'),
              Text('Email: ${_email ?? "Not set"}'),
              Text('Token: ${_pushToken?.substring(0, 20) ?? "None"}...'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _setProfile,
                child: const Text('Set Profile'),
              ),
              ElevatedButton(
                onPressed: _trackEvent,
                child: const Text('Track Event'),
              ),
              ElevatedButton(
                onPressed: _requestPush,
                child: const Text('Request Push Permission'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await KlcKlaviyoFlutter.ic.resetProfile();
                  setState(() => _email = null);
                },
                child: const Text('Reset Profile (Logout)'),
              ),
              ElevatedButton(
                onPressed: _getToken,
                child: const Text('Get Push Token'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
