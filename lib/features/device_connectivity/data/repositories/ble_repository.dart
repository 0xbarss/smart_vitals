import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleRepository {
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  Future<void> startScan() async {
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connect(BluetoothDevice device) async {
    await device.connect(
      license: License.free,
      timeout: const Duration(seconds: 15),
      autoConnect: false,
    );
  }

  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }

  Future<void> discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();

    for (var service in services) {
      if (service.uuid.toString().toUpperCase().contains("180D")) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString().toUpperCase().contains("2A37")) {
            await characteristic.setNotifyValue(true);
            characteristic.lastValueStream.listen((value) {
              print("❤️ Live Data from ESP32: $value");
            });
          }
        }
      }
    }
  }
}