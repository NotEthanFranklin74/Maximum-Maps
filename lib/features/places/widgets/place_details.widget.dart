import 'package:flutter/material.dart';
import 'package:maximum_maps/features/places/models/place.model.dart';

class PlaceDetailsWidget extends StatelessWidget {
  final Place place;
  final ScrollController? scrollController;
  final VoidCallback? onDirections;
  final VoidCallback? onSave;

  const PlaceDetailsWidget({
    super.key,
    required this.place,
    this.scrollController,
    this.onDirections,
    this.onSave,
  });

  IconData get categoryIcon {
    switch (place.category.toLowerCase()) {
      case 'restaruant':
      case 'cafe':
      case 'food':
        return Icons.restaurant;

      case 'park':
        return Icons.park;

      case 'museum':
        return Icons.museum;

      case 'shop':
      case 'shopping':
        return Icons.shopping_bag;

      case 'hotel':
        return Icons.hotel;

      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                categoryIcon,
                size: 28,
                color: theme.colorScheme.primaryContainer,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    place.category,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              tooltip: 'Close',
            ),
          ],
        ),

        const SizedBox(height: 20),

        if (place.description != null && place.description!.isNotEmpty) ...[
          Text(
            place.description!,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
        ],

        Text(
          'Location',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        _InfoRow(
          icon: Icons.explore_outlined,
          label: 'Longitude',
          value: place.lon.toStringAsFixed(6),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            if (onSave != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.bookmark_outline),
                  label: const Text('Save'),
                ),
              ),

            if (onSave != null && onDirections != null)
              const SizedBox(width: 12),
            
            if (onDirections != null) 
              Expanded(
                child: FilledButton.icon(
                  onPressed: onDirections,
                  icon: const Icon(Icons.directions),
                  label: const Text('Directions'),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.secondary,
          size: 20,
        ),

        const SizedBox(width: 12),

        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),

        const Spacer(),

        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}