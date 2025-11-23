#!/usr/bin/env bash

sudo rm -rf ../ios/Pods && rm -rf ../ios/Podfile.lock
flutter clean
flutter pub get