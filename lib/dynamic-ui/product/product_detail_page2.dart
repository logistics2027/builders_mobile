import 'package:builders_mobile/dynamic-ui/product/product_detail_page.dart';
import 'package:flutter/material.dart';

const Color _kTint = Color(0xFFFDECEC);

String _u(String seed, {int size = 800}) => 'https://picsum.photos/seed/$seed/$size/$size';

class _Review {
  final String name;
  final int rating;
  final String date;
  final String text;
  int helpful;
  _Review(this.name, this.rating, this.date, this.text, this.helpful);
}

class _Like {
  final String name;
  final int price;
  final int oldPrice;
  final double rating;
  final String image;
  const _Like(this.name, this.price, this.oldPrice, this.rating, this.image);
}

class ProductDetailPage2 extends StatefulWidget {
  const ProductDetailPage2({super.key});

  @override
  State<ProductDetailPage2> createState() => _ProductDetailPage2State();
}

class _ProductDetailPage2State extends State<ProductDetailPage2> {
  static const int _price = 2499;
  static const int _oldPrice = 3999;

  final PageController _pageController = PageController();
  final TextEditingController _pinController = TextEditingController();

  int _image = 0;
  int _color = 0;
  int _size = 1;
  int _qty = 1;
  int _tab = 0;
  bool _fav = false;
  bool _pinChecked = false;
  final Set<_Review> _helped = {};

  final List<String> _images = [
    _u('pd2-front'),
    _u('pd2-side'),
    _u('pd2-back'),
    _u('pd2-wrist'),
  ];

  final List<Map<String, dynamic>> _colors = const [
    {'name': 'Crimson', 'color': Color(0xFFD32F2F)},
    {'name': 'Rose', 'color': Color(0xFFF06292)},
    {'name': 'Slate', 'color': Color(0xFF607D8B)},
    {'name': 'Black', 'color': Color(0xFF212121)},
  ];

  final List<String> _sizes = const ['S', 'M', 'L', 'XL'];
  final List<String> _tabs = const ['Details', 'Specs', 'Reviews'];

  final List<String> _highlights = const [
    '1.69" AMOLED display with always-on mode',
    'Heart rate, SpO2, sleep and stress tracking',
    '100+ sports modes with auto detection',
    'Up to 10 days battery life',
    'IP68 water and dust resistance',
  ];

  final List<String> _offers = const [
    '10% instant discount on card payments',
    'No-cost EMI from ₹417 per month',
    'Extra ₹100 off on your first order',
  ];

  final Map<String, String> _specs = const {
    'Brand': 'RedPulse',
    'Model': 'RP-Aero X2',
    'Display': '1.69" AMOLED',
    'Battery': 'Up to 10 days',
    'Water resistance': 'IP68',
    'Connectivity': 'Bluetooth 5.3',
    'Weight': '38 g',
    'Warranty': '1 year',
  };

  final Map<int, int> _bars = const {5: 62, 4: 24, 3: 8, 2: 4, 1: 2};

  final List<_Review> _reviews = [
    _Review('Aarav Sharma', 5, '12 Oct 2026',
        'Amazing build quality and the battery really lasts over a week. Looks very premium.', 18),
    _Review('Priya Nair', 4, '03 Oct 2026',
        'Great value for money. Strap is comfortable. The app could be a bit smoother.', 9),
    _Review('Rahul Verma', 5, '28 Sep 2026',
        'Fast delivery, neat packaging and the display is bright even outdoors.', 12),
  ];

