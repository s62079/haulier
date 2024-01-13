import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:haulier/util.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationPickerPage extends StatefulWidget {
  final Map<String, dynamic>? coordinates;
  final bool viewOnly;

  const LocationPickerPage({
    super.key,
    this.coordinates,
    this.viewOnly = false,
  });

  @override
  State<StatefulWidget> createState() {
    return _LocationPickerPageState();
  }
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late LatLng pos = (widget.coordinates != null)
      ? LatLng.fromJson(widget.coordinates!)
      : const LatLng(10, 0);
  double z = 5;
  late Marker? marker = (widget.coordinates != null) ? getMarker() : null;

  Marker getMarker() {
    return Marker(
      point: pos,
      child: GestureDetector(
        onTap: (widget.viewOnly) ? null : () => setState(() => marker = null),
        child: const Icon(Icons.location_on, color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: getNavOverlay(Theme.of(context).canvasColor),
        title: Text('${(widget.viewOnly) ? 'Current' : 'Select'} Location'),
      ),
      body: FlutterMap(
        options: MapOptions(
          // https://pub.dev/documentation/flutter_map/latest/flutter_map/InteractionOptions-class.html
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
          ),
          initialCenter: pos,
          initialZoom: z,
          // https://stackoverflow.com/questions/67464084
          onTap: (widget.viewOnly)
              ? null
              : (TapPosition tapPos, LatLng pos) {
                  if (kDebugMode) {
                    print('DEBUG: ${pos.toJson()}');
                  }
                  this.pos = pos;
                  setState(() => marker = getMarker());
                },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.citawarisan.haulier',
          ),
          RichAttributionWidget(
            alignment: AttributionAlignment.bottomLeft,
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () => launchUrl(
                  Uri.parse('https://openstreetmap.org/copyright'),
                ),
              ),
            ],
          ),
          MarkerLayer(markers: [if (marker != null) marker!]),
        ],
      ),
      floatingActionButton: (widget.viewOnly)
          ? null
          : FloatingActionButton(
              onPressed: (marker != null)
                  ? () => Navigator.pop(context, pos.toJson())
                  : null,
              child: const Icon(Icons.check),
            ),
    );
  }
}
