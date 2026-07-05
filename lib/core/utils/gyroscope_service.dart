import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GyroscopeService with ChangeNotifier {
  StreamSubscription<GyroscopeEvent>? _subscription;

  double _x = 0.0;
  double _y = 0.0;
  double _z = 0.0;

  double get x => _x;
  double get y => _y;
  double get z => _z;

  void startListening() {
    _subscription = gyroscopeEventStream().listen((GyroscopeEvent event) {
      _x = event.x;
      _y = event.y;
      _z = event.z;
      notifyListeners();
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
