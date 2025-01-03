import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  final String? location;

  const MapPage({super.key, this.location});

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  late MapController mapController;
  GeoPoint? userLocation;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // Se a localização inicial foi fornecida, usa-a
    if (widget.location != null) {
      final coords = widget.location!.split(',');
      userLocation = GeoPoint(
        latitude: double.parse(coords[0]),
        longitude: double.parse(coords[1]),
      );
    } else {
      // Caso contrário, tenta obter a localização atual usando `location`
      final loc = Location();
      final permissionGranted = await loc.requestPermission();
      if (permissionGranted == PermissionStatus.granted) {
        try {
          final currentLocation = await loc.getLocation();
          userLocation = GeoPoint(
            latitude: currentLocation.latitude ?? 0.0,
            longitude: currentLocation.longitude ?? 0.0,
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao obter localização: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permissão de localização negada.')),
        );
      }
    }

    // Inicializa o controlador do mapa
    mapController = MapController(
      initPosition: userLocation ?? GeoPoint(latitude: 0.0, longitude: 0.0),
    );
    setState(() {}); // Atualiza o estado para carregar o mapa
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Localização no Mapa'),
      ),
      body: userLocation == null
          ? Center(child: CircularProgressIndicator()) // Mostra um loader até que a localização esteja pronta
          : OSMFlutter(
        controller: mapController,
        mapIsLoading: Center(child: CircularProgressIndicator()),
        osmOption: OSMOption(
          userLocationMarker: UserLocationMaker(
            personMarker: MarkerIcon(
              icon: Icon(
                Icons.person_pin_circle,
                color: Colors.blue,
                size: 48,
              ),
            ),
            directionArrowMarker: MarkerIcon(
              icon: Icon(
                Icons.double_arrow,
                color: Colors.green,
                size: 48,
              ),
            ),
          ),
          staticPoints: [
            StaticPositionGeoPoint(
              "user_location",
              MarkerIcon(
                icon: Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              userLocation != null ? [userLocation!] : [],
            ),
          ],
          showZoomController: true,
          zoomOption: ZoomOption(
            initZoom: 12,
            maxZoomLevel: 18,
            minZoomLevel: 3,
          ),
          showContributorBadgeForOSM: true,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (userLocation != null) {
            Navigator.pop(context, "${userLocation!.latitude},${userLocation!.longitude}");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Nenhuma localização selecionada.')),
            );
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
