import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import '../components/car_component.dart';
import '../components/road_component.dart';
import '../components/obstacle_component.dart';
import '../components/power_up_component.dart';
import 'package:flame/events.dart';
import 'dart:async' as async;

// TrafficRacerGame class: Main game class that manages the game logic and components
class TrafficRacerGame extends FlameGame with HorizontalDragDetector, HasCollisionDetection {
  late CarComponent car;
  late RoadComponent road1;
  late RoadComponent road2;
  final List<ObstacleComponent> obstacles = [];
  final List<PowerUpComponent> powerUps = [];
  late TextComponent scoreText;
  bool isPaused = true;
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  int score = 0;
  bool isGameOver = false;
  double elapsedTime = 0.0;
  Vector2? dragStartPosition;

  // Power-up related properties
  bool isInvincible = false;
  double scoreMultiplier = 1.0;
  double gameSpeed = 1.0;
  final Map<PowerUpType, async.Timer?> activePowerUps = {};

  // Difficulty related properties
  int currentLevel = 1;
  double baseObstacleSpeed = 300.0;
  double obstacleSpawnInterval = 3.0;
  double timeSinceLastObstacle = 0.0;
  double timeSinceLastPowerUp = 0.0;
  double powerUpSpawnInterval = 10.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await images.loadAllImages();

    road1 = await RoadComponent.create(this);
    road2 = await RoadComponent.create(this);
    road2.position.y = -size.y;
    await addAll([road1, road2]);

    car = await CarComponent.create(this);
    await add(car);

    await spawnObstacle();

    pauseEngine();
    overlays.add('landingPage');
  }

  @override
  void update(double dt) {
    if (!isPaused && !isGameOver) {
      super.update(dt);

      elapsedTime += dt;
      score = ((elapsedTime * 10) * scoreMultiplier).toInt();
      scoreNotifier.value = score;

      updateDifficulty();
      updateRoads(dt);
      updateObstacles(dt);
      updatePowerUps(dt);
      checkCollisions();

      // Spawn obstacles based on interval
      timeSinceLastObstacle += dt;
      if (timeSinceLastObstacle >= obstacleSpawnInterval) {
        spawnObstacle();
        timeSinceLastObstacle = 0;
      }

      // Spawn power-ups based on interval
      timeSinceLastPowerUp += dt;
      if (timeSinceLastPowerUp >= powerUpSpawnInterval) {
        spawnPowerUp();
        timeSinceLastPowerUp = 0;
      }
    }
  }

  void updateDifficulty() {
    // Update level based on score
    int newLevel = (score / 1000).floor() + 1;
    if (newLevel != currentLevel) {
      currentLevel = newLevel;
      // Increase difficulty
      baseObstacleSpeed = 300.0 + (currentLevel - 1) * 50.0;
      obstacleSpawnInterval = max(1.0, 3.0 - (currentLevel - 1) * 0.2);
    }
  }

  void updateRoads(double dt) {
    final roadSpeed = 300.0 * gameSpeed;
    road1.position.y += roadSpeed * dt;
    road2.position.y += roadSpeed * dt;

    if (road1.position.y >= size.y) {
      road1.position.y = road2.position.y - size.y;
    }
    if (road2.position.y >= size.y) {
      road2.position.y = road1.position.y - size.y;
    }
  }

  void updateObstacles(double dt) {
    for (var obstacle in List.from(obstacles)) {
      obstacle.position.y += baseObstacleSpeed * gameSpeed * dt;
      if (obstacle.position.y > size.y) {
        remove(obstacle);
        obstacles.remove(obstacle);
      }
    }
  }

  void updatePowerUps(double dt) {
    for (var powerUp in List.from(powerUps)) {
      powerUp.position.y += baseObstacleSpeed * gameSpeed * dt;
      if (powerUp.position.y > size.y) {
        remove(powerUp);
        powerUps.remove(powerUp);
      }
    }
  }

  void checkCollisions() {
    if (!isInvincible) {
      for (var obstacle in obstacles) {
        if (car.checkCollision(obstacle)) {
          gameOver();
          break;
        }
      }
    }

    for (var powerUp in List.from(powerUps)) {
      if (car.checkCollision(powerUp)) {
        activatePowerUp(powerUp);
        remove(powerUp);
        powerUps.remove(powerUp);
      }
    }
  }

  Future<void> spawnObstacle() async {
    if (isGameOver) return;
    final obstacle = await ObstacleComponent.create(this);
    obstacles.add(obstacle);
    await add(obstacle);
  }

  Future<void> spawnPowerUp() async {
    if (isGameOver) return;
    final powerUp = await PowerUpComponent.create(this);
    powerUps.add(powerUp);
    await add(powerUp);
  }

  void activatePowerUp(PowerUpComponent powerUp) {
    // Deactivate existing power-up of the same type
    activePowerUps[powerUp.type]?.cancel();

    // Activate the new power-up
    powerUp.activate();

    // Set timer for deactivation
    activePowerUps[powerUp.type] = async.Timer(
      Duration(seconds: powerUp.duration.toInt()),
      () {
        powerUp.deactivate();
        activePowerUps[powerUp.type] = null;
      },
    );
  }

  void gameOver() {
    isGameOver = true;
    overlays.add('gameOver');
  }

  void reset() {
    isGameOver = false;
    score = 0;
    scoreNotifier.value = 0;
    elapsedTime = 0.0;
    currentLevel = 1;
    gameSpeed = 1.0;
    scoreMultiplier = 1.0;
    isInvincible = false;

    // Cancel all active power-ups
    for (var timer in activePowerUps.values) {
      timer?.cancel();
    }
    activePowerUps.clear();

    car.reset();

    // Clear obstacles and power-ups
    for (var obstacle in obstacles) {
      obstacle.removeFromParent();
    }
    obstacles.clear();

    for (var powerUp in powerUps) {
      powerUp.removeFromParent();
    }
    powerUps.clear();

    spawnObstacle();

    // Reset car position
    car.position = Vector2(size.x / 3, size.y - car.size.y);

    // Reset roads
    road1.position.y = 0;
    road2.position.y = -size.y;

    // Update game state
    resumeEngine();
    overlays.remove('gameOver');
  }

  @override
  void onHorizontalDragStart(DragStartInfo info) {
    if (isPaused || isGameOver) return;
    dragStartPosition = info.eventPosition.global;
  }

  @override
  void onHorizontalDragUpdate(DragUpdateInfo info) {
    if (isPaused || isGameOver || dragStartPosition == null) return;

    final screenWidth = size.x;
    final laneWidth = screenWidth / 4;
    final dragDistance = info.eventPosition.global.x - dragStartPosition!.x;
    final dragDirection = dragDistance.sign;

    if (dragDistance.abs() > laneWidth / 2) {
      final newX = (car.position.x + dragDirection * laneWidth).clamp(0.0, screenWidth - car.size.x);
      car.position.x = newX;
      dragStartPosition = null;
    }
  }

  @override
  void onHorizontalDragEnd(DragEndInfo info) {
    dragStartPosition = null;
  }

  @override
  void resumeEngine() {
    isPaused = false;
    overlays.add('hud');
  }

  @override
  void pauseEngine() {
    isPaused = true;
    overlays.remove('hud');
  }
}
