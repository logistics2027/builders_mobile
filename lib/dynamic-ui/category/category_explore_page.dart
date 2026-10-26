import 'package:builders_mobile/dynamic-ui/product/product_detail_page.dart';
import 'package:flutter/material.dart';

const Color _kRedTint = Color(0xFFFDECEC);

String _imgUrl(String seed, {int size = 500}) =>
    'https://picsum.photos/seed/$seed/$size/$size';

class _Cat {
  final String name;
  final String image;
  final String tagline;
  final List<String> subs;
  const _Cat(this.name, this.image, this.tagline, this.subs);
}

class _Prod {
  final String id;
  final String name;
  final String cat;
  final String sub;
  final int price;
  final int oldPrice;
  final double rating;
  final int reviews;
  final String image;
  const _Prod(
    this.id,
    this.name,
    this.cat,
    this.sub,
    this.price,
    this.oldPrice,
    this.rating,
    this.reviews,
    this.image,
  );

  int get discount => (((oldPrice - price) / oldPrice) * 100).round();
}

_Prod _p(
  String id,
  String name,
  String cat,
  String sub,
  int price,
  int old,
  double rating,
  int reviews,
) {
  return _Prod(
    id,
    name,
    cat,
    sub,
    price,
    old,
    rating,
    reviews,
    _imgUrl('explore-$id'),
  );
}

class CategoryExplorePage extends StatefulWidget {
  const CategoryExplorePage({super.key});

  @override
  State<CategoryExplorePage> createState() => _CategoryExplorePageState();
}

class _CategoryExplorePageState extends State<CategoryExplorePage> {
  final TextEditingController _searchController = TextEditingController();

  int _catIndex = 0;
  String _sub = 'All';
  String _query = '';
  int _sort = 0; // 0 popular, 1 low-high, 2 high-low
  final Set<String> _favs = {};

  final List<_Cat> _cats = [
    _Cat('Watches', _imgUrl('ex-cat-watch', size: 200), 'Up to 50% off', [
      'All',
      'Smart',
      'Fitness',
      'Kids',
    ]),
    _Cat('Earbuds', _imgUrl('ex-cat-buds', size: 200), 'Starting at ₹999', [
      'All',
      'True wireless',
      'Neckband',
      'Gaming',
    ]),
    _Cat('Speakers', _imgUrl('ex-cat-speaker', size: 200), 'Loud and clear', [
      'All',
      'Portable',
      'Party',
      'Soundbar',
    ]),
    _Cat('Cameras', _imgUrl('ex-cat-camera', size: 200), 'Capture more', [
      'All',
      'Action',
      'Vlogging',
      'Security',
    ]),
    _Cat(
      'Accessories',
      _imgUrl('ex-cat-acc', size: 200),
      'Everyday essentials',
      ['All', 'Chargers', 'Cases', 'Straps'],
    ),
    _Cat('Gaming', _imgUrl('ex-cat-game', size: 200), 'Level up', [
      'All',
      'Controllers',
      'Headsets',
      'Mice',
    ]),
  ];

