import 'package:builders_mobile/dynamic-ui/product/product_detail_page.dart';
import 'package:flutter/material.dart';

const Color _kTint = Color(0xFFFDECEC);

String _u(String seed, {int size = 800}) =>
    'https://picsum.photos/seed/$seed/$size/$size';

class _Review {
  final String name;
  final int rating;
  final String date;
  final String title;
  final String text;
  int helpful;
  _Review(
    this.name,
    this.rating,
    this.date,
    this.title,
    this.text,
    this.helpful,
  );
}

class _Item {
  final String name;
  final int price;
  final int oldPrice;
  final double rating;
  final String image;
  const _Item(this.name, this.price, this.oldPrice, this.rating, this.image);
}

class ProductDetailPage3 extends StatefulWidget {
  const ProductDetailPage3({super.key});

  @override
  State<ProductDetailPage3> createState() => _ProductDetailPage3State();
}

class _ProductDetailPage3State extends State<ProductDetailPage3> {
  static const int _price = 2499;
  static const int _oldPrice = 3999;

  final ScrollController _scroll = ScrollController();
  bool _showTitle = false;

  int _color = 0;
  int _size = -1; // nothing selected until the user picks one
  bool _fav = false;
  final Set<int> _open = {0, 2};
  final Set<_Review> _helped = {};

  final List<String> _images = [
    _u('pd3-main'),
    _u('pd3-a'),
    _u('pd3-b'),
    _u('pd3-c'),
    _u('pd3-d'),
  ];

  final List<Map<String, dynamic>> _colors = const [
    {'name': 'Crimson', 'color': Color(0xFFD32F2F)},
    {'name': 'Rose', 'color': Color(0xFFF06292)},
    {'name': 'Slate', 'color': Color(0xFF607D8B)},
    {'name': 'Black', 'color': Color(0xFF212121)},
  ];

  final List<String> _sizes = const ['S', 'M', 'L', 'XL'];
  final List<int> _stock = const [12, 3, 8, 0];

  final Map<String, String> _specs = const {
    'Brand': 'RedPulse',
    'Model': 'RP-Aero X2',
    'Display': '1.69" AMOLED',
    'Battery': 'Up to 10 days',
    'Water resistance': 'IP68',
    'Connectivity': 'Bluetooth 5.3',
    'Weight': '38 g',
  };

  final Map<int, int> _bars = const {5: 62, 4: 24, 3: 8, 2: 4, 1: 2};

  final List<_Review> _reviews = [
    _Review(
      'Aarav Sharma',
      5,
      '12 Oct 2026',
      'Worth every rupee',
      'Amazing build quality and the battery really lasts over a week. Looks very premium.',
      18,
    ),
    _Review(
      'Priya Nair',
      4,
      '03 Oct 2026',
      'Very good',
      'Great value for money. Strap is comfortable. The app could be a bit smoother.',
      9,
    ),
    _Review(
      'Rahul Verma',
      5,
      '28 Sep 2026',
      'Bright display',
      'Fast delivery, neat packaging and the display is bright even outdoors.',
      12,
    ),
  ];

  final List<_Item> _look = [
    _Item('Leather Strap', 699, 1199, 4.3, _u('pd3-look1', size: 400)),
    _Item('Travel Case', 399, 699, 4.5, _u('pd3-look2', size: 400)),
    _Item('Fast Charger', 699, 1199, 4.2, _u('pd3-look3', size: 400)),
    _Item('Screen Guard', 299, 499, 4.0, _u('pd3-look4', size: 400)),
  ];

  final List<_Item> _viewed = [
    _Item('Aero Lite', 1799, 2999, 4.2, _u('pd3-v1', size: 400)),
    _Item('Pulse Band', 1299, 1999, 4.0, _u('pd3-v2', size: 400)),
    _Item('Aero Pro Max', 3999, 5499, 4.7, _u('pd3-v3', size: 400)),
    _Item('Kids Tracker', 999, 1499, 3.9, _u('pd3-v4', size: 400)),
  ];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final show = _scroll.offset > 320;
      if (show != _showTitle) setState(() => _showTitle = show);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  int get _discount => (((_oldPrice - _price) / _oldPrice) * 100).round();

