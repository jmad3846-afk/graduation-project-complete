import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/vehicle_model.dart';
import '../providers/data_providers.dart';

/// Default camera center: Damascus, Syria.
const double _defaultLat = 33.5138;
const double _defaultLng = 36.2765;

Color _statusColor(String status) {
  switch (status) {
    case 'available':
      return Colors.green;
    case 'on_mission':
      return Colors.orange;
    case 'out_of_service':
      return Colors.grey;
    default:
      return Colors.blue;
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'available':
      return 'متاحة';
    case 'on_mission':
      return 'في مهمة';
    case 'out_of_service':
      return 'خارج الخدمة';
    default:
      return status;
  }
}

/// Renders a small filled-circle marker bitmap for [color].
/// google_maps_flutter_web ignores BitmapDescriptor.defaultMarkerWithHue,
/// so custom bitmap icons are used to keep marker colors consistent
/// across web, Android and iOS.
Future<BitmapDescriptor> _buildMarkerIcon(Color color) async {
  const double size = 96;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final center = const Offset(size / 2, size / 2);

  final fill = Paint()..color = color;
  final border = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 6;

  canvas.drawCircle(center, size / 2 - 4, fill);
  canvas.drawCircle(center, size / 2 - 4, border);

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
}

/// Shared fleet map: shows vehicle markers color-coded by status.
/// Pass [centerId] to restrict the markers to a single center's vehicles;
/// leave it null to show the whole fleet.
class FleetMapWidget extends ConsumerStatefulWidget {
  final int? centerId;
  final double height;

  const FleetMapWidget({super.key, this.centerId, this.height = 320});

  @override
  ConsumerState<FleetMapWidget> createState() => _FleetMapWidgetState();
}

class _FleetMapWidgetState extends ConsumerState<FleetMapWidget> {
  final Map<String, BitmapDescriptor> _icons = {};
  bool _iconsReady = false;

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    final statuses = ['available', 'on_mission', 'out_of_service'];
    for (final status in statuses) {
      _icons[status] = await _buildMarkerIcon(_statusColor(status));
    }
    if (mounted) setState(() => _iconsReady = true);
  }

  BitmapDescriptor _iconFor(String status) =>
      _icons[status] ?? BitmapDescriptor.defaultMarker;

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehicleListProvider);

    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 5,
          ),
        ],
      ),
      child: !_iconsReady
          ? const Center(child: CircularProgressIndicator())
          : vehiclesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('تعذر تحميل مواقع المركبات: $e')),
              data: (vehicles) {
                final filtered = widget.centerId == null
                    ? vehicles
                    : vehicles.where((v) => v.centerId == widget.centerId).toList();

                return Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _initialCameraPosition(filtered),
                      zoomControlsEnabled: false,
                      scrollGesturesEnabled: true,
                      zoomGesturesEnabled: true,
                      markers: _buildMarkers(filtered),
                    ),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: _Legend(),
                    ),
                  ],
                );
              },
            ),
    );
  }

  CameraPosition _initialCameraPosition(List<VehicleModel> vehicles) {
    final withCoords = vehicles.where((v) => v.latitude != 0 || v.longitude != 0).toList();
    if (withCoords.isEmpty) {
      return const CameraPosition(target: LatLng(_defaultLat, _defaultLng), zoom: 12);
    }
    final avgLat = withCoords.map((v) => v.latitude).reduce((a, b) => a + b) / withCoords.length;
    final avgLng = withCoords.map((v) => v.longitude).reduce((a, b) => a + b) / withCoords.length;
    return CameraPosition(target: LatLng(avgLat, avgLng), zoom: 13);
  }

  Set<Marker> _buildMarkers(List<VehicleModel> vehicles) {
    return vehicles.map((v) {
      return Marker(
        markerId: MarkerId(v.id.toString()),
        position: LatLng(v.latitude, v.longitude),
        icon: _iconFor(v.status),
        infoWindow: InfoWindow(
          title: v.code.isNotEmpty ? v.code : 'مركبة #${v.id}',
          snippet: _statusLabel(v.status),
        ),
      );
    }).toSet();
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          _dot(Colors.green, 'متاحة'),
          const SizedBox(width: 10),
          _dot(Colors.orange, 'في مهمة'),
          const SizedBox(width: 10),
          _dot(Colors.grey, 'خارج الخدمة'),
        ],
      ),
    );
  }

  Widget _dot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
