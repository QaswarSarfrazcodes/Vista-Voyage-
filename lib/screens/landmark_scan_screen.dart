// lib/screens/landmark_scan_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/destination_model.dart';
import '../services/landmark_scanner_service.dart';
import '../theme/app_colors.dart';

class LandmarkScanScreen extends StatefulWidget {
  const LandmarkScanScreen({super.key});
  @override
  State<LandmarkScanScreen> createState() => _LandmarkScanScreenState();
}

class _LandmarkScanScreenState extends State<LandmarkScanScreen> {
  File? _image;
  String? _result;
  bool _loading = false;

  // ImagePicker is only ever instantiated here, on explicit tap — never at
  // app root or in another screen's initState, mirroring the same lazy-init
  // discipline V7 already established for mobile_scanner's camera controller.
  Future<void> _capture(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    final file = File(picked.path);
    setState(() { _image = file; _loading = true; _result = null; });
    final result = await LandmarkScannerService.identifyLandmark(file);
    if (mounted) setState(() { _result = result; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Scan a Landmark', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(_image!, height: 220, width: double.infinity, fit: BoxFit.cover),
            )
          else
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(color: AppColors.cardTint, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Icon(Icons.camera_alt_outlined, size: 56, color: AppColors.primary)),
            ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
                onPressed: _loading ? null : () => _capture(ImageSource.camera),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery', style: TextStyle(fontFamily: 'Nunito')),
                onPressed: _loading ? null : () => _capture(ImageSource.gallery),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary)),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          if (_loading) const CircularProgressIndicator(color: AppColors.primary),
          if (_result != null)
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.cardTint, borderRadius: BorderRadius.circular(16)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [
                      Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 20),
                      SizedBox(width: 8),
                      Text('What we found', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 15)),
                    ]),
                    const SizedBox(height: 10),
                    Text(_result!, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, height: 1.5, color: AppColors.charcoal)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                        label: const Text('Ask AI Assistant more about this', style: TextStyle(fontFamily: 'Nunito')),
                        onPressed: () => Navigator.pushNamed(context, '/ai', arguments: DestinationModel(
                          id: 'scanned-landmark',
                          name: 'this landmark',
                          country: '',
                          imageUrl: '',
                          description: _result!,
                          rating: 0,
                        )),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary)),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
