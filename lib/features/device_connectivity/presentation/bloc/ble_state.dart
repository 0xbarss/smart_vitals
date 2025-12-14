import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BleState {}

class BleInitial extends BleState {}

class BleScanning extends BleState {
  final List<ScanResult> results;

  BleScanning(this.results);
}

class BleConnected extends BleState {
  final BluetoothDevice device;

  BleConnected(this.device);
}
