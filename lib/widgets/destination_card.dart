// lib/widgets/destination_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/destination_model.dart';
import '../theme/app_colors.dart';

class DestinationCard extends StatefulWidget {
  final DestinationModel destination;
  final VoidCallback     onTap;

  const DestinationCard({super.key, required this.destination, required this.onTap});

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  static const _amber    = AppColors.gold;
  static const _blue     = AppColors.primary;
  static const _blueDark = AppColors.primaryDark;
  static const _green    = Color(0xFF4CAF50);
  static const _gray     = AppColors.gray;

  bool _pressed = false;

  DestinationModel get destination => widget.destination;
  VoidCallback get onTap => widget.onTap;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        scale: _pressed ? 0.98 : 1.0,
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _pressed ? 0.06 : 0.12),
                  blurRadius: _pressed ? 12 : 20,
                  offset: Offset(0, _pressed ? 4 : 8),
                ),
              ],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Image ─────────────────────────────────────────────────────
              ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Stack(children: [
                    _buildImage(),

                    // Bottom gradient scrim for a seamless, cinematic blend
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 70,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.32),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Rating badge
                    Positioned(top: 12, right: 12,
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.star_rounded, color: _amber, size: 15),
                              const SizedBox(width: 4),
                              Text(destination.rating.toStringAsFixed(1),
                                  style: const TextStyle(color: Colors.white,
                                      fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
                            ]))),

                    // Country badge
                    Positioned(top: 12, left: 12,
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [_blue, _blueDark]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _blue.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.location_on_rounded, color: Colors.white, size: 13),
                              const SizedBox(width: 4),
                              Text(destination.country,
                                  style: const TextStyle(color: Colors.white,
                                      fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
                            ]))),

                    // Name overlay on image bottom-left, sitting on the scrim
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 10,
                      child: Text(
                        destination.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Nunito',
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
                        ),
                      ),
                    ),
                  ])),

              // ── Body ────────────────────────────────────────────────────────
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Description
                    Text(destination.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: _gray,
                            fontFamily: 'Nunito', height: 1.45)),
                    const SizedBox(height: 12),

                    // Tags
                    if (destination.tags.isNotEmpty)
                      Wrap(spacing: 6, runSpacing: 6,
                          children: destination.tags.take(3).map((tag) =>
                              Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardTint,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.divider),
                                  ),
                                  child: Text(tag, style: const TextStyle(
                                      fontSize: 11, fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w700, color: _blueDark)))).toList()),
                    if (destination.tags.isNotEmpty) const SizedBox(height: 12),

                    // Best time + budget row
                    if (destination.bestTime.isNotEmpty || destination.avgBudget.isNotEmpty)
                      Row(children: [
                        if (destination.bestTime.isNotEmpty) ...[
                          _InfoChip(
                            icon: Icons.wb_sunny_rounded,
                            color: _amber,
                            label: destination.bestTime,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (destination.avgBudget.isNotEmpty)
                          _InfoChip(
                            icon: Icons.account_balance_wallet_rounded,
                            color: _green,
                            label: destination.avgBudget,
                          ),
                      ]),
                    const SizedBox(height: 16),

                    // View Details button
                    SizedBox(width: double.infinity, height: 46,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [_blue, _blueDark]),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _blue.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: onTap,
                            child: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.explore_outlined, size: 18, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('View Details', style: TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold,
                                      fontFamily: 'Nunito', color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ])),
            ])),
      ),
    );
  }

  Widget _buildImage() {
    if (destination.isAsset) {
      return Image.asset(destination.imageUrl,
          height: 210, width: double.infinity, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder());
    }
    return CachedNetworkImage(
        imageUrl: destination.imageUrl,
        height: 210, width: double.infinity, fit: BoxFit.cover,
        memCacheWidth: 480,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (_, __) => Container(height: 210, color: AppColors.cardTint,
            child: const Center(child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2))),
        errorWidget: (_, __, ___) => _placeholder());
  }

  Widget _placeholder() => Container(
      height: 210, color: AppColors.cardTint,
      child: const Center(child: Icon(Icons.image_outlined,
          size: 48, color: AppColors.primary)));
}

/// Small pill used for the best-time / budget metadata row.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _InfoChip({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.charcoal, fontFamily: 'Nunito', fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}