import 'dart:async';
import 'dart:convert';

import 'package:builders_mobile/const/app_config.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

const _crimson = Color(0xFF9E1B32);
const _ink = Color(0xFF14161A);
const _muted = Color(0xFF6B7280);
const _border = Color(0xFFE2E4E9);
const _bg = Color(0xFFFAFAFB);
const _green = Color(0xFF16803C);
const _amber = Color(0xFFB45309);
const _blue = Color(0xFF1D4ED8);

/// Returned via Navigator.pop when the user confirms a location.
class PickedLocation {
  final LatLng latLng;
  final String address;
  final String? area;
  final String? city;
  final String? state;
  final String? postalCode;

  const PickedLocation({
    required this.latLng,
    required this.address,
    this.area,
    this.city,
    this.state,
    this.postalCode,
  });
}

class _Suggestion {
  final String placeId;
  final String title;
  final String subtitle;
  const _Suggestion(this.placeId, this.title, this.subtitle);
}

class MapPage1 extends StatefulWidget {
  /// Optional starting point. Falls back to the user's current location.
  final LatLng? initialPosition;
  const MapPage1({super.key, this.initialPosition});

  @override
  State<MapPage1> createState() => _MapPage1State();
}

class _MapPage1State extends State<MapPage1> {
  final key = AppConfig.googleApiKey;

  static const _fallback = LatLng(12.9716, 77.5946); // Bengaluru
  static const double _sheetBase = 240;

  GoogleMapController? _map;
  LatLng _center = _fallback;

  bool _moving = false;
  bool _locating = false;
  bool _hasPermission = false;
  bool _geocoding = false;
  String? _geoError;

  PickedLocation? _picked;
  int _geoRequestId = 0;

  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;
  List<_Suggestion> _suggestions = [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _center = widget.initialPosition!;
    } else {
      _goToMyLocation(initial: true);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _map?.dispose();
    super.dispose();
  }

  // ───────────── Location ─────────────

