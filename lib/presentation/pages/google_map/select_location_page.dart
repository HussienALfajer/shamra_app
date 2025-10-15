import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/constants/colors.dart';
import '../../widgets/common_widgets.dart';

class SelectLocationPage extends StatefulWidget {
  const SelectLocationPage({super.key});

  @override
  State<SelectLocationPage> createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  final Completer<GoogleMapController> _mapCtrl = Completer<GoogleMapController>();

  static const LatLng _kDefaultCenter = LatLng(34.802075, 38.996815);
  CameraPosition _initialCamera = const CameraPosition(target: _kDefaultCenter, zoom: 12);

  LatLng? _selected;
  String? _address;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _goToMyLocationIfPermitted();
  }

  Future<void> _goToMyLocationIfPermitted() async {
    setState(() => _locating = true);
    try {
      bool svc = await Geolocator.isLocationServiceEnabled();
      if (!svc) {
        setState(() => _locating = false);
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() => _locating = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      final controller = await _mapCtrl.future;
      final target = LatLng(pos.latitude, pos.longitude);
      _initialCamera = CameraPosition(target: target, zoom: 15);
      await controller.animateCamera(CameraUpdate.newCameraPosition(_initialCamera));
    } catch (_) {
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _onTap(LatLng p) {
    setState(() => _selected = p);
    geocoding:
    _reverseGeocode(p);
  }

  Future<void> _reverseGeocode(LatLng p) async {
    try {
      final placemarks = await placemarkFromCoordinates(p.latitude, p.longitude);
      final first = placemarks.first;
      setState(() {
        _address = [
          if ((first.street ?? '').isNotEmpty) first.street,
          if ((first.subLocality ?? '').isNotEmpty) first.subLocality,
          if ((first.locality ?? '').isNotEmpty) first.locality,
          if ((first.administrativeArea ?? '').isNotEmpty) first.administrativeArea,
          if ((first.country ?? '').isNotEmpty) first.country,
        ].whereType<String>().join('، ');
      });
    } catch (_) {}
  }

  Future<void> _confirm() async {
    if (_selected == null) {
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'الرجاء اختيار موقع الاستلام على الخريطة',
        type: SnackBarType.warning,
      );
      return;
    }

    Get.back(result: {
      'lat': _selected!.latitude,
      'lng': _selected!.longitude,
      'address': _address, // قد تكون null
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(
          title: 'تحديد موقع الاستلام',
          showBackButton: true,
        ),
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialCamera,
              onMapCreated: (c) {
                if (!_mapCtrl.isCompleted) _mapCtrl.complete(c);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              zoomControlsEnabled: false,
              onTap: _onTap,
              markers: {
                if (_selected != null)
                  Marker(
                    markerId: const MarkerId('selected'),
                    position: _selected!,
                    draggable: true,
                    onDragEnd: (p) => setState(() => _selected = p),
                  ),
              },
            ),

            if (_locating)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('جاري تحديد موقعك...', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_pin, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selected == null
                                ? 'اضغط على الخريطة لاختيار نقطة الاستلام'
                                : (_address ?? 'إحداثيات: ${_selected!.latitude.toStringAsFixed(6)}, ${_selected!.longitude.toStringAsFixed(6)}'),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ShamraButton(
                            text: 'تأكيد وإتمام الطلب',
                            onPressed: _confirm,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}