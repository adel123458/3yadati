import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import 'app_card.dart';

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  const SkeletonBox({super.key, this.width, this.height = 14, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

class _ShimmerWrap extends StatelessWidget {
  final Widget child;
  const _ShimmerWrap({required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE9EEF3),
      highlightColor: const Color(0xFFF7FAFC),
      period: const Duration(milliseconds: 1100),
      child: child,
    );
  }
}

class StatGridSkeleton extends StatelessWidget {
  final int count;
  const StatGridSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return _ShimmerWrap(
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        childAspectRatio: 1.45,
        children: List.generate(
          count,
          (_) => AppCard(
            elevated: false,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 44, height: 44, borderRadius: BorderRadius.all(Radius.circular(14))),
                SizedBox(height: 14),
                SkeletonBox(width: 60, height: 22),
                SizedBox(height: 6),
                SkeletonBox(width: 90),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  final int rows;
  final double tileHeight;
  const ListSkeleton({super.key, this.rows = 5, this.tileHeight = 76});

  @override
  Widget build(BuildContext context) {
    return _ShimmerWrap(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rows,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => Container(
          height: tileHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(radius: 22, backgroundColor: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SkeletonBox(width: 140, height: 14),
                    SizedBox(height: 8),
                    SkeletonBox(width: 90, height: 11),
                  ],
                ),
              ),
              const SkeletonBox(width: 56, height: 22, borderRadius: BorderRadius.all(Radius.circular(10))),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartSkeleton extends StatelessWidget {
  final double height;
  const ChartSkeleton({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return _ShimmerWrap(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

/// Generic helper to wrap any widget with shimmer.
class Shimmered extends StatelessWidget {
  final Widget child;
  const Shimmered({super.key, required this.child});

  @override
  Widget build(BuildContext context) => _ShimmerWrap(child: child);
}

class HeroSkeleton extends StatelessWidget {
  const HeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: _ShimmerWrap(
        child: Row(
          children: [
            const CircleAvatar(radius: 28, backgroundColor: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 120, height: 14),
                  SizedBox(height: 8),
                  SkeletonBox(width: 80, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
