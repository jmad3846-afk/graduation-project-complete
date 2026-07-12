import 'dart:async';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Thin wrapper around dart_pusher_channels (a pure-Dart Pusher-protocol
/// client, unlike pusher_client which has no working web implementation)
/// connecting to the self-hosted Reverb server. Subscribes to the private
/// `cases.new` channel so any screen (e.g. the lidar/leader dashboard) can
/// react to newly submitted reports in real time.
class WebSocketService {
  PusherChannelsClient? _client;
  PrivateChannel? _casesChannel;
  StreamSubscription? _caseCreatedSubscription;

  final _caseCreatedController = StreamController<void>.broadcast();

  /// Fires (with no payload) whenever a new case is broadcast on the
  /// private `cases.new` channel. Listeners should just refetch their own
  /// case list rather than trying to parse the event payload.
  Stream<void> get onCaseCreated => _caseCreatedController.stream;

  final String _baseUrl = const String.fromEnvironment('FLUTTER_API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8000/api');
  final String _appKey = const String.fromEnvironment('REVERB_APP_KEY',
      defaultValue: 'reverb_key');
  final String _host = const String.fromEnvironment('REVERB_HOST',
      defaultValue: '127.0.0.1');
  final String _port = const String.fromEnvironment('REVERB_PORT',
      defaultValue: '8080');
  final String _scheme = const String.fromEnvironment('REVERB_SCHEME',
      defaultValue: 'http');

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token == null) return;

    await dispose();

    final options = PusherChannelsOptions.fromHost(
      scheme: _scheme == 'https' ? 'wss' : 'ws',
      host: _host,
      port: int.parse(_port),
      key: _appKey,
      shouldSupplyMetadataQueries: true,
      metadata: PusherChannelsOptionsMetadata.byDefault(),
    );

    final client = PusherChannelsClient.websocket(
      options: options,
      connectionErrorHandler: (exception, trace, refresh) {
        refresh();
      },
    );
    _client = client;

    final casesChannel = client.privateChannel(
      'private-cases.new',
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('$_baseUrl/broadcasting/auth'),
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    _casesChannel = casesChannel;

    client.onConnectionEstablished.listen((_) {
      casesChannel.subscribeIfNotUnsubscribed();
    });

    _caseCreatedSubscription = casesChannel.bind('case.created').listen((event) {
      _caseCreatedController.add(null);
    });

    client.connect();
  }

  Future<void> dispose() async {
    await _caseCreatedSubscription?.cancel();
    _caseCreatedSubscription = null;
    _casesChannel?.unsubscribe();
    _casesChannel = null;
    _client?.dispose();
    _client = null;
  }
}
