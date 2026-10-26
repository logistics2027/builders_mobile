import 'package:builders_mobile/dynamic-ui/product/product_detail_page.dart';
import 'package:flutter/material.dart';

import 'category_explore_page.dart';

String _imgUrl(String seed, {int size = 600}) =>
    'https://picsum.photos/seed/$seed/$size/$size';

class _CatItem {
  final String name;
  final String offer;
  final String image;
  const _CatItem(this.name, this.offer, String seed)
    : image = 'https://picsum.photos/seed/$seed/600/600';
}

class CatgoryListPage2 extends StatefulWidget {
  const CatgoryListPage2({super.key});

  @override
  State<CatgoryListPage2> createState() => _CatgoryListPage2State();
}

class _CatgoryListPage2State extends State<CatgoryListPage2> {
  int _tab = 0;

  final List<String> _tabs = const ['Popular', 'Men', 'Women', 'Kids'];

  final List<String> _chips = const [
    'Under ₹499',
    'Under ₹999',
    'Min 50% off',
    'New arrivals',
    'Top rated',
  ];

  final List<List<_CatItem>> _data = const [
    // Popular
    [
      _CatItem('Watches', 'Up to 50% off', 'st-pop-1'),
      _CatItem('Sneakers', 'Min 40% off', 'st-pop-2'),
      _CatItem('Bags', 'From ₹499', 'st-pop-3'),
      _CatItem('Sunglasses', 'New arrivals', 'st-pop-4'),
      _CatItem('Jackets', 'Up to 45% off', 'st-pop-5'),
      _CatItem('Perfumes', 'From ₹299', 'st-pop-6'),
      _CatItem('Jewellery', 'Min 30% off', 'st-pop-7'),
      _CatItem('Earbuds', 'From ₹999', 'st-pop-8'),
    ],
    // Men
    [
      _CatItem('T-Shirts', 'Up to 50% off', 'st-men-1'),
      _CatItem('Shirts', 'Min 40% off', 'st-men-2'),
      _CatItem('Jeans', 'From ₹799', 'st-men-3'),
      _CatItem('Shoes', 'Up to 45% off', 'st-men-4'),
      _CatItem('Hoodies', 'Min 35% off', 'st-men-5'),
      _CatItem('Watches', 'From ₹999', 'st-men-6'),
      _CatItem('Trousers', 'New arrivals', 'st-men-7'),
      _CatItem('Sports', 'Up to 40% off', 'st-men-8'),
    ],
    // Women
    [
      _CatItem('Kurtas', 'Up to 50% off', 'st-wom-1'),
      _CatItem('Dresses', 'Min 40% off', 'st-wom-2'),
      _CatItem('Sarees', 'From ₹699', 'st-wom-3'),
      _CatItem('Heels', 'Up to 45% off', 'st-wom-4'),
      _CatItem('Handbags', 'Min 35% off', 'st-wom-5'),
      _CatItem('Beauty', 'From ₹199', 'st-wom-6'),
      _CatItem('Tops', 'New arrivals', 'st-wom-7'),
      _CatItem('Activewear', 'Up to 40% off', 'st-wom-8'),
    ],
    // Kids
    [
      _CatItem('Boys wear', 'Up to 50% off', 'st-kid-1'),
      _CatItem('Girls wear', 'Min 40% off', 'st-kid-2'),
      _CatItem('Toys', 'From ₹149', 'st-kid-3'),
      _CatItem('Shoes', 'Up to 45% off', 'st-kid-4'),
      _CatItem('Infants', 'Min 35% off', 'st-kid-5'),
      _CatItem('School', 'From ₹299', 'st-kid-6'),
      _CatItem('Books', 'New arrivals', 'st-kid-7'),
      _CatItem('Winter', 'Up to 40% off', 'st-kid-8'),
    ],
  ];

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
        titleSpacing: 16,
        title: GestureDetector(
          onTap: _openExplore,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: kSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, size: 20, color: kSub),
                SizedBox(width: 8),
                Text('Search categories & brands', style: kBodySub),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => _snack('Wishlist opened'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => _snack('Cart opened'),
          ),
        ],
      ),
      body: Column(
        children: [
          _tabBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  _chipRow(),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text('Shop ${_tabs[_tab]}', style: kHeading),
                        const Spacer(),
                        GestureDetector(
                          onTap: _openExplore,
                          child: const Text(
                            'View all',
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
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: KeyedSubtree(
                      key: ValueKey(_tab),
                      child: _staggered(_data[_tab]),
                    ),
                  ),
                  _promoCard(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _tabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kLine)),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = i == _tab;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _tab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? kRed : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? kRed : kText,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _chipRow() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: _openExplore,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kLine),
            ),
            child: Text(_chips[i], style: kBody),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Staggered two-column layout (left and right columns have alternating heights)
  // -------------------------------------------------------------------------
  Widget _staggered(List<_CatItem> items) {
    const tall = 224.0;
    const short = 172.0;

    final left = <Widget>[];
    final right = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      final isLeft = i.isEven;
      final order = i ~/ 2;
      // left column: tall, short, tall, short...  right column: short, tall, ...
      final height = isLeft
          ? (order.isEven ? tall : short)
          : (order.isEven ? short : tall);
      final card = Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _card(items[i], height),
      );
      (isLeft ? left : right).add(card);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: left)),
          const SizedBox(width: 12),
          Expanded(child: Column(children: right)),
        ],
      ),
    );
  }

  Widget _card(_CatItem c, double height) {
    return GestureDetector(
      onTap: _openExplore,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _net(c.image),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0x00000000), Color(0xB3000000)],
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_outward_rounded,
                    size: 14,
                    color: kRed,
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: kRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        c.offer,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _promoCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: GestureDetector(
        onTap: _openExplore,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 130,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _net(_imgUrl('st-promo', size: 800)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'End of season sale',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Flat 40% off on top picks',
                          style: kBodyWhite,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
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
      ),
    );
  }

  // -------------------------------------------------------------------------
  void _openExplore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoryExplorePage()),
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
