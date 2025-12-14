import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BleEvent {}

class StartScanEvent extends BleEvent {}

class ConnectToDeviceEvent extends BleEvent {
  final BluetoothDevice device;

  ConnectToDeviceEvent(this.device);
}