  late final List<_Prod> _prods = [
    // Watches
    _p('w1', 'Aero X2 Smart Watch', 'Watches', 'Smart', 2499, 3999, 4.5, 312),
    _p('w2', 'Aero Pro Max', 'Watches', 'Smart', 3999, 5499, 4.7, 421),
    _p('w3', 'Pulse Fit Band', 'Watches', 'Fitness', 1299, 1999, 4.0, 188),
    _p('w4', 'Runner GPS Watch', 'Watches', 'Fitness', 4299, 5999, 4.4, 97),
    _p('w5', 'Kids Tracker', 'Watches', 'Kids', 999, 1499, 3.9, 54),
    _p('w6', 'Little Star Watch', 'Watches', 'Kids', 1199, 1799, 4.1, 41),
    // Earbuds
    _p(
      'e1',
      'Wireless Buds Neo',
      'Earbuds',
      'True wireless',
      1499,
      2499,
      4.4,
      256,
    ),
    _p('e2', 'Bass Buds Pro', 'Earbuds', 'True wireless', 1999, 3299, 4.3, 143),
    _p('e3', 'Sprint Neckband', 'Earbuds', 'Neckband', 899, 1499, 4.2, 330),
    _p('e4', 'Flex Neckband 2', 'Earbuds', 'Neckband', 1099, 1799, 4.1, 120),
    _p('e5', 'Gamer Buds X', 'Earbuds', 'Gaming', 1799, 2999, 4.3, 78),
    // Speakers
    _p('s1', 'Boom Mini Speaker', 'Speakers', 'Portable', 1199, 1999, 4.2, 97),
    _p('s2', 'Roam Go Speaker', 'Speakers', 'Portable', 1499, 2299, 4.4, 150),
    _p('s3', 'Thunder 40W', 'Speakers', 'Party', 3499, 4999, 4.6, 210),
    _p('s4', 'Party Tower 60W', 'Speakers', 'Party', 5999, 8499, 4.5, 66),
    _p('s5', 'Cinema Soundbar', 'Speakers', 'Soundbar', 4999, 7499, 4.3, 88),
    // Cameras
    _p('c1', 'Snap Action Camera', 'Cameras', 'Action', 4499, 6999, 4.1, 64),
    _p('c2', 'Trail Cam 4K', 'Cameras', 'Action', 5499, 7999, 4.3, 52),
    _p('c3', 'Vlog Pocket Cam', 'Cameras', 'Vlogging', 4999, 7499, 4.4, 88),
    _p('c4', 'Home Guard 360', 'Cameras', 'Security', 2299, 3499, 4.2, 140),
    // Accessories
    _p('a1', 'Power Bank 10K', 'Accessories', 'Chargers', 999, 1599, 4.3, 530),
    _p(
      'a2',
      'Fast Charger 33W',
      'Accessories',
      'Chargers',
      699,
      1199,
      4.2,
      280,
    ),
    _p('a3', 'Travel Case', 'Accessories', 'Cases', 399, 699, 4.5, 120),
    _p('a4', 'Hard Shell Case', 'Accessories', 'Cases', 549, 899, 4.0, 62),
    _p('a5', 'Strap Set (3 pack)', 'Accessories', 'Straps', 499, 899, 4.1, 76),
    // Gaming
    _p('g1', 'Pro Controller', 'Gaming', 'Controllers', 2299, 3499, 4.5, 190),
    _p('g2', 'Pulse Headset 7.1', 'Gaming', 'Headsets', 2799, 4299, 4.4, 134),
    _p('g3', 'Rapid RGB Mouse', 'Gaming', 'Mice', 899, 1499, 4.2, 305),
    _p('g4', 'Click Mini Mouse', 'Gaming', 'Mice', 599, 999, 4.0, 90),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _searching => _query.isNotEmpty;

  List<_Prod> get _visible {
    final cat = _cats[_catIndex];
    var list = _prods.where((p) {
      if (_searching)
        return p.name.toLowerCase().contains(_query.toLowerCase());
      if (p.cat != cat.name) return false;
      return _sub == 'All' || p.sub == _sub;
    }).toList();

    if (_sort == 1) list.sort((a, b) => a.price.compareTo(b.price));
    if (_sort == 2) list.sort((a, b) => b.price.compareTo(a.price));
    if (_sort == 0) list.sort((a, b) => b.reviews.compareTo(a.reviews));
    return list;
  }

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
        title: const Text('Explore', style: kHeading),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => _snack('Cart opened'),
          ),
        ],
      ),
      body: Column(
        children: [
          _searchBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sidebar(),
                Expanded(child: _rightPane()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: TextField(
        controller: _searchController,
        style: kBody,
        cursorColor: kRed,
        onChanged: (v) => setState(() => _query = v.trim()),
        decoration: InputDecoration(
          hintText: 'Search in all categories',
          hintStyle: kBodySub,
          prefixIcon: const Icon(Icons.search, color: kSub, size: 20),
          suffixIcon: _searching
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18, color: kSub),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          filled: true,
          fillColor: kSoft,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // LEFT: category sidebar (soft red tile for the selected item)
  // -------------------------------------------------------------------------
  Widget _sidebar() {
    return SizedBox(
      width: 84,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 4, 4, 16),
        itemCount: _cats.length,
        itemBuilder: (_, i) {
          final c = _cats[i];
          final selected = i == _catIndex && !_searching;
          return GestureDetector(
            onTap: () {
              _searchController.clear();
              setState(() {
                _catIndex = i;
                _sub = 'All';
                _query = '';
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
                color: selected ? _kRedTint : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? kRed : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _net(c.image),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? kRed : kText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // RIGHT: banner + sub chips + products
  // -------------------------------------------------------------------------
  Widget _rightPane() {
    final cat = _cats[_catIndex];
    final items = _visible;

    return CustomScrollView(
      key: ValueKey('pane-$_catIndex-$_searching'),
      slivers: [
        if (!_searching) ...[
          SliverToBoxAdapter(child: _banner(cat)),
          SliverToBoxAdapter(child: _subChips(cat)),
        ],
        SliverToBoxAdapter(child: _resultHeader(items.length, cat)),
        if (items.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: _emptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(4, 0, 12, 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _card(items[i]),
                childCount: items.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 236,
              ),
            ),
          ),
      ],
    );
  }

  Widget _banner(_Cat cat) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 124,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _net(_imgUrl('banner-${cat.name}', size: 600)),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xE6D32F2F), Color(0x00D32F2F)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(cat.tagline, style: kBodyWhite),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Shop now',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: kRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subChips(_Cat cat) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(4, 2, 12, 6),
        itemCount: cat.subs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = cat.subs[i];
          final selected = s == _sub;
          return GestureDetector(
            onTap: () => setState(() => _sub = s),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? kRed : kSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(s, style: selected ? kBodyWhite : kBody),
            ),
          );
        },
      ),
    );
  }

  Widget _resultHeader(int count, _Cat cat) {
    final title = _searching ? 'Search results' : cat.name;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 2, 4, 4),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kText,
                    ),
                  ),
                  TextSpan(text: '  $count items', style: kBodySub),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          PopupMenuButton<int>(
            tooltip: 'Sort',
            icon: const Icon(Icons.swap_vert_rounded, color: kText, size: 22),
            color: Colors.white,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => [
              _sortItem(0, 'Popularity'),
              _sortItem(1, 'Price: low to high'),
              _sortItem(2, 'Price: high to low'),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<int> _sortItem(int value, String label) {
    final selected = _sort == value;
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Icon(
            selected ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: selected ? kRed : kSub,
          ),
          const SizedBox(width: 8),
          Text(label, style: kBody),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Product card: image on top, info panel below, add button inside the card
  // -------------------------------------------------------------------------
  Widget _card(_Prod p) {
    final fav = _favs.contains(p.id);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProductDetailPage()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kLine),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(13),
                      ),
                      child: _net(p.image),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: kRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${p.discount}% OFF',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        if (!_favs.add(p.id)) _favs.remove(p.id);
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          fav ? Icons.favorite : Icons.favorite_border,
                          size: 15,
                          color: fav ? kRed : kText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kBody,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: kStar),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          '${p.rating} (${p.reviews})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: kBodySub,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${p.price}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: kText,
                              ),
                            ),
                            Text(
                              '₹${p.oldPrice}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: kSub,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _snack('${p.name} added to cart'),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: kRed,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: kSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 34, color: kSub),
          ),
          const SizedBox(height: 10),
          const Text('No products found', style: kHeading),
          const SizedBox(height: 4),
          const Text('Try another sub category or search', style: kBodySub),
        ],
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
              width: 18,
              height: 18,
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
