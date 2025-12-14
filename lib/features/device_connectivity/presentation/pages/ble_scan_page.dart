import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart' as di;
import '../bloc/ble_bloc.dart';
import '../bloc/ble_event.dart';
import '../bloc/ble_state.dart';

class BleScanPage extends StatelessWidget {
  const BleScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<BleBloc>()..add(StartScanEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text("Find ESP32")),
        body: BlocBuilder<BleBloc, BleState>(
          builder: (context, state) {
            if (state is BleConnected) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.bluetooth_connected,
                      size: 64,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Connected to ${state.device.platformName}",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    const Text("Check console logs for data stream"),
                  ],
                ),
              );
            }

            if (state is BleScanning) {
              if (state.results.isEmpty) {
                return const Center(child: Text("Scanning for devices..."));
              }
              return ListView.builder(
                itemCount: state.results.length,
                itemBuilder: (context, index) {
                  final result = state.results[index];
                  return ListTile(
                    title: Text(result.device.platformName),
                    subtitle: Text(result.device.remoteId.toString()),
                    trailing: ElevatedButton(
                      onPressed: () {
                        context.read<BleBloc>().add(
                          ConnectToDeviceEvent(result.device),
                        );
                      },
                      child: const Text("Connect"),
                    ),
                  );
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
