import 'package:flutter/material.dart';
import 'package:maximum_maps/core/map/models/map.style.dart';

class MapStyleSelector extends StatelessWidget {
  final MapStyle selectedStyle;
  final ValueChanged<MapStyle> onChanged;

  const MapStyleSelector({
    super.key,
    required this.selectedStyle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MapStyle>(
      initialValue: selectedStyle,
      onSelected: onChanged,
      tooltip: 'Change map style',
      itemBuilder: (context) => [
        PopupMenuItem(
          value: MapStyle.light,
          child: Row(
            children: [
              const Icon(Icons.light_mode),
              const SizedBox(width: 12),
              const Text('Light'),
              const Spacer(),
              if (selectedStyle == MapStyle.light)
                const Icon(Icons.check),
            ],
          ),
        ),
        PopupMenuItem(
          value: MapStyle.dark,
          child: Row(
            children: [
              const Icon(Icons.dark_mode),
              const SizedBox(width: 12),
              const Text('Dark'),
              const Spacer(),
              if (selectedStyle == MapStyle.dark)
                const Icon(Icons.check),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.layers_outlined),
      ),
    );
  }
}