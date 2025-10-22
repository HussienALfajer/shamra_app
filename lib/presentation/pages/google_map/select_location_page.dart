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

  // NEW: reflect whether we actually have runtime location permission
  bool _hasLocationPermission = false; // NEW

  @override
  void initState() {
    super.initState();
    _prepareAndFocusOnUser(); // NEW
  }

  // NEW: High-level orchestrator to ensure service+permission, then drop a pin.
  Future<void> _prepareAndFocusOnUser() async {
    setState(() => _locating = true);
    try {
      final ready = await _ensureLocationReady(); // service + permission
      if (ready) {
        await _goToMyLocationAndDropPin();
      }
    } catch (_) {
      // swallow errors, UI already shows default view
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  // NEW: Make sure GPS is on and permission is granted (or guide user to settings)
  Future<bool> _ensureLocationReady() async {
    // Check service (GPS)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final proceed = await _askEnableLocationService(); // dialog + open settings
      if (!proceed) return false;

      // Wait/poll until user turns GPS on or timeout
      serviceEnabled = await _waitFor(() => Geolocator.isLocationServiceEnabled());
      if (!serviceEnabled) return false;
    }

    // Check permission
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.deniedForever) {
      final opened = await _askOpenAppSettings(); // dialog + open app settings
      if (!opened) {
        _hasLocationPermission = false;
        return false;
      }
      // After returning from settings, check again
      perm = await Geolocator.checkPermission();
    }

    _hasLocationPermission = perm == LocationPermission.always || perm == LocationPermission.whileInUse;
    return _hasLocationPermission;
  }

  // NEW: Actually get user's position, move camera, place marker, reverse geocode
  Future<void> _goToMyLocationAndDropPin() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      final target = LatLng(pos.latitude, pos.longitude);

      // Update camera first time map is ready
      final controller = await _mapCtrl.future;
      _initialCamera = CameraPosition(target: target, zoom: 15);
      await controller.animateCamera(CameraUpdate.newCameraPosition(_initialCamera));

      // Drop/Update marker + reverse geocode
      setState(() => _selected = target);
      await _reverseGeocode(target);
    } catch (e) {
      // If fetching precise location fails, we keep the map at default center
    }
  }

  // CHANGED: onTap now just sets & reverse geocodes (removed stray "geocoding:" label)
  void _onTap(LatLng p) {
    setState(() => _selected = p);
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
              myLocationEnabled: _hasLocationPermission,       // CHANGED
              myLocationButtonEnabled: _hasLocationPermission,  // CHANGED
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

  // =========================
  // Helpers (dialogs + waits)
  // =========================

  // NEW: Ask user to enable device location (GPS) and open system settings
  Future<bool> _askEnableLocationService() async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('تشغيل الموقع'),
        content: const Text('خدمة تحديد الموقع غير مفعّلة. هل تريد فتح الإعدادات لتفعيلها؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              await Geolocator.openLocationSettings();
              if (context.mounted) Navigator.of(context).pop(true);
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  // NEW: Ask user to open app settings when permission is permanently denied
  Future<bool> _askOpenAppSettings() async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('السماح بالوصول للموقع'),
        content: const Text('صلاحية الموقع مرفوضة دائماً. افتح إعدادات التطبيق لمنح الصلاحية.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              await Geolocator.openAppSettings();
              if (context.mounted) Navigator.of(context).pop(true);
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  // NEW: Polling helper to wait until a condition becomes true (or times out)
  Future<bool> _waitFor(Future<bool> Function() check, {int timeoutSec = 25, int intervalMs = 500}) async {
    final end = DateTime.now().add(Duration(seconds: timeoutSec));
    while (DateTime.now().isBefore(end)) {
      try {
        if (await check()) return true;
      } catch (_) {}
      await Future.delayed(Duration(milliseconds: intervalMs));
    }
    return false;
  }
}
