import 'package:builders_mobile/dynamic-ui/product/product_detail_page.dart';
import 'package:flutter/material.dart';


String _imgUrl(String seed, {int size = 500}) => 'https://picsum.photos/seed/$seed/$size/$size';

class _Category {
  final String name;
  final String image;
  const _Category(this.name, this.image);
}

class _Item {
  final String id;
  final String name;
  final String category;
  final int price;
  final int oldPrice;
  final double rating;
  final int reviews;
  final String image;
  const _Item(this.id, this.name, this.category, this.price, this.oldPrice, this.rating,
      this.reviews, this.image);

  int get discount => (((oldPrice - price) / oldPrice) * 100).round();
}

class CatgoryListPage extends StatefulWidget {
  const CatgoryListPage({super.key});

  @override
  State<CatgoryListPage> createState() => _CatgoryListPageState();
}

class _CatgoryListPageState extends State<CatgoryListPage> {
  final TextEditingController _searchController = TextEditingController();

  String _category = 'All';
  String _query = '';
  int _sort = 0; // 0 popular, 1 price low-high, 2 price high-low, 3 rating
  bool _isGrid = true;
  double _maxPrice = 5000;
  final Set<String> _favs = {};

  final List<_Category> _categories = [
    _Category('All', _imgUrl('cat-all', size: 200)),
    _Category('Watches', _imgUrl('cat-watch', size: 200)),
    _Category('Earbuds', _imgUrl('cat-buds', size: 200)),
    _Category('Speakers', _imgUrl('cat-speaker', size: 200)),
    _Category('Cameras', _imgUrl('cat-camera', size: 200)),
    _Category('Accessories', _imgUrl('cat-acc', size: 200)),
  ];