  final List<_Like> _likes = [
    _Like('Aero Lite', 1799, 2999, 4.2, _u('pd2-like1', size: 400)),
    _Like('Pulse Band', 1299, 1999, 4.0, _u('pd2-like2', size: 400)),
    _Like('Aero Pro Max', 3999, 5499, 4.7, _u('pd2-like3', size: 400)),
    _Like('Kids Tracker', 999, 1499, 3.9, _u('pd2-like4', size: 400)),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _pinController.dispose();
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                _hero(),
                Padding(
                  padding: const EdgeInsets.only(top: 352),
                  child: _sheet(),
                ),
              ],
            ),
          ),
          _floatingTopBar(),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Hero image with floating buttons and vertical thumbnails
  // -------------------------------------------------------------------------
  Widget _floatingTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              _circleBtn(Icons.arrow_back_rounded, () => Navigator.maybePop(context)),
              const Spacer(),
              _circleBtn(
                _fav ? Icons.favorite : Icons.favorite_border,
                () => setState(() => _fav = !_fav),
                color: _fav ? kRed : kText,
              ),
              const SizedBox(width: 8),
              _circleBtn(Icons.share_outlined, () => _snack('Link copied')),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                color: Colors.white,
                onSelected: (v) {
                  if (v == 'report') _reportSheet('this product');
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag_outlined, size: 18, color: kRed),
                        SizedBox(width: 8),
                        Text('Report this product', style: kBody),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.more_horiz, size: 20, color: kText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, {Color color = kText}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _hero() {
    return SizedBox(
      height: 380,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: (i) => setState(() => _image = i),
            itemBuilder: (_, i) => _net(_images[i]),
          ),
          // vertical thumbnails
          Positioned(
            left: 12,
            bottom: 52,
            child: Column(
              children: List.generate(_images.length, (i) {
                final selected = i == _image;
                return GestureDetector(
                  onTap: () => _pageController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  ),
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? kRed : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _net(_images[i]),
                    ),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            right: 14,
            bottom: 44,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${_image + 1} / ${_images.length}', style: kBodyWhite),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Rounded sheet with all details
  // -------------------------------------------------------------------------
  Widget _sheet() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleBlock(),
          const SizedBox(height: 18),
          _colorBlock(),
          const SizedBox(height: 18),
          _sizeBlock(),
          const SizedBox(height: 18),
          _deliveryBlock(),
          const SizedBox(height: 22),
          _tabSwitcher(),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: KeyedSubtree(
              key: ValueKey(_tab),
              child: _tabContent(),
            ),
          ),
          const SizedBox(height: 26),
          _likeSection(),
          const SizedBox(height: 20),
          _reportRow(),
        ],
      ),
    );
  }

  Widget _titleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: _kTint, borderRadius: BorderRadius.circular(6)),
              child: const Text('Bestseller',
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700, color: kRed)),
            ),
            const SizedBox(width: 8),
            const Text('RedPulse', style: kBodySub),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Aero X2 Smart Watch',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: kText)),
        const SizedBox(height: 4),
        const Text('AMOLED display • Heart-rate • 100+ sports modes',
            style: kBodySub),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('₹$_price',
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800, color: kRed)),
            const SizedBox(width: 10),
            const Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Text('₹$_oldPrice',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kSub,
                    decoration: TextDecoration.lineThrough,
                  )),
            ),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: kRed, borderRadius: BorderRadius.circular(6)),
              child: Text('$_discount% OFF',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: kLine),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 15, color: kStar),
                  const SizedBox(width: 4),
                  Text(_avg.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kText)),
                  const SizedBox(width: 4),
                  const Text('(1.2k)', style: kBodySub),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Text('Inclusive of all taxes', style: kBodySub),
      ],
    );
  }

  Widget _colorBlock() {
    return Column(
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
        Row(
          children: List.generate(_colors.length, (i) {
            final selected = i == _color;
            return GestureDetector(
              onTap: () => setState(() => _color = i),
              child: Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: selected ? kRed : kLine, width: selected ? 2 : 1),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: _colors[i]['color'] as Color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _sizeBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Strap size', style: kHeading),
            const Spacer(),
            GestureDetector(
              onTap: () => _snack('Size guide opened'),
              child: const Text('Size guide',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: kRed)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(_sizes.length, (i) {
            final selected = i == _size;
            return GestureDetector(
              onTap: () => setState(() => _size = i),
              child: Container(
                width: 50,
                height: 40,
                margin: const EdgeInsets.only(right: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? _kTint : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: selected ? kRed : kLine, width: selected ? 1.5 : 1),
                ),
                child: Text(_sizes[i],
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected ? kRed : kText)),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _deliveryBlock() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping_outlined, size: 20, color: kRed),
              SizedBox(width: 8),
              Text('Delivery options', style: kHeading),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: kBody,
                  cursorColor: kRed,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Enter pincode',
                    hintStyle: kBodySub,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (_pinController.text.trim().length == 6) {
                      setState(() => _pinChecked = true);
                    } else {
                      _snack('Enter a valid 6 digit pincode');
                    }
                  },
                  child: const Text('Check', style: kBodyWhite),
                ),
              ),
            ],
          ),
          if (_pinChecked) ...[
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Color(0xFF2E7D32)),
                SizedBox(width: 6),
                Expanded(
                  child: Text('Delivery in 2–3 days • Free delivery',
                      style: kBody),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.replay_rounded, size: 16, color: kSub),
              SizedBox(width: 6),
              Text('7-day easy returns', style: kBodySub),
              SizedBox(width: 16),
              Icon(Icons.verified_user_outlined, size: 16, color: kSub),
              SizedBox(width: 6),
              Text('1-year warranty', style: kBodySub),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Tabs: Details / Specs / Reviews
  // -------------------------------------------------------------------------
  Widget _tabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = i == _tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? kRed : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : kText,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _tabContent() {
    switch (_tab) {
      case 0:
        return _detailsTab();
      case 1:
        return _specsTab();
      default:
        return _reviewsTab();
    }
  }

  Widget _detailsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The RedPulse Aero X2 pairs a vivid AMOLED display with all-day health tracking, '
          'a lightweight aluminium body and a battery that goes the distance.',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: kSub, height: 1.5),
        ),
        const SizedBox(height: 14),
        const Text('Highlights', style: kHeading),
        const SizedBox(height: 8),
        ..._highlights.map(
          (h) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(Icons.check_circle_rounded, size: 16, color: kRed),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(h, style: kBody)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text('Offers for you', style: kHeading),
        const SizedBox(height: 8),
        ..._offers.map(
          (o) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer_outlined, size: 18, color: kRed),
                const SizedBox(width: 10),
                Expanded(child: Text(o, style: kBody)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _specsTab() {
    final entries = _specs.entries.toList();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kLine),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: List.generate(entries.length, (i) {
          final last = i == entries.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: last ? Colors.transparent : kLine),
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

  Widget _reviewsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              children: [
                Text(_avg.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 38, fontWeight: FontWeight.w800, color: kText)),
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
                          child: Text('$pct%',
                              textAlign: TextAlign.right, style: kBodySub),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kRed),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _writeReviewSheet,
            icon: const Icon(Icons.edit_outlined, size: 16, color: kRed),
            label: const Text('Write a review',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: kRed)),
          ),
        ),
        ..._reviews.map((r) {
          final helped = _helped.contains(r);
          return Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: kLine),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: _kTint,
                      child: Text(r.name[0],
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kRed)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: kText)),
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
                Text(r.text,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: kText,
                        height: 1.45)),
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
                              helped
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              size: 15,
                              color: helped ? kRed : kSub),
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
    );
  }

  // -------------------------------------------------------------------------
  Widget _likeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('You may also like', style: kHeading),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _likes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final p = _likes[i];
              final off = (((p.oldPrice - p.price) / p.oldPrice) * 100).round();
              return SizedBox(
                width: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: _net(p.image),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: kRed,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text('$off%',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: kBody),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text('₹${p.price}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: kText)),
                        const SizedBox(width: 6),
                        Text('₹${p.oldPrice}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: kSub,
                              decoration: TextDecoration.lineThrough,
                            )),
                        const Spacer(),
                        const Icon(Icons.star, size: 12, color: kStar),
                        const SizedBox(width: 2),
                        Text('${p.rating}', style: kBodySub),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _reportRow() {
    return GestureDetector(
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
              child: Text('Found something wrong with this listing?',
                  style: kBody),
            ),
            Text('Report',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: kRed)),
          ],
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
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: kLine),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _stepBtn(Icons.remove, () {
                    if (_qty > 1) setState(() => _qty--);
                  }),
                  SizedBox(
                    width: 28,
                    child: Text('$_qty',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kText)),
                  ),
                  _stepBtn(Icons.add, () {
                    if (_qty < 10) setState(() => _qty++);
                  }),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _snack('Added to cart'),
                  child: Text('Add to cart  •  ₹${_price * _qty}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(icon, size: 18, color: kText),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Sheets
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
              16, 18, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
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
                          borderRadius: BorderRadius.circular(10)),
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
              16, 18, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
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
                      child: Icon(i < stars ? Icons.star : Icons.star_border,
                          color: kStar, size: 34),
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
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    setState(() {
                      _reviews.insert(
                          0, _Review('You', stars, 'Just now', text, 0));
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
        (i) => Icon(i < count ? Icons.star : Icons.star_border,
            size: size, color: kStar),
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
            child: Icon(Icons.image_not_supported_outlined, color: kSub)),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: kText,
        behavior: SnackBarBehavior.floating,
        content: Text(msg, style: kBodyWhite),
      ));
  }
}