  Future<void> _goToMyLocation({bool initial = false}) async {
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _toast('Turn on location services to use your current location.');
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _toast(perm == LocationPermission.deniedForever
            ? 'Location permission is blocked. Enable it from app settings.'
            : 'Location permission denied.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      final target = LatLng(pos.latitude, pos.longitude);
      if (mounted) setState(() => _hasPermission = true);
      _center = target;
      await _map?.animateCamera(CameraUpdate.newLatLngZoom(target, 17));
      if (_map == null) _reverseGeocode(target);
    } catch (_) {
      if (!initial) _toast('Could not get your current location.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  // ───────────── Reverse geocoding ─────────────

  Future<void> _reverseGeocode(LatLng pos) async {
    final id = ++_geoRequestId;
    setState(() {
      _geocoding = true;
      _geoError = null;
    });
    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'latlng': '${pos.latitude},${pos.longitude}',
        'key': key,
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (id != _geoRequestId || !mounted) return; // stale response

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final status = json['status'] as String?;
      final results = (json['results'] as List?) ?? [];

      if (status != 'OK' || results.isEmpty) {
        setState(() {
          _picked = null;
          _geoError = status == 'ZERO_RESULTS'
              ? 'No address found for this spot.'
              : 'Could not fetch address ($status).';
        });
        return;
      }

      final top = results.first as Map<String, dynamic>;
      final comps = (top['address_components'] as List)
          .cast<Map<String, dynamic>>();

      String? pick(List<String> types) {
        for (final t in types) {
          for (final c in comps) {
            if ((c['types'] as List).contains(t)) {
              return c['long_name'] as String;
            }
          }
        }
        return null;
      }

      setState(() {
        _picked = PickedLocation(
          latLng: pos,
          address: top['formatted_address'] as String,
          area: pick(['sublocality_level_1', 'sublocality', 'neighborhood']),
          city: pick(['locality', 'administrative_area_level_2']),
          state: pick(['administrative_area_level_1']),
          postalCode: pick(['postal_code']),
        );
      });
    } catch (_) {
      if (id != _geoRequestId || !mounted) return;
      setState(() {
        _picked = null;
        _geoError = 'Network error. Check your connection.';
      });
    } finally {
      if (id == _geoRequestId && mounted) setState(() => _geocoding = false);
    }
  }

  // ───────────── Places search ─────────────

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    if (text.trim().length < 3) {
      setState(() {
        _suggestions = [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _fetchSuggestions(text.trim());
    });
  }

  Future<void> _fetchSuggestions(String input) async {
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        {
          'input': input,
          'location': '${_center.latitude},${_center.longitude}',
          'radius': '50000',
          'key': key,
        },
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (!mounted || _searchCtrl.text.trim() != input) return;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final preds = ((json['predictions'] as List?) ?? [])
          .cast<Map<String, dynamic>>();
      setState(() {
        _suggestions = preds.map((p) {
          final f = (p['structured_formatting'] as Map?) ?? {};
          return _Suggestion(
            p['place_id'] as String,
            (f['main_text'] ?? p['description'] ?? '') as String,
            (f['secondary_text'] ?? '') as String,
          );
        }).toList();
      });
    } catch (_) {
      if (mounted) setState(() => _suggestions = []);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _selectSuggestion(_Suggestion s) async {
    _searchFocus.unfocus();
    setState(() {
      _searchCtrl.text = s.title;
      _suggestions = [];
    });
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        {'place_id': s.placeId, 'fields': 'geometry', 'key': key},
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final loc = json['result']?['geometry']?['location'];
      if (loc == null) throw Exception('no geometry');
      final target = LatLng(
        (loc['lat'] as num).toDouble(),
        (loc['lng'] as num).toDouble(),
      );
      await _map?.animateCamera(CameraUpdate.newLatLngZoom(target, 17));
    } catch (_) {
      _toast('Could not open that place.');
    }
  }

  // ───────────── Helpers ─────────────

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  void _confirm() {
    final p = _picked;
    if (p == null) return;
    Navigator.pop(context, p);
  }

  // ───────────── UI ─────────────

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final sheetH = _sheetBase + bottomInset;

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 16),
            padding: EdgeInsets.only(bottom: sheetH),
            myLocationEnabled: _hasPermission,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (c) {
              _map = c;
              _reverseGeocode(_center);
            },
            onCameraMoveStarted: () {
              if (!_moving) setState(() => _moving = true);
              if (_searchFocus.hasFocus) _searchFocus.unfocus();
            },
            onCameraMove: (pos) => _center = pos.target,
            onCameraIdle: () {
              setState(() => _moving = false);
              _reverseGeocode(_center);
            },
          ),

          // Centre pin
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: sheetH,
            child: IgnorePointer(child: Center(child: _Pin(lifted: _moving))),
          ),

          // Search + suggestions
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  _SearchBar(
                    controller: _searchCtrl,
                    focusNode: _searchFocus,
                    loading: _searching,
                    onChanged: _onSearchChanged,
                    onBack: () => Navigator.maybePop(context),
                    onClear: () {
                      _searchCtrl.clear();
                      setState(() => _suggestions = []);
                    },
                  ),
                  if (_suggestions.isNotEmpty)
                    _SuggestionList(
                      items: _suggestions,
                      onTap: _selectSuggestion,
                    ),
                ],
              ),
            ),
          ),

          // My-location button
          Positioned(
            right: 16,
            bottom: sheetH + 16,
            child: _LocateButton(
              loading: _locating,
              onTap: () => _goToMyLocation(),
            ),
          ),

          // Bottom sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _AddressSheet(
              height: sheetH,
              bottomInset: bottomInset,
              loading: _geocoding || _moving,
              error: _geoError,
              picked: _picked,
              center: _center,
              onRetry: () => _reverseGeocode(_center),
              onConfirm: (_geocoding || _moving || _picked == null)
                  ? null
                  : _confirm,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Pin ─────────────────────────

class _Pin extends StatelessWidget {
  final bool lifted;
  const _Pin({required this.lifted});

  @override
  Widget build(BuildContext context) {
    // The tip of the pin sits exactly on the map centre.
    return SizedBox(
      width: 60,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ground shadow at the exact centre
          Positioned(
            top: 60 - 4,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: lifted ? 14 : 20,
              height: lifted ? 5 : 8,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(lifted ? 40 : 70),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // pin body
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            bottom: lifted ? 66 : 56,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _crimson,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: _crimson.withAlpha(90),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                Container(width: 3, height: 14, color: _crimson),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Search ─────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool loading;
  final ValueChanged<String> onChanged;
  final VoidCallback onBack;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.loading,
    required this.onChanged,
    required this.onBack,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: _ink),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              cursorColor: _crimson,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
              decoration: const InputDecoration(
                hintText: 'Search area, street or landmark',
                hintStyle: TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _crimson,
                ),
              ),
            )
          else
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, v, __) => v.text.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(right: 14),
                      child: Icon(Icons.search_rounded, color: _muted),
                    )
                  : IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded, color: _muted),
                    ),
            ),
        ],
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  final List<_Suggestion> items;
  final ValueChanged<_Suggestion> onTap;
  const _SuggestionList({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: items.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 60, color: _border),
          itemBuilder: (_, i) {
            final s = items[i];
            return InkWell(
              onTap: () => onTap(s),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _border),
                      ),
                      child: const Icon(
                        Icons.place_outlined,
                        size: 18,
                        color: _muted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                          if (s.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              s.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: _muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ───────────────────────── Locate button ─────────────────────────

class _LocateButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const _LocateButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black.withAlpha(60),
      shape: const CircleBorder(side: BorderSide(color: _border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: loading ? null : onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _crimson,
                    ),
                  )
                : const Icon(Icons.my_location_rounded, color: _crimson),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Bottom sheet ─────────────────────────

class _AddressSheet extends StatelessWidget {
  final double height;
  final double bottomInset;
  final bool loading;
  final String? error;
  final PickedLocation? picked;
  final LatLng center;
  final VoidCallback onRetry;
  final VoidCallback? onConfirm;

  const _AddressSheet({
    required this.height,
    required this.bottomInset,
    required this.loading,
    required this.error,
    required this.picked,
    required this.center,
    required this.onRetry,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: const Border(top: BorderSide(color: _border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 4,
                height: 12,
                decoration: BoxDecoration(
                  color: _crimson,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'SELECTED LOCATION',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w800,
                  color: _muted,
                ),
              ),
              const Spacer(),
              Text(
                '${center.latitude.toStringAsFixed(4)}, ${center.longitude.toStringAsFixed(4)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: _body()),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: _crimson,
                disabledBackgroundColor: _border,
                foregroundColor: Colors.white,
                disabledForegroundColor: _muted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: const Text('Confirm location'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (error != null && !loading) {
      return Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _amber.withAlpha(24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.wrong_location_outlined, color: _amber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error!,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: _crimson),
            child: const Text(
              'Retry',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      );
    }

    if (loading || picked == null) {
      return const _AddressSkeleton();
    }

    final p = picked!;
    final chips = <_ChipData>[
      if (p.area != null) _ChipData(Icons.apartment_rounded, p.area!, _blue),
      if (p.city != null) _ChipData(Icons.location_city_rounded, p.city!, _green),
      if (p.postalCode != null)
        _ChipData(Icons.markunread_mailbox_outlined, p.postalCode!, _amber),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _crimson.withAlpha(22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.place_rounded, color: _crimson),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                p.address,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        if (chips.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final c in chips) ...[
                  _InfoChip(data: c),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _ChipData {
  final IconData icon;
  final String label;
  final Color color;
  const _ChipData(this.icon, this.label, this.color);
}

class _InfoChip extends StatelessWidget {
  final _ChipData data;
  const _InfoChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: data.color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 14, color: data.color),
          const SizedBox(width: 6),
          Text(
            data.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: data.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressSkeleton extends StatefulWidget {
  const _AddressSkeleton();

  @override
  State<_AddressSkeleton> createState() => _AddressSkeletonState();
}

class _AddressSkeletonState extends State<_AddressSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final color = Color.lerp(_border, _bg, _c.value)!;
        Widget bar(double w, double h) => Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  bar(double.infinity, 13),
                  const SizedBox(height: 8),
                  bar(180, 13),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      bar(70, 24),
                      const SizedBox(width: 8),
                      bar(80, 24),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}