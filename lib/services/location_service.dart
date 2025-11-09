import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:svpro/app_navigator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  static StreamSubscription<Position>? locationStream;
  static Position? positionStream;

  /// Xin quyền và kiểm tra
  static Future<bool> _prepare() async {
    // B1: Kiểm tra GPS có bật chưa
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      await AppNavigator.showAlertDialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("GPS chưa bật"),
          content: const Text("Vui lòng bật GPS để tiếp tục sử dụng ứng dụng."),
          actions: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: AppNavigator.pop,
                child: const Text("Đã bật"),
              ),
            ),
          ],
        ),
      );
      return false;
    }

    // B2: Kiểm tra quyền
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      await AppNavigator.showAlertDialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Quyền vị trí"),
          content: const Text(
            "Ứng dụng cần quyền truy cập vị trí để hiển thị bản đồ, chỉ đường và xác định vị trí.\n\n"
                "Dữ liệu vị trí chỉ được sử dụng trong ứng dụng để hỗ trợ định vị và không được chia sẻ với bên thứ ba.",
          ),
          actions: [
            TextButton(
              onPressed: AppNavigator.pop,
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                AppNavigator.pop();
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied) {
                  AppNavigator.error("Bạn chưa cấp quyền vị trí!");
                }
              },
              child: const Text("Đồng ý"),
            ),
          ],
        ),
      );
    }

    if (permission == LocationPermission.deniedForever) {
      await AppNavigator.showAlertDialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Quyền bị chặn"),
          content: const Text(
            "Bạn đã từ chối quyền vị trí và chọn 'Không hỏi lại'.\n"
                "Vui lòng vào Cài đặt để cấp quyền thủ công.",
          ),
          actions: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  AppNavigator.pop();
                  Geolocator.openAppSettings();
                },
                child: const Text("Mở cài đặt"),
              ),
            ),
          ],
        ),
      );
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Lấy vị trí hiện tại
  static Future<Position?> getCurrentLocation() async {
    final ok = await _prepare();
    if (!ok) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint("error: $e");
      return null;
    }
  }

  /// Bắt đầu stream vị trí
  static Future<StreamSubscription<Position>?> startLocationStream(
      Function(Position) onLocation, {
        int distanceFilter = 10,
      }) async {
    final ok = await _prepare();
    if (!ok) return null;

    final sub = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: distanceFilter,
      ),
    ).listen(onLocation);
    return sub;
  }

  /// Lấy địa chỉ văn bản từ vị trí hiện tại
  static Future<String?> getCurrentAddress() async {
    final position = await getCurrentLocation();
    if (position == null) return null;

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final address = [
          place.name,
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(", ");

        return address;
      }
    } catch (e) {
      debugPrint("error: $e");
    }
    return null;
  }

  /// Lấy GPS (lat, lng) từ địa chỉ văn bản
  static Future<Location?> getGpsFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) return locations.first;
    } catch (e) {
      debugPrint("error: $e");
    }
    return null;
  }

  /// Tính khoảng cách giữa 2 điểm
  static String formatDistance(
      double lat1, double lng1, double lat2, double lng2) {
    final meters = Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
    if (meters < 1000) {
      return "${meters.toStringAsFixed(0)}m";
    } else {
      return "${(meters / 1000).toStringAsFixed(1)}km";
    }
  }

  /// Mở bản đồ ngoài
  static Future<void> openMap(double lat, double lng) async {
    final googleUrl =
    Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    final appleUrl = Uri.parse("http://maps.apple.com/?q=$lat,$lng");

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleUrl)) {
      await launchUrl(appleUrl, mode: LaunchMode.externalApplication);
    } else {
      AppNavigator.warning("Không mở được bản đồ");
    }
  }
}
