import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Theme: clean white UI, red used only as the accent (buttons, price, badges)
// Body text: size 12, medium weight
// ---------------------------------------------------------------------------
const Color kRed = Color(0xFFD32F2F);
const Color kText = Color(0xFF1F1F1F);
const Color kSub = Color(0xFF757575);
const Color kLine = Color(0xFFEEEEEE);
const Color kSoft = Color(0xFFF6F6F6);
const Color kStar = Color(0xFFFFB300);

const TextStyle kBody = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: kText,
);
const TextStyle kBodySub = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: kSub,
);
const TextStyle kBodyWhite = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: Colors.white,
);
const TextStyle kHeading = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: kText,
);

String _img(String seed, {int size = 800}) =>
    'https://picsum.photos/seed/$seed/$size/$size';

class _Review {
  final String name;
  final int rating;
  final String date;
  final String text;
  int helpful;
  _Review(this.name, this.rating, this.date, this.text, this.helpful);
}

class _Related {
  final String name;
  final int price;
  final int oldPrice;
  final double rating;
  final String image;
  const _Related(this.name, this.price, this.oldPrice, this.rating, this.image);
}

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final PageController _pageController = PageController();
  int _currentImage = 0;
  int _selectedColor = 0;
  int _selectedSize = 1;
  int _qty = 1;
  bool _isFav = false;
  bool _descExpanded = false;
  int _reviewFilter = 0;
  final Set<_Review> _helped = {};

  static const int _price = 2499;
  static const int _oldPrice = 3999;

  final List<String> _images = [
    _img('aero-front'),
    _img('aero-side'),
    _img('aero-back'),
    _img('aero-wrist'),
  ];

  final List<Map<String, dynamic>> _colors = const [
    {'name': 'Crimson', 'color': Color(0xFFD32F2F)},
    {'name': 'Rose', 'color': Color(0xFFF06292)},
    {'name': 'Slate', 'color': Color(0xFF607D8B)},
    {'name': 'Black', 'color': Color(0xFF212121)},
  ];

  final List<String> _sizes = const ['S', 'M', 'L', 'XL'];

  final Map<String, String> _specs = const {
    'Brand': 'RedPulse',
    'Model': 'RP-Aero X2',
    'Display': '1.69" AMOLED',
    'Battery': 'Up to 10 days',
    'Water resistance': 'IP68',
    'Connectivity': 'Bluetooth 5.3',
    'Warranty': '1 year',
  };

  final Map<int, int> _ratingBars = const {5: 62, 4: 24, 3: 8, 2: 4, 1: 2};

  final List<_Review> _reviews = [
    _Review(
      'Aarav Sharma',
      5,
      '12 Oct 2026',
      'Amazing build quality and the battery really lasts over a week. Looks very premium.',
      18,
    ),
    _Review(
      'Priya Nair',
      4,
      '03 Oct 2026',
      'Great value for money. Strap is comfortable. The app could be a bit smoother.',
      9,
    ),
    _Review(
      'Rahul Verma',
      5,
      '28 Sep 2026',
      'Fast delivery, neat packaging and the display is bright even outdoors.',
      12,
    ),
    _Review(
      'Sneha Iyer',
      3,
      '19 Sep 2026',
      'Good watch overall but the charging cable is a little short.',
      4,
    ),
  ];

  final List<_Related> _similar = [
    _Related('Aero Lite', 1799, 2999, 4.2, _img('similar1', size: 400)),
    _Related('Pulse Band', 1299, 1999, 4.0, _img('similar2', size: 400)),
    _Related('Aero Pro Max', 3999, 5499, 4.7, _img('similar3', size: 400)),
    _Related('Kids Tracker', 999, 1499, 3.9, _img('similar4', size: 400)),
  ];

  final List<_Related> _together = [
    _Related('Wireless Buds', 1499, 2499, 4.4, _img('together1', size: 400)),
    _Related('Power Bank 10K', 999, 1599, 4.3, _img('together2', size: 400)),
    _Related('Strap Set', 499, 899, 4.1, _img('together3', size: 400)),
    _Related('Travel Case', 399, 699, 4.5, _img('together4', size: 400)),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double get _avgRating {
    int total = 0, count = 0;
    _ratingBars.forEach((s, p) {
      total += s * p;
      count += p;
    });
    return total / count;
  }

  int get _discount => (((_oldPrice - _price) / _oldPrice) * 100).round();

  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: kText,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Product details', style: kHeading),
        actions: [
          IconButton(
            icon: Icon(
              _isFav ? Icons.favorite : Icons.favorite_border,
              color: _isFav ? kRed : kText,
            ),
            onPressed: () => setState(() => _isFav = !_isFav),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _snack('Link copied'),
          ),
        ],
      ),
      bottomNavigationBar: _bottomBar(),
      body: ListView(
        children: [
          _gallery(),
          _titleSection(),
          _divider(),
          _optionsSection(),
          _divider(),
          _perks(),
          _divider(),
          _descriptionSection(),
          _divider(),
          _specsSection(),
          _divider(),
          _ratingSection(),
          _reviewsSection(),
          _divider(),
          _reportSection(),
          _divider(),
          _rail('Similar products', _similar),
          _divider(),
          _grid('Frequently bought together', _together),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _gallery() {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.1,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _images.length,
                onPageChanged: (i) => setState(() => _currentImage = i),
                itemBuilder: (_, i) => _net(_images[i]),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kRed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('$_discount% OFF', style: kBodyWhite),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_currentImage + 1}/${_images.length}',
                    style: kBodyWhite,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final selected = i == _currentImage;
              return GestureDetector(
                onTap: () => _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                ),
                child: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected ? kRed : kLine,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _net(_images[i]),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _titleSection() {
    return _pad(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RedPulse', style: kBodySub),
          const SizedBox(height: 2),
          const Text(
            'Aero X2 Smart Watch with AMOLED Display',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_avgRating.toStringAsFixed(1), style: kBodyWhite),
                    const SizedBox(width: 3),
                    const Icon(Icons.star, size: 12, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text('1,284 ratings • 312 reviews', style: kBodySub),
            ],
          ),
          const SizedBox(height: 12),
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
              const SizedBox(width: 8),
              const Text(
                '₹$_oldPrice',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: kSub,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$_discount% off',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text('Inclusive of all taxes', style: kBodySub),
        ],
      ),
    );
  }

  Widget _optionsSection() {
    return _pad(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Colour: ${_colors[_selectedColor]['name']}', style: kHeading),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_colors.length, (i) {
              final selected = i == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? kRed : kLine,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 13,
                    backgroundColor: _colors[i]['color'] as Color,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          const Text('Strap size', style: kHeading),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_sizes.length, (i) {
              final selected = i == _selectedSize;
              return GestureDetector(
                onTap: () => setState(() => _selectedSize = i),
                child: Container(
                  width: 46,
                  height: 36,
                  margin: const EdgeInsets.only(right: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? kRed : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: selected ? kRed : kLine),
                  ),
                  child: Text(_sizes[i], style: selected ? kBodyWhite : kBody),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Text('Quantity', style: kHeading),
              const Spacer(),
              _qtyBtn(Icons.remove, () {
                if (_qty > 1) setState(() => _qty--);
              }),
              SizedBox(
                width: 40,
                child: Text(
                  '$_qty',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
              ),
              _qtyBtn(Icons.add, () {
                if (_qty < 10) setState(() => _qty++);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: kLine),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: kText),
      ),
    );
  }

  Widget _perks() {
    const perks = [
      [Icons.local_shipping_outlined, 'Free delivery'],
      [Icons.replay_rounded, '7-day returns'],
      [Icons.verified_user_outlined, '1-year warranty'],
    ];
    return _pad(
      Row(
        children: perks
            .map(
              (p) => Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: kSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(p[0] as IconData, color: kRed, size: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p[1] as String,
                      style: kBody,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _descriptionSection() {
    const text =
        'The RedPulse Aero X2 combines a vivid 1.69" AMOLED display with all-day health '
        'tracking. Monitor heart rate, SpO2, sleep and stress around the clock and choose '
        'from over 100 sports modes. A lightweight aluminium body, IP68 water resistance '
        'and a battery that lasts up to 10 days make it a perfect everyday companion.';
    return _pad(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('About this product', style: kHeading),
          const SizedBox(height: 8),
          Text(
            text,
            maxLines: _descExpanded ? null : 3,
            overflow: _descExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: kSub,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _descExpanded = !_descExpanded),
            child: Text(
              _descExpanded ? 'Show less' : 'Read more',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _specsSection() {
    return _pad(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Specifications', style: kHeading),
          const SizedBox(height: 8),
          ..._specs.entries.map(
            (e) => Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: kLine)),
              ),
              child: Row(
                children: [
                  Expanded(flex: 4, child: Text(e.key, style: kBodySub)),
                  Expanded(flex: 5, child: Text(e.value, style: kBody)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingSection() {
    return _pad(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Ratings & reviews', style: kHeading)),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kRed,
                  side: const BorderSide(color: kRed),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _writeReviewSheet,
                child: const Text(
                  'Write review',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    _avgRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  _stars(_avgRating.round(), 15),
                  const SizedBox(height: 4),
                  const Text('1,284 ratings', style: kBodySub),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((s) {
                    final pct = _ratingBars[s]!;
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
                              style: kBodySub,
                              textAlign: TextAlign.right,
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
        ],
      ),
    );
  }

  Widget _reviewsSection() {
    final visible = _reviewFilter == 0
        ? _reviews
        : _reviews.where((r) => r.rating == _reviewFilter).toList();
    return _pad(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [0, 5, 4, 3, 2, 1].map((f) {
                final selected = _reviewFilter == f;
                return GestureDetector(
                  onTap: () => setState(() => _reviewFilter = f),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? kRed : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? kRed : kLine),
                    ),
                    child: Text(
                      f == 0 ? 'All' : '$f ★',
                      style: selected ? kBodyWhite : kBody,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No reviews for this rating yet', style: kBodySub),
              ),
            ),
          ...visible.map((r) {
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
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: kSoft,
                        child: Text(
                          r.name[0],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: kText,
                              ),
                            ),
                            Row(
                              children: [
                                _stars(r.rating, 12),
                                const SizedBox(width: 6),
                                Text(r.date, style: kBodySub),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    r.text,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: kText,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
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

  Widget _reportSection() {
    return _pad(
      Row(
        children: [
          const Icon(Icons.outlined_flag_rounded, color: kSub),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Found something wrong with this listing?',
              style: kBody,
            ),
          ),
          TextButton(
            onPressed: () => _reportSheet('this product'),
            child: const Text(
              'Report product',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _rail(String title, List<_Related> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: Text(title, style: kHeading)),
                const Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kRed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 216,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) =>
                  SizedBox(width: 140, child: _tile(items[i])),
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(String title, List<_Related> items) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 216,
            ),
            itemBuilder: (_, i) => _tile(items[i]),
          ),
        ],
      ),
    );
  }

  Widget _tile(_Related p) {
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
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('$off%', style: kBodyWhite),
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
                fontWeight: FontWeight.w700,
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
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total', style: kBodySub),
                Text(
                  '₹${_price * _qty}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kText,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kRed),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _snack('Added to cart'),
                child: const Text(
                  'Add to cart',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kRed,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kRed,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _snack('Proceeding to checkout'),
                child: const Text(
                  'Buy now',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
                            color: selected == i ? kRed : kSub,
                            size: 20,
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
                    child: const Text(
                      'Submit report',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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
                        _Review('You', stars, 'Just now', text, 0),
                      );
                      _reviewFilter = 0;
                    });
                    Navigator.pop(ctx);
                    _snack('Review posted');
                  },
                  child: const Text(
                    'Post review',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
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
              width: 22,
              height: 22,
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

  Widget _pad(Widget child) =>
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: child);

  Widget _divider() => Container(height: 8, color: kSoft);

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
