// lib/screens/qr_scan_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_toast.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});
  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool _handled = false;
  bool _importing = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled || _importing) return;
    if (capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null || !raw.startsWith('tripline://trip/')) return;
    final tripId = raw.substring('tripline://trip/'.length);
    if (tripId.isEmpty) return;

    _handled = true;
    setState(() => _importing = true);
    try {
      await SupabaseDataService().importTrip(tripId);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Could not import trip: $e', type: ToastType.error);
        setState(() { _importing = false; _handled = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white, elevation: 0,
        title: const Text('Scan Trip QR Code', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold))),
      body: Stack(fit: StackFit.expand, children: [
        MobileScanner(onDetect: _onDetect),
        if (_importing)
          Container(
            color: Colors.black54,
            child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircularProgressIndicator(color: AppColors.gold),
              SizedBox(height: 16),
              Text('Importing trip…', style: TextStyle(fontFamily: 'Nunito', color: Colors.white)),
            ])),
          ),
      ]),
    );
  }
}
