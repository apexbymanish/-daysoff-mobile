import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

enum _Category { all, beach, forest, mountains, culture }

class _Destination {
  const _Destination({
    required this.image,
    required this.title,
    this.subtitle,
    required this.tag,
    required this.tagBg,
    required this.tagFg,
    required this.category,
  });

  final String image;
  final String title;
  final String? subtitle;
  final String tag;
  final Color tagBg;
  final Color tagFg;
  final _Category category;
}

const _destinations = <_Destination>[
  _Destination(
    image: 'assets/scenery/cinque_terre.jpg',
    title: 'Cinque Terre, Italy',
    subtitle: 'Coastal charm with pastel villas and turquoise waters.',
    tag: 'Chuseok Break · 5 days',
    tagBg: DaysoffColors.oliveFixedDim,
    tagFg: DaysoffColors.olive,
    category: _Category.beach,
  ),
  _Destination(
    image: 'assets/scenery/kyoto.jpg',
    title: 'Arashiyama, Kyoto',
    tag: 'Weekend Trip · 3 days',
    tagBg: DaysoffColors.indigoContainer,
    tagFg: DaysoffColors.indigo,
    category: _Category.forest,
  ),
  _Destination(
    image: 'assets/scenery/marrakech.jpg',
    title: 'Marrakech, Morocco',
    tag: 'Annual Leave · 7 days',
    tagBg: DaysoffColors.brandTeal,
    tagFg: Colors.white,
    category: _Category.culture,
  ),
  _Destination(
    image: 'assets/scenery/alps.jpg',
    title: 'Grindelwald, Swiss Alps',
    subtitle: 'Best in Dec–Feb.',
    tag: 'Recommended for Winter',
    tagBg: Colors.white,
    tagFg: DaysoffColors.brandTeal,
    category: _Category.mountains,
  ),
];

// ---------------------------------------------------------------------------
// Trip Collections data
// ---------------------------------------------------------------------------

class _Collection {
  const _Collection({
    required this.icon,
    required this.title,
    required this.blurb,
  });

  final IconData icon;
  final String title;
  final String blurb;
}

const _collections = <_Collection>[
  _Collection(
    icon: Icons.local_florist,
    title: 'Nature Retreats',
    blurb: 'Forests, mountains, and wild coastlines to recharge.',
  ),
  _Collection(
    icon: Icons.history_edu,
    title: 'Cultural Journeys',
    blurb: 'Temples, markets, and traditions from around the world.',
  ),
  _Collection(
    icon: Icons.restaurant,
    title: 'Culinary Trips',
    blurb: 'Taste your way through cities and countryside.',
  ),
];

// ---------------------------------------------------------------------------
// Chip descriptor
// ---------------------------------------------------------------------------

class _ChipData {
  const _ChipData({required this.label, required this.category, this.icon});

  final String label;
  final _Category category;
  final IconData? icon;
}

const _chips = <_ChipData>[
  _ChipData(label: 'ALL IDEAS', category: _Category.all),
  _ChipData(
      label: 'BEACH',
      category: _Category.beach,
      icon: Icons.beach_access),
  _ChipData(
      label: 'FOREST',
      category: _Category.forest,
      icon: Icons.forest),
  _ChipData(
      label: 'MOUNTAINS',
      category: _Category.mountains,
      icon: Icons.terrain),
  _ChipData(
      label: 'CULTURE',
      category: _Category.culture,
      icon: Icons.temple_buddhist),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class DestinationsScreen extends StatefulWidget {
  const DestinationsScreen({super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  _Category _selectedCategory = _Category.all;
  String _query = '';
  final Set<int> _bookmarked = {};

  List<_Destination> get _filtered {
    return _destinations.where((d) {
      final matchesCategory =
          _selectedCategory == _Category.all ||
          d.category == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          d.title.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DaysoffColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: DaysoffColors.surfaceContainerLow,
        elevation: 0,
        leading: const BackButton(color: DaysoffColors.brandTeal),
        title: const Text(
          'Find Your Escape',
          style: TextStyle(
            color: DaysoffColors.brandTeal,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // ── Header ──────────────────────────────────────────────────────
          const Text(
            'Find Your Escape',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: DaysoffColors.brandTeal,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Curated trips for your next available window.',
            style: TextStyle(
              fontSize: 14,
              color: DaysoffColors.neutral700,
            ),
          ),
          const SizedBox(height: 20),

          // ── Search ──────────────────────────────────────────────────────
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search destinations…',
              prefixIcon: const Icon(
                Icons.search,
                color: DaysoffColors.neutral500,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: DaysoffColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: DaysoffColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: DaysoffColors.brandTeal, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          // ── Category chips ───────────────────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _chips.length,
              separatorBuilder: (context, i) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final chip = _chips[i];
                final selected = chip.category == _selectedCategory;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = chip.category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 0),
                    decoration: BoxDecoration(
                      color: selected
                          ? DaysoffColors.brandTeal
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? DaysoffColors.brandTeal
                            : DaysoffColors.outlineVariant,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (chip.icon != null) ...[
                          Icon(
                            chip.icon,
                            size: 14,
                            color: selected
                                ? Colors.white
                                : DaysoffColors.neutral700,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          chip.label,
                          style: labelCaps(
                            fontSize: 11,
                            color: selected
                                ? Colors.white
                                : DaysoffColors.neutral700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // ── Destination cards ────────────────────────────────────────────
          ..._filtered.asMap().entries.map((entry) {
            final idx = _destinations.indexOf(entry.value);
            final dest = entry.value;
            final isBookmarked = _bookmarked.contains(idx);
            final isAlps = dest.category == _Category.mountains;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _DestinationCard(
                destination: dest,
                isBookmarked: isBookmarked,
                isAlps: isAlps,
                onBookmark: () => setState(() {
                  if (isBookmarked) {
                    _bookmarked.remove(idx);
                  } else {
                    _bookmarked.add(idx);
                  }
                }),
              ),
            );
          }),

          const SizedBox(height: 8),

          // ── Trip Collections ─────────────────────────────────────────────
          const Text(
            'Trip Collections',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: DaysoffColors.brandTeal,
            ),
          ),
          const SizedBox(height: 12),
          ..._collections.map(
            (col) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CollectionCard(collection: col),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Destination card
// ---------------------------------------------------------------------------

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({
    required this.destination,
    required this.isBookmarked,
    required this.isAlps,
    required this.onBookmark,
  });

  final _Destination destination;
  final bool isBookmarked;
  final bool isAlps;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    final height = isAlps ? 280.0 : 220.0;

    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: DaysoffColors.neutral300,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Image.asset(
            destination.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: DaysoffColors.neutral300,
              child: const Center(
                child: Icon(Icons.landscape, size: 48, color: Colors.white54),
              ),
            ),
          ),
          // Bottom gradient scrim
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.0, 0.65],
                colors: [
                  Color(0xCC000000),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Top-right bookmark button
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: onBookmark,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          // Bottom overlay: tag + title + subtitle
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tag pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: destination.tagBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      destination.tag,
                      style: labelCaps(
                        fontSize: 10,
                        color: destination.tagFg,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Title
                  Text(
                    destination.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  if (destination.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      destination.subtitle!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Collection card
// ---------------------------------------------------------------------------

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection});

  final _Collection collection;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: DaysoffColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: DaysoffColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              collection.icon,
              color: DaysoffColors.brandTeal,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  collection.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: DaysoffColors.brandTeal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  collection.blurb,
                  style: const TextStyle(
                    fontSize: 13,
                    color: DaysoffColors.neutral700,
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
