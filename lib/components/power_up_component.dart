import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/traffic_racer_game.dart';
import 'icon_component.dart';
import 'dart:math';

enum PowerUpType {
  invincibility,
  scoreMultiplier,
  slowMotion,
  nitro,
}

class PowerUpComponent extends IconComponent {
  final TrafficRacerGame game;
  final PowerUpType type;
  double duration = 5.0; // Duration in seconds
  bool isActive = false;

  PowerUpComponent(this.game, this.type)
      : super(
          icon: _getIconForType(type),
          size: Vector2(40, 40),
          position: Vector2(0, 0),
          color: _getColorForType(type),
        );

  static IconData _getIconForType(PowerUpType type) {
    switch (type) {
      case PowerUpType.invincibility:
        return Icons.shield;
      case PowerUpType.scoreMultiplier:
        return Icons.star;
      case PowerUpType.slowMotion:
        return Icons.speed;
      case PowerUpType.nitro:
        return Icons.flash_on;
    }
  }

  static Color _getColorForType(PowerUpType type) {
    switch (type) {
      case PowerUpType.invincibility:
        return Colors.blue;
      case PowerUpType.scoreMultiplier:
        return Colors.yellow;
      case PowerUpType.slowMotion:
        return Colors.purple;
      case PowerUpType.nitro:
        return Colors.orange;
    }
  }

  static Future<PowerUpComponent> create(TrafficRacerGame game) async {
    final random = Random();
    final powerUpTypes = PowerUpType.values;
    final type = powerUpTypes[random.nextInt(powerUpTypes.length)];
    final powerUp = PowerUpComponent(game, type);

    const minX = 20.0;
    final maxX = game.size.x - powerUp.size.x - 20.0;
    final powerUpX = minX + random.nextDouble() * (maxX - minX);

    powerUp.position = Vector2(powerUpX, -powerUp.size.y);
    return powerUp;
  }

  void activate() {
    isActive = true;
    switch (type) {
      case PowerUpType.invincibility:
        game.isInvincible = true;
        break;
      case PowerUpType.scoreMultiplier:
        game.scoreMultiplier = 2;
        break;
      case PowerUpType.slowMotion:
        game.gameSpeed = 0.5;
        break;
      case PowerUpType.nitro:
        game.gameSpeed = 2.0;
        break;
    }
  }

  void deactivate() {
    isActive = false;
    switch (type) {
      case PowerUpType.invincibility:
        game.isInvincible = false;
        break;
      case PowerUpType.scoreMultiplier:
        game.scoreMultiplier = 1;
        break;
      case PowerUpType.slowMotion:
        game.gameSpeed = 1.0;
        break;
      case PowerUpType.nitro:
        game.gameSpeed = 1.0;
        break;
    }
  }
}
