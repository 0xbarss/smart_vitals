import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

abstract class StepCounterService {
  Future<int> getTodaySteps();
  Future<bool> requestPermissions();
}

class StepCounterServiceImpl implements StepCounterService {
  final Health _health = Health();

  bool _useHealthApi = false;
  int _fallbackSteps = 0;

  final double _threshold = 7;
  int _lastStepTime = 0;

  @override
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await _health.getHealthConnectSdkStatus();
      if (status != HealthConnectSdkStatus.sdkAvailable) {
        _initSensorFallback();
        return true;
      }
    }

    var types = [HealthDataType.STEPS];
    bool? hasPermissions = await _health.hasPermissions(types);

    if (hasPermissions == false) {
      bool authorized = await _health.requestAuthorization(types);
      if (authorized) {
        _useHealthApi = true;
        return true;
      }
    } else {
      _useHealthApi = true;
      return true;
    }

    _initSensorFallback();
    return true;
  }

  @override
  Future<int> getTodaySteps() async {
    if (_useHealthApi) {
      try {
        final now = DateTime.now();
        final midnight = DateTime(now.year, now.month, now.day);
        int? steps = await _health.getTotalStepsInInterval(midnight, now);
        return steps ?? 0;
      } catch (e) {
        return 0;
      }
    }

    return _fallbackSteps;
  }

  void _initSensorFallback() async {
    var status = await Permission.activityRecognition.status;
    if (status.isDenied) {
      await Permission.activityRecognition.request();
    }

    userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      _detectStep(event);
    });
  }

  void _detectStep(UserAccelerometerEvent event) {
    double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    int now = DateTime.now().millisecondsSinceEpoch;

    if (magnitude > _threshold && (now - _lastStepTime) > 500) {
      _fallbackSteps++;
      _lastStepTime = now;
    }
  }
}