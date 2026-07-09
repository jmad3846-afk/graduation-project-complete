# Flutter Real-time (WebSocket) Integration

This document contains minimal, production-clean Flutter snippets for integrating with the Laravel backend's real-time features (private channels, Sanctum auth, and Pusher/Reverb-compatible websockets). Do not add push notifications (FCM/APNs) here — this is for in-app realtime only.

Requirements (pubspec.yaml)

Add these dependencies in your Flutter app:

```yaml
dependencies:
  http: ^1.0.0
  pusher_client: ^2.0.0
  web_socket_channel: ^2.2.0
  flutter_secure_storage: ^8.0.0
  async: ^2.10.0 # optional: retry/backoff helpers
```

1) Authentication

- Use your existing endpoint `POST /api/paramedic/login` to obtain an API token.
- Store tokens securely with `flutter_secure_storage` and send them as `Authorization: Bearer <token>` for API calls and broadcasting auth.

Example: login and store token

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = FlutterSecureStorage();

Future<void> login(String email, String password) async {
  final resp = await http.post(
    Uri.parse('https://api.example.com/api/paramedic/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (resp.statusCode == 200) {
    final body = jsonDecode(resp.body);
    final token = body['token'] as String;
    await _storage.write(key: 'api_token', value: token);
  } else {
    throw Exception('Login failed: ${resp.statusCode}');
  }
}
```

2) API requests (example helper)

```dart
Future<http.Response> apiGet(String path) async {
  final token = await _storage.read(key: 'api_token');
  return http.get(Uri.parse('https://api.example.com$path'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
}
```

3) Laravel Echo / Pusher configuration (Flutter using `pusher_client`)

- Laravel uses `/broadcasting/auth` for private channel auth. The client must include the `Authorization: Bearer <token>` header when requesting this endpoint.
- Use `pusher_client` to connect to Pusher-compatible servers (Pusher, hosted or self-hosted Reverb that supports the Pusher protocol).

Minimal Pusher client setup (`lib/services/realtime_pusher.dart`)

```dart
import 'package:pusher_client/pusher_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = FlutterSecureStorage();

class RealtimePusher {
  late final PusherClient pusher;

  RealtimePusher(String appKey, String cluster, String authEndpoint) {
    final tokenHeader = () async => {
      'Authorization': 'Bearer ' + (await _storage.read(key: 'api_token') ?? ''),
    };

    final options = PusherOptions(
      cluster: cluster,
      encrypted: true,
      auth: PusherAuth(authEndpoint, headers: null),
    );

    pusher = PusherClient(appKey, options, autoConnect: false);
  }

  void connect() => pusher.connect();
  void disconnect() => pusher.disconnect();
}
```

Note: `pusher_client` automatically calls the `authEndpoint` when subscribing to a `private-*` channel. Make sure your backend validates `Authorization: Bearer <token>`.

4) Private channel subscriptions

Channel naming (server conventions):

- User personal channel: `private-App.Models.User.{userId}`
- Vehicle team channel: `private-vehicle.{vehicleId}`
- Center team channel: `private-center.{centerId}`

Subscribe and bind events (example)

```dart
// After connecting
final channel = pusher.subscribe('private-App.Models.User.$userId');
channel.bind('NotificationCreated', (PusherEvent? ev) {
  final data = ev?.data; // JSON string — parse into map
  // Handle notification: navigate, store, show UI
});

final vehicleChannel = pusher.subscribe('private-vehicle.$vehicleId');
vehicleChannel.bind('CaseAssigned', (ev) { /* handle */ });

final centerChannel = pusher.subscribe('private-center.$centerId');
centerChannel.bind('CaseStatusUpdated', (ev) { /* handle */ });
```

5) Vehicle & center channels

- Use vehicle channels to broadcast events intended for all paramedics assigned to a vehicle.
- Use center channels for center-wide events.
- Server authorizes subscriptions via `routes/channels.php` (backend responsibility).

6) Real-time event listeners (best practices)

- Parse event payloads defensively — payloads are typically JSON strings in `event.data`.
- Keep listener handlers small and dispatch work to app state managers (Bloc/Provider/Riverpod).

Example handler

```dart
channel.bind('CaseAssigned', (ev) {
  final payload = jsonDecode(ev?.data ?? '{}');
  // e.g., payload['case_id'], payload['title']
  // Update UI/state via your app store/provider
});
```

7) Reconnect handling

- Use Pusher client's connection callbacks to monitor status and retry with backoff.
- When token rotation occurs, update the auth header and re-subscribe.

Example simple reconnect & token refresh pattern

```dart
// connect and listen
realtime.pusher.onConnectionStateChange((state) async {
  if (state.currentState == 'DISCONNECTED') {
    // show offline indicator
  } else if (state.currentState == 'CONNECTED') {
    // optionally re-subscribe or verify state
  }
});

// On token refresh
Future<void> refreshTokenAndReconnect(String newToken) async {
  await _storage.write(key: 'api_token', value: newToken);
  // pusher_client doesn't expose header setter on older versions; safest is to disconnect and recreate
  realtime.disconnect();
  realtime = RealtimePusher('APP_KEY', 'APP_CLUSTER', 'https://api.example.com/broadcasting/auth');
  realtime.connect();
}
```

8) Security best practices

- Always use `https://` and `wss://` in production.
- Do not embed server `APP_KEY` or private credentials in the app.
- Store tokens in `flutter_secure_storage` and rotate them when possible.
- Validate all channel auth server-side in `routes/channels.php`.
- Ensure broadcast driver and queue worker run in production (e.g., `php artisan queue:work`).

Appendix — Generic WebSocket (Reverb) flow

If your websocket server implements the Pusher protocol but you need to perform manual auth (example using `web_socket_channel`):

1. Open WebSocket and wait for `pusher:connection_established` to obtain `socket_id`.
2. POST to `/broadcasting/auth` with `Authorization: Bearer <token>` and JSON body `{ "socket_id": "<socket_id>", "channel_name": "private-vehicle.1" }`.
3. Send subscribe message to WS with returned `auth` signature.

Minimal authorize example (Dart `http`) :

```dart
final resp = await http.post(
  Uri.parse('https://api.example.com/broadcasting/auth'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json'
  },
  body: jsonEncode({'socket_id': socketId, 'channel_name': channelName}),
);
final auth = jsonDecode(resp.body)['auth'];
```

That's it — implement listeners to update app state and keep the token refreshed. If you'd like, I can add these snippets as a tiny Flutter example app in `final_project_frontend_flutter_Citizen` or `final_project_frontend_flutter_Paramedic`.
