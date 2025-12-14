import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../data/repositories/ble_repository.dart';

import 'ble_event.dart';
import 'ble_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  final BleRepository repository;
  StreamSubscription? _scanSubscription;

  BleBloc(this.repository) : super(BleInitial()) {
    on<StartScanEvent>(_onStartScan);
    on<ConnectToDeviceEvent>(_onConnect);
  }

  Future<void> _onStartScan(
    StartScanEvent event,
    Emitter<BleState> emit,
  ) async {
    await repository.startScan();

    await emit.forEach(
      repository.scanResults,
      onData: (List<ScanResult> results) {
        final namedDevices = results
            .where((r) => r.device.platformName.isNotEmpty)
            .toList();
        return BleScanning(namedDevices);
      },
    );
  }

  Future<void> _onConnect(
    ConnectToDeviceEvent event,
    Emitter<BleState> emit,
  ) async {
    try {
      await repository.stopScan();
      await repository.connect(event.device);
      emit(BleConnected(event.device));

      await repository.discoverServices(event.device);
    } catch (e) {
      print("Connection failed: $e");
    }
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }
}
