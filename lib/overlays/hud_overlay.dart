import 'package:flutter/material.dart';
import '../game/traffic_racer_game.dart';
import '../components/power_up_component.dart';

class HudOverlay extends StatelessWidget {
  final TrafficRacerGame game;

  const HudOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            _buildTopRow(),
            const SizedBox(height: 8),
            _buildPowerUpsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Level indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.speed,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Level ${game.currentLevel}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Score display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.stars,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<int>(
                valueListenable: game.scoreNotifier,
                builder: (context, score, child) {
                  return Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPowerUpsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: PowerUpType.values.map((PowerUpType type) {
        final bool isActive = game.activePowerUps[type] != null;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? _getColorForType(type).withOpacity(0.3) : Colors.black54,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? _getColorForType(type) : Colors.white24,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconForType(type),
                  color: isActive ? _getColorForType(type) : Colors.white54,
                  size: 20,
                ),
                if (isActive) ...[
                  const SizedBox(width: 4),
                  Text(
                    _getNameForType(type),
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForType(PowerUpType type) {
    switch (type) {
      case PowerUpType.invincibility:
        return Icons.shield;
      case PowerUpType.scoreMultiplier:
        return Icons.star;
      case PowerUpType.nitro:
        return Icons.flash_on;
      case PowerUpType.slowMotion:
        return Icons.speed;
    }
  }

  Color _getColorForType(PowerUpType type) {
    switch (type) {
      case PowerUpType.invincibility:
        return Colors.blue;
      case PowerUpType.scoreMultiplier:
        return Colors.amber;
      case PowerUpType.nitro:
        return Colors.orange;
      case PowerUpType.slowMotion:
        return Colors.purple;
    }
  }

  String _getNameForType(PowerUpType type) {
    switch (type) {
      case PowerUpType.invincibility:
        return 'Shield';
      case PowerUpType.scoreMultiplier:
        return '2x';
      case PowerUpType.nitro:
        return 'Nitro';
      case PowerUpType.slowMotion:
        return 'Slow';
    }
  }
}
