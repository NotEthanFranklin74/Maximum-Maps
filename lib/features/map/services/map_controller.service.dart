import 'package:maplibre_gl/maplibre_gl.dart';

class MapControllerService {
  MapLibreMapController? _controller;

  bool get isReady => _controller != null;

  void initialise(MapLibreMapController controller) {
    _controller = controller;
  }

  void dispose() {
    _controller = null;
  }

  Future<void> moveTo(LatLng location, {double zoom = 15}) async {
    final controller = _controller;

    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: zoom,
        )
      )
    );
  }
  
  Future<void> zoomIn() async {
    final controller = _controller;

    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }

  Future<void> zoomOut() async {
    final controller = _controller;

    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.zoomOut(),
    );
  }
}