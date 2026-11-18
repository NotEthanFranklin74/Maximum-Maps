import 'package:flutter/material.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onMyLocation;

  const MapControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onMyLocation,
  });

  Widget _controlButton({ required IconData icon, required VoidCallback onPressed, String? tooltip }) {
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.black54
        ),
        tooltip: tooltip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _controlButton(
          icon: Icons.add,
          onPressed: onZoomIn,
          tooltip: "Zoom in",
        ),

        const SizedBox(height: 8),

        _controlButton(
          icon: Icons.remove,
          onPressed: onZoomOut,
          tooltip: "Zoom out",
        ),

        const SizedBox(height: 16),
        
        _controlButton(
          icon: Icons.my_location,
          onPressed: onMyLocation,
          tooltip: "My location",
        ),
      ],
    );
  }
}