  double get _avg {
    int total = 0, count = 0;
    _bars.forEach((s, p) {
      total += s * p;
      count += p;
    });
    return total / count;
  }

  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _bottomBar(),
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          _appBar(),
          SliverToBoxAdapter(child: _mosaic()),
          SliverToBoxAdapter(child: _info()),
          SliverToBoxAdapter(child: _variants()),
          SliverToBoxAdapter(child: _serviceStrip()),
          SliverToBoxAdapter(child: _accordions()),
          SliverToBoxAdapter(child: _rail('Complete the look', _look)),
          SliverToBoxAdapter(child: _grid('Customers also viewed', _viewed)),
          SliverToBoxAdapter(child: _reportRow()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  SliverAppBar _appBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: kText,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _showTitle ? 1 : 0,
        child: const Text(
          'Aero X2 Smart Watch',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: kText,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _fav ? Icons.favorite : Icons.favorite_border,
            color: _fav ? kRed : kText,
          ),
          onPressed: () => setState(() => _fav = !_fav),
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () => _snack('Link copied'),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined),
              onPressed: () => _snack('Bag opened'),
            ),
            Positioned(
              top: 10,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: kRed,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '2',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Photo mosaic: 1 large image + 2x2 small images, tap to zoom
  // -------------------------------------------------------------------------
  Widget _mosaic() {
    Widget tile(int i, {double ratio = 1}) {
      return GestureDetector(
        onTap: () => _openViewer(i),
        child: AspectRatio(aspectRatio: ratio, child: _net(_images[i])),
      );
    }

    return Column(
      children: [
        Stack(
          children: [
            tile(0, ratio: 0.95),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kRed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('$_discount% OFF', style: kBodyWhite),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.zoom_out_map_rounded, size: 14, color: kText),
                    SizedBox(width: 4),
                    Text('Tap to zoom', style: kBody),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Expanded(child: tile(1)),
            const SizedBox(width: 3),
            Expanded(child: tile(2)),
          ],
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Expanded(child: tile(3)),
            const SizedBox(width: 3),
            Expanded(child: tile(4)),
          ],
        ),
      ],
    );
  }

  void _openViewer(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ImageViewer(images: _images, start: index),
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _info() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'RedPulse',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kRed,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              const Icon(Icons.star, size: 16, color: kStar),
              const SizedBox(width: 3),
              Text(
                _avg.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kText,
                ),
              ),
              const SizedBox(width: 4),
              const Text('(1,284)', style: kBodySub),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Aero X2 Smart Watch with AMOLED Display',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '₹$_price',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
              const SizedBox(width: 10),
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text(
                  '₹$_oldPrice',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kSub,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '$_discount% off',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text('MRP inclusive of all taxes', style: kBodySub),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _variants() {
    final noteStock = _size >= 0 ? _stock[_size] : -1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Colour', style: kHeading),
              const SizedBox(width: 8),
              Text(_colors[_color]['name'] as String, style: kBodySub),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_colors.length, (i) {
              final selected = i == _color;
              return GestureDetector(
                onTap: () => setState(() => _color = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _kTint : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: selected ? kRed : kLine,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 8,
                        backgroundColor: _colors[i]['color'] as Color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _colors[i]['name'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? kRed : kText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Text('Select size', style: kHeading),
              const Spacer(),
              GestureDetector(
                onTap: () => _snack('Size guide opened'),
                child: const Row(
                  children: [
                    Icon(Icons.straighten_rounded, size: 16, color: kRed),
                    SizedBox(width: 4),
                    Text(
                      'Size guide',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: kRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_sizes.length, (i) {
              final out = _stock[i] == 0;
              final selected = i == _size;
              return Expanded(
                child: GestureDetector(
                  onTap: out ? null : () => setState(() => _size = i),
                  child: Container(
                    height: 44,
                    margin: EdgeInsets.only(
                      right: i == _sizes.length - 1 ? 0 : 8,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: out ? kSoft : (selected ? kRed : Colors.white),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selected ? kRed : kLine),
                    ),
                    child: Text(
                      _sizes[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: out ? kSub : (selected ? Colors.white : kText),
                        decoration: out
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          if (noteStock > 0 && noteStock <= 5)
            Text(
              'Hurry! Only $noteStock left in this size',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kRed,
              ),
            )
          else
            const Text(
              'Sizes with a line through them are out of stock',
              style: kBodySub,
            ),
        ],
      ),
    );
  }

  Widget _serviceStrip() {
    const items = [
      [Icons.local_shipping_outlined, 'Free\ndelivery'],
      [Icons.replay_rounded, '7-day\nreturns'],
      [Icons.verified_user_outlined, '1-year\nwarranty'],
      [Icons.payments_outlined, 'Cash on\ndelivery'],
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: kSoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: items
              .map(
                (e) => Expanded(
                  child: Column(
                    children: [
                      Icon(e[0] as IconData, size: 22, color: kRed),
                      const SizedBox(height: 6),
                      Text(
                        e[1] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: kText,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Collapsible sections
  // -------------------------------------------------------------------------
  Widget _accordions() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          _accordion(
            0,
            'Description',
            Icons.description_outlined,
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'The RedPulse Aero X2 pairs a vivid 1.69" AMOLED display with all-day health '
                'tracking. Monitor heart rate, SpO2, sleep and stress, and pick from over 100 '
                'sports modes. A lightweight aluminium body, IP68 resistance and up to 10 days '
                'of battery make it an easy everyday companion.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: kSub,
                  height: 1.55,
                ),
              ),
            ),
          ),
          _accordion(1, 'Specifications', Icons.tune_rounded, _specsBody()),
          _accordion(
            2,
            'Ratings & reviews (312)',
            Icons.star_border_rounded,
            _reviewsBody(),
          ),
          _accordion(
            3,
            'Shipping & returns',
            Icons.local_shipping_outlined,
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bullet('Free standard delivery in 2–3 working days'),
                  _Bullet('Easy 7-day returns if the product is unused'),
                  _Bullet('Refund to the original payment method in 3–5 days'),
                  _Bullet('1-year manufacturer warranty on the watch'),
                ],
              ),
            ),
          ),
          Container(height: 1, color: kLine),
        ],
      ),
    );
  }

  Widget _accordion(int index, String title, IconData icon, Widget body) {
    final open = _open.contains(index);
    return Column(
      children: [
        Container(height: 1, color: kLine),
        InkWell(
          onTap: () => setState(() {
            if (!_open.add(index)) _open.remove(index);
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: kText),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kText,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: kText,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: open
              ? SizedBox(width: double.infinity, child: body)
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _specsBody() {
    final entries = _specs.entries.toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: List.generate(entries.length, (i) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: i == entries.length - 1 ? Colors.transparent : kLine,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 4, child: Text(entries[i].key, style: kBodySub)),
                Expanded(flex: 5, child: Text(entries[i].value, style: kBody)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _reviewsBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                children: [
                  Text(
                    _avg.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  _stars(_avg.round(), 15),
                  const SizedBox(height: 4),
                  const Text('1,284 ratings', style: kBodySub),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((s) {
                    final pct = _bars[s]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Text('$s', style: kBody),
                          const SizedBox(width: 3),
                          const Icon(Icons.star, size: 12, color: kStar),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct / 100,
                                minHeight: 6,
                                color: kRed,
                                backgroundColor: kSoft,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 34,
                            child: Text(
                              '$pct%',
                              textAlign: TextAlign.right,
                              style: kBodySub,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kRed),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _writeReviewSheet,
              child: const Text(
                'Write a review',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kRed,
                ),
              ),
            ),
          ),
          ..._reviews.map((r) {
            final helped = _helped.contains(r);
            return Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.only(bottom: 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: kLine)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _stars(r.rating, 13),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          r.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    r.text,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: kText,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text('${r.name} • ${r.date}', style: kBodySub),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => setState(() {
                          if (helped) {
                            _helped.remove(r);
                            r.helpful--;
                          } else {
                            _helped.add(r);
                            r.helpful++;
                          }
                        }),
                        child: Row(
                          children: [
                            Icon(
                              helped ? Icons.thumb_up : Icons.thumb_up_outlined,
                              size: 15,
                              color: helped ? kRed : kSub,
                            ),
                            const SizedBox(width: 5),
                            Text('Helpful (${r.helpful})', style: kBodySub),
                          ],
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _reportSheet('review by ${r.name}'),
                        child: const Row(
                          children: [
                            Icon(Icons.flag_outlined, size: 15, color: kSub),
                            SizedBox(width: 4),
                            Text('Report', style: kBodySub),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Product rails
  // -------------------------------------------------------------------------
  Widget _rail(String title, List<_Item> items) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(title, style: kHeading),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 214,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final p = items[i];
                return SizedBox(
                  width: 138,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _net(p.image),
                              ),
                            ),
                            Positioned(
                              right: 6,
                              bottom: 6,
                              child: GestureDetector(
                                onTap: () => _snack('${p.name} added to bag'),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: kRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: kBody,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '₹${p.price}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: kText,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '₹${p.oldPrice}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: kSub,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(String title, List<_Item> items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: kHeading),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              mainAxisExtent: 236,
            ),
            itemBuilder: (_, i) {
              final p = items[i];
              final off = (((p.oldPrice - p.price) / p.oldPrice) * 100).round();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _net(p.image),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: kRed,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              '$off% OFF',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kBody,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '₹${p.price}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '₹${p.oldPrice}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: kSub,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, size: 12, color: kStar),
                      const SizedBox(width: 2),
                      Text('${p.rating}', style: kBodySub),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _reportRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: GestureDetector(
        onTap: () => _reportSheet('this product'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: kLine),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.outlined_flag_rounded, color: kSub),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Found something wrong with this listing?',
                  style: kBody,
                ),
              ),
              Text(
                'Report',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _bottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kLine)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _fav = !_fav),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: kLine),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _fav ? Icons.favorite : Icons.favorite_border,
                  color: _fav ? kRed : kText,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_size < 0) {
                      _snack('Please select a size');
                      return;
                    }
                    _snack('Added to bag');
                  },
                  child: const Text(
                    'Add to bag  •  ₹$_price',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  void _reportSheet(String target) {
    const reasons = [
      'Fake or counterfeit',
      'Wrong price or misleading offer',
      'Inappropriate content',
      'Wrong description',
      'Other',
    ];
    int selected = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            18,
            16,
            MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Report $target', style: kHeading),
                const SizedBox(height: 8),
                ...List.generate(reasons.length, (i) {
                  return InkWell(
                    onTap: () => setSheet(() => selected = i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(
                        children: [
                          Icon(
                            selected == i
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            size: 20,
                            color: selected == i ? kRed : kSub,
                          ),
                          const SizedBox(width: 10),
                          Text(reasons[i], style: kBody),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 3,
                  style: kBody,
                  cursorColor: kRed,
                  decoration: InputDecoration(
                    hintText: 'Add more details (optional)',
                    hintStyle: kBodySub,
                    filled: true,
                    fillColor: kSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kRed,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _snack('Report submitted. Thank you!');
                    },
                    child: const Text('Submit report', style: kBodyWhite),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _writeReviewSheet() {
    int stars = 5;
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            18,
            16,
            MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Write a review', style: kHeading),
              const SizedBox(height: 10),
              Row(
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () => setSheet(() => stars = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        i < stars ? Icons.star : Icons.star_border,
                        color: kStar,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                style: kBody,
                cursorColor: kRed,
                decoration: InputDecoration(
                  hintText: 'Share your experience with this product',
                  hintStyle: kBodySub,
                  filled: true,
                  fillColor: kSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kRed,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    setState(() {
                      _reviews.insert(
                        0,
                        _Review('You', stars, 'Just now', 'My review', text, 0),
                      );
                    });
                    Navigator.pop(ctx);
                    _snack('Review posted');
                  },
                  child: const Text('Post review', style: kBodyWhite),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _stars(int count, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < count ? Icons.star : Icons.star_border,
          size: size,
          color: kStar,
        ),
      ),
    );
  }

  Widget _net(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: kSoft,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: kRed),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: kSoft,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, color: kSub),
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: kText,
          behavior: SnackBarBehavior.floating,
          content: Text(msg, style: kBodyWhite),
        ),
      );
  }
}

// ---------------------------------------------------------------------------
class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: CircleAvatar(radius: 3, backgroundColor: kRed),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: kBody)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Full screen zoomable image viewer
// ---------------------------------------------------------------------------
class _ImageViewer extends StatefulWidget {
  final List<String> images;
  final int start;
  const _ImageViewer({required this.images, required this.start});

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  late final PageController _controller = PageController(
    initialPage: widget.start,
  );
  late int _index = widget.start;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  widget.images[i],
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white54,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_index + 1} / ${widget.images.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == _index ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _index ? kRed : Colors.white54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
