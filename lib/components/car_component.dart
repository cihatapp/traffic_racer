import 'package:flame/components.dart';
import '../game/traffic_racer_game.dart';
import 'dart:ui';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class CarComponent extends SpriteComponent with HasGameRef<TrafficRacerGame> {
  static const double moveSpeed = 5.0;
  int moveDirection = 0;
  Effect? _shieldEffect;
  bool _isShieldActive = false;

  CarComponent() : super(size: Vector2(150, 75));

  static Future<CarComponent> create(TrafficRacerGame game) async {
    final component = CarComponent();
    component.sprite = Sprite(game.images.fromCache('car.png'));
    component.position = Vector2(game.size.x / 2 - component.size.x / 2, game.size.y - component.size.y - 20);
    return component;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (moveDirection != 0) {
      position.x += moveDirection * moveSpeed;
      position.x = position.x.clamp(0, gameRef.size.x - size.x);
    }

    // Update shield effect based on game's invincibility state
    final isInvincible = gameRef.isInvincible;
    if (isInvincible && !_isShieldActive) {
      _activateShield();
    } else if (!isInvincible && _isShieldActive) {
      _deactivateShield();
    }
  }

  void _activateShield() {
    _isShieldActive = true;
    _shieldEffect?.removeFromParent();

    final glowPaint = Paint()
      ..imageFilter = ImageFilter.blur(sigmaX: 8, sigmaY: 8)
      ..colorFilter = const ColorFilter.mode(Colors.blue, BlendMode.srcIn);

    _shieldEffect = ColorEffect(
      const Color.fromARGB(77, 33, 149, 243),
      EffectController(
        duration: 1.0,
        reverseDuration: 1.0,
        infinite: true,
      ),
    );

    add(_shieldEffect!);
    paint = glowPaint;
  }

  void _deactivateShield() {
    _isShieldActive = false;
    _shieldEffect?.removeFromParent();
    _shieldEffect = null;
    paint = Paint();
  }

  void move(int direction) {
    moveDirection = direction;
  }

  void stopMoving() {
    moveDirection = 0;
  }

  void reset() {
    position = Vector2(game.size.x / 2 - size.x / 2, game.size.y - size.y - 50);
    stopMoving();
    _deactivateShield();
  }

  bool checkCollision(PositionComponent other) {
    final carRect = Rect.fromCenter(
      center: center.toOffset(),
      width: width * 0.2,
      height: height * 0.2,
    );
    return carRect.overlaps(other.toRect());
  }
}