  final List<_Item> _items = [
    _Item('1', 'Aero X2 Smart Watch', 'Watches', 2499, 3999, 4.5, 312, _imgUrl('item-1')),
    _Item('2', 'Pulse Band Lite', 'Watches', 1299, 1999, 4.0, 188, _imgUrl('item-2')),
    _Item('3', 'Aero Pro Max', 'Watches', 3999, 5499, 4.7, 421, _imgUrl('item-3')),
    _Item('4', 'Wireless Buds Neo', 'Earbuds', 1499, 2499, 4.4, 256, _imgUrl('item-4')),
    _Item('5', 'Bass Buds Pro', 'Earbuds', 1999, 3299, 4.3, 143, _imgUrl('item-5')),
    _Item('6', 'Boom Mini Speaker', 'Speakers', 1199, 1999, 4.2, 97, _imgUrl('item-6')),
    _Item('7', 'Thunder 40W Speaker', 'Speakers', 3499, 4999, 4.6, 210, _imgUrl('item-7')),
    _Item('8', 'Snap Action Camera', 'Cameras', 4499, 6999, 4.1, 64, _imgUrl('item-8')),
    _Item('9', 'Vlog Pocket Cam', 'Cameras', 4999, 7499, 4.4, 88, _imgUrl('item-9')),
    _Item('10', 'Power Bank 10K', 'Accessories', 999, 1599, 4.3, 530, _imgUrl('item-10')),
    _Item('11', 'Strap Set (3 pack)', 'Accessories', 499, 899, 4.1, 76, _imgUrl('item-11')),
    _Item('12', 'Travel Case', 'Accessories', 399, 699, 4.5, 120, _imgUrl('item-12')),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Item> get _filtered {
    var list = _items.where((e) {
      final matchCat = _category == 'All' || e.category == _category;
      final matchQuery = _query.isEmpty || e.name.toLowerCase().contains(_query.toLowerCase());
      return matchCat && matchQuery && e.price <= _maxPrice;
    }).toList();

    switch (_sort) {
      case 1:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 2:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 3:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        list.sort((a, b) => b.reviews.compareTo(a.reviews));
    }
    return list;
  }

  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: kText,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Categories', style: kHeading),
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
          _categoryRow(),
          _toolbar(items.length),
          Container(height: 1, color: kLine),
          Expanded(
            child: items.isEmpty
                ? _emptyState()
                : (_isGrid ? _gridView(items) : _listView(items)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        controller: _searchController,
        style: kBody,
        cursorColor: kRed,
        onChanged: (v) => setState(() => _query = v.trim()),
        decoration: InputDecoration(
          hintText: 'Search products',
          hintStyle: kBodySub,
          prefixIcon: const Icon(Icons.search, color: kSub, size: 20),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 18, color: kSub),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
          filled: true,
          fillColor: kSoft,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _categoryRow() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final c = _categories[i];
          final selected = c.name == _category;
          return GestureDetector(
            onTap: () => setState(() => _category = c.name),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? kRed : kLine, width: 2),
                  ),
                  child: ClipOval(child: _net(c.image)),
                ),
                const SizedBox(height: 6),
                Text(
                  c.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? kRed : kText,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _toolbar(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      child: Row(
        children: [
          Expanded(child: Text('$count products', style: kBodySub)),
          TextButton.icon(
            onPressed: _openFilterSheet,
            icon: const Icon(Icons.tune_rounded, size: 18, color: kText),
            label: const Text('Sort & filter', style: kBody),
          ),
          IconButton(
            tooltip: _isGrid ? 'List view' : 'Grid view',
            icon: Icon(_isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                color: kText, size: 22),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _gridView(List<_Item> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        mainAxisExtent: 250,
      ),
      itemBuilder: (_, i) => _gridCard(items[i]),
    );
  }

  Widget _gridCard(_Item p) {
    final fav = _favs.contains(p.id);
    return GestureDetector(
      onTap: _openDetail,
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
                  child: _badge('${p.discount}% OFF'),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _toggleFav(p.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Icon(fav ? Icons.favorite : Icons.favorite_border,
                          size: 16, color: fav ? kRed : kText),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: kBody),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(Icons.star, size: 13, color: kStar),
              const SizedBox(width: 3),
              Text('${p.rating} (${p.reviews})', style: kBodySub),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text('₹${p.price}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800, color: kText)),
              const SizedBox(width: 6),
              Text('₹${p.oldPrice}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: kSub,
                    decoration: TextDecoration.lineThrough,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _listView(List<_Item> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: kLine)),
      itemBuilder: (_, i) => _listCard(items[i]),
    );
  }

  Widget _listCard(_Item p) {
    final fav = _favs.contains(p.id);
    return GestureDetector(
      onTap: _openDetail,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _net(p.image),
                  ),
                ),
                Positioned(top: 6, left: 6, child: _badge('${p.discount}%')),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 112,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(p.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700, color: kText)),
                      ),
                      GestureDetector(
                        onTap: () => _toggleFav(p.id),
                        child: Icon(fav ? Icons.favorite : Icons.favorite_border,
                            size: 20, color: fav ? kRed : kSub),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(p.category, style: kBodySub),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 13, color: kStar),
                      const SizedBox(width: 3),
                      Text('${p.rating} (${p.reviews})', style: kBodySub),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${p.price}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800, color: kText)),
                      const SizedBox(width: 6),
                      Text('₹${p.oldPrice}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: kSub,
                            decoration: TextDecoration.lineThrough,
                          )),
                      const Spacer(),
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kRed,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _snack('${p.name} added to cart'),
                          child: const Text('Add', style: kBodyWhite),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(color: kSoft, shape: BoxShape.circle),
            child: const Icon(Icons.search_off_rounded, size: 38, color: kSub),
          ),
          const SizedBox(height: 12),
          const Text('No products found', style: kHeading),
          const SizedBox(height: 4),
          const Text('Try a different search or filter', style: kBodySub),
          const SizedBox(height: 14),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kRed),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _query = '';
                _category = 'All';
                _maxPrice = 5000;
                _sort = 0;
              });
            },
            child: const Text('Clear all',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kRed)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  void _openFilterSheet() {
    int sort = _sort;
    double maxPrice = _maxPrice;
    const sortLabels = [
      'Popularity',
      'Price: low to high',
      'Price: high to low',
      'Customer rating',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Sort & filter', style: kHeading)),
                    TextButton(
                      onPressed: () => setSheet(() {
                        sort = 0;
                        maxPrice = 5000;
                      }),
                      child: const Text('Reset',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700, color: kRed)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Sort by', style: kBodySub),
                const SizedBox(height: 4),
                ...List.generate(sortLabels.length, (i) {
                  return InkWell(
                    onTap: () => setSheet(() => sort = i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(
                        children: [
                          Icon(
                            sort == i
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            size: 20,
                            color: sort == i ? kRed : kSub,
                          ),
                          const SizedBox(width: 10),
                          Text(sortLabels[i], style: kBody),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Max price', style: kBodySub),
                    const Spacer(),
                    Text('₹${maxPrice.round()}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: kText)),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(ctx).copyWith(
                    activeTrackColor: kRed,
                    thumbColor: kRed,
                    inactiveTrackColor: kLine,
                    overlayColor: const Color(0x22D32F2F),
                  ),
                  child: Slider(
                    value: maxPrice,
                    min: 500,
                    max: 5000,
                    divisions: 45,
                    onChanged: (v) => setSheet(() => maxPrice = v),
                  ),
                ),
                const SizedBox(height: 8),
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
                      setState(() {
                        _sort = sort;
                        _maxPrice = maxPrice;
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Apply',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  void _openDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductDetailPage()),
    );
  }

  void _toggleFav(String id) {
    setState(() {
      if (!_favs.add(id)) _favs.remove(id);
    });
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(5)),
      child: Text(text,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
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
        child: const Center(child: Icon(Icons.image_not_supported_outlined, color: kSub)),
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