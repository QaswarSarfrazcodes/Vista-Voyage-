import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../models/destination_model.dart';
import '../theme/app_colors.dart';

/// Pushed-route wrapper — reads the destination list from route arguments.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final destinations = ModalRoute.of(context)!.settings.arguments as List<DestinationModel>;
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: MapScreenBody(destinations: destinations),
    );
  }
}

/// Reusable map body — used both by the pushed [MapScreen] route and the
/// persistent Map tab inside [MainShell] (via MapScreenTab).
class MapScreenBody extends StatefulWidget {
  final List<DestinationModel> destinations;
  final bool showBackButton;

  const MapScreenBody({super.key, required this.destinations, this.showBackButton = true});

  @override
  State<MapScreenBody> createState() => _MapScreenBodyState();
}

class _MapScreenBodyState extends State<MapScreenBody> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  DestinationModel? _selectedDestination;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  double _currentZoom = 5.0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _zoomBy(double delta) {
    final newZoom = (_currentZoom + delta).clamp(2.0, 18.0);
    setState(() => _currentZoom = newZoom);
    _mapController.move(_mapController.camera.center, newZoom);
  }

  @override
  Widget build(BuildContext context) {
    final destinations = widget.destinations;
    final withCoords = destinations
        .where((d) => d.latitude != null && d.longitude != null)
        .toList();

    final center = withCoords.isNotEmpty
        ? LatLng(withCoords.first.latitude!, withCoords.first.longitude!)
        : const LatLng(30.3753, 69.3451); // Default Pakistan Center

    return Stack(
        children: [
          // 1. Core Map Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: _currentZoom,
              onTap: (_, __) {
                setState(() {
                  _selectedDestination = null;
                });
              },
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  _currentZoom = position.zoom;
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.tripline.app',
              ),
              MarkerLayer(
                markers: withCoords.map((d) {
                  final isSelected = _selectedDestination?.id == d.id;
                  return Marker(
                    point: LatLng(d.latitude!, d.longitude!),
                    width: isSelected ? 84 : 56,
                    height: isSelected ? 96 : 64,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDestination = d;
                        });
                        _mapController.move(LatLng(d.latitude!, d.longitude!), 6.5);
                        _currentZoom = 6.5;
                      },
                      child: _PremiumMarker(
                        destination: d,
                        isSelected: isSelected,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. Cinematic gradient scrims for legibility, non-interactive
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.18],
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3],
                ),
              ),
            ),
          ),

          // 3. Premium Frosted Glass Floating App Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (widget.showBackButton) ...[
                        _CircleIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 14),
                      ],
                      const Expanded(
                        child: Text(
                          'Explore Destinations',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            letterSpacing: 0.1,
                            color: AppColors.primaryDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _CircleIconButton(
                        icon: Icons.my_location_rounded,
                        onTap: () {
                          if (withCoords.isNotEmpty) {
                            setState(() => _currentZoom = 5.0);
                            _mapController.move(center, 5.0);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Floating premium zoom controls
          // Solid container instead of BackdropFilter — a live blur here on
          // top of an already-blurred app bar was pure per-frame GPU cost
          // for a corner control the user glances at, not reads through.
          Positioned(
            right: 16,
            bottom: _selectedDestination != null ? 172 : 32,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CircleIconButton(icon: Icons.add_rounded, onTap: () => _zoomBy(1)),
                  Divider(height: 1, color: AppColors.primaryDark.withValues(alpha: 0.08)),
                  _CircleIconButton(icon: Icons.remove_rounded, onTap: () => _zoomBy(-1)),
                ],
              ),
            ),
          ),

          // 5. Premium Bottom Destination Preview Card
          AnimatedSlide(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            offset: _selectedDestination != null ? Offset.zero : const Offset(0, 1.4),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 260),
              opacity: _selectedDestination != null ? 1.0 : 0.0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: _selectedDestination == null
                      ? const SizedBox(height: 132)
                      : _DestinationPreviewCard(
                    destination: _selectedDestination!,
                    onViewDetails: () {
                      Navigator.pushNamed(
                        context,
                        '/detail',
                        arguments: _selectedDestination,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
    );
  }
}

/// Frosted, circular icon button used across the floating controls.
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.primaryDark.withValues(alpha: 0.85),
              ],
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// Custom teardrop map pin with a glowing halo when selected.
class _PremiumMarker extends StatefulWidget {
  final DestinationModel destination;
  final bool isSelected;

  const _PremiumMarker({required this.destination, required this.isSelected});

  @override
  State<_PremiumMarker> createState() => _PremiumMarkerState();
}

class _PremiumMarkerState extends State<_PremiumMarker> with SingleTickerProviderStateMixin {
  // Explicit controller instead of TweenAnimationBuilder — plays exactly
  // once per selection event via didUpdateWidget below, rather than relying
  // on implicit widget-reconciliation timing to decide when it (re)plays.
  late final AnimationController _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    if (widget.isSelected) _pulseCtrl.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant _PremiumMarker old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) _pulseCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.destination;
    final isSelected = widget.isSelected;
    final double size = isSelected ? 62 : 46;

    return AnimatedScale(
      duration: const Duration(milliseconds: 280),
      curve: Curves.elasticOut,
      scale: isSelected ? 1.0 : 0.92,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected)
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (context, child) {
                    final value = _pulseCtrl.value;
                    return Opacity(
                      opacity: (1.0 - value) * 0.5 + 0.1,
                      child: Container(
                        width: size + 26 * value,
                        height: size + 26 * value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.coral.withValues(alpha: 0.35),
                        ),
                      ),
                    );
                  },
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: size,
                height: size,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSelected
                        ? [AppColors.coral, AppColors.coral.withValues(alpha: 0.7)]
                        : [Colors.white, Colors.white.withValues(alpha: 0.9)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isSelected ? AppColors.coral : Colors.black).withValues(alpha: 0.35),
                      blurRadius: isSelected ? 14 : 8,
                      spreadRadius: isSelected ? 1 : 0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    imageUrl: destination.imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 140,
                    fadeInDuration: const Duration(milliseconds: 120),
                    placeholder: (context, url) => Container(color: AppColors.primaryDark),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.primaryDark,
                      child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          CustomPaint(
            size: const Size(14, 8),
            painter: _PinTailPainter(
              color: isSelected ? AppColors.coral : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.3), 2, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter oldDelegate) => oldDelegate.color != color;
}

/// Glassmorphic quick-preview card shown when a marker is tapped.
class _DestinationPreviewCard extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback onViewDetails;

  const _DestinationPreviewCard({
    required this.destination,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    // Solid container instead of BackdropFilter — this card animates in on
    // every marker tap, so a live blur here was a per-frame GPU cost paid
    // on top of the map's own tile rendering every single time it appeared.
    return Container(
          height: 132,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Hero(
                tag: 'map-img-${destination.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      CachedNetworkImage(
                        imageUrl: destination.imageUrl,
                        width: 104,
                        height: 108,
                        fit: BoxFit.cover,
                        memCacheWidth: 220,
                        fadeInDuration: const Duration(milliseconds: 120),
                        placeholder: (context, url) => Container(color: AppColors.primaryDark.withValues(alpha: 0.1)),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.25),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      destination.name,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.primaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            destination.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: onViewDetails,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.coral, AppColors.coral.withValues(alpha: 0.8)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.coral.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
  }
}