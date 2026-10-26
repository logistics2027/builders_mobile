import 'package:builders_mobile/dynamic-ui/product/product_detail_page.dart';
import 'package:flutter/material.dart';

import 'category_explore_page.dart';

const Color _kTint = Color(0xFFFDECEC);

class _Cat {
  final String name;
  final String image;
  final String? tag;
  const _Cat(this.name, String seed, {this.tag})
    : image = 'https://picsum.photos/seed/$seed/300/300';
}

class _Section {
  final String title;
  final List<_Cat> items;
  const _Section(this.title, this.items);
}

class CatgoryListPage4 extends StatefulWidget {
  const CatgoryListPage4({super.key});

  @override
  State<CatgoryListPage4> createState() => _CatgoryListPage4State();
}

class _CatgoryListPage4State extends State<CatgoryListPage4> {
  final List<_Section> _sections = const [
    _Section('Grocery & Kitchen', [
      _Cat('Fruits & Vegetables', 'zp-fruits', tag: 'FRESH'),
      _Cat('Dairy & Milk', 'zp-dairy'),
      _Cat('Bread & Eggs', 'zp-bread'),
      _Cat('Atta, Rice & Dal', 'zp-atta'),
      _Cat('Oil & Masala', 'zp-oil'),
      _Cat('Dry Fruits', 'zp-dry', tag: '10% OFF'),
      _Cat('Cereals', 'zp-cereal'),
      _Cat('Tea & Coffee', 'zp-tea'),
    ]),
    _Section('Snacks & Drinks', [
      _Cat('Chips & Namkeen', 'zp-chips'),
      _Cat('Biscuits', 'zp-biscuit'),
      _Cat('Chocolates', 'zp-choco', tag: 'NEW'),
      _Cat('Cold Drinks', 'zp-cold'),
      _Cat('Juices', 'zp-juice'),
      _Cat('Instant Food', 'zp-instant'),
      _Cat('Noodles & Pasta', 'zp-noodle'),
      _Cat('Ice Creams', 'zp-ice', tag: '20% OFF'),
    ]),
    _Section('Beauty & Personal Care', [
      _Cat('Skin Care', 'zp-skin'),
      _Cat('Hair Care', 'zp-hair'),
      _Cat('Bath & Body', 'zp-bath'),
      _Cat('Makeup', 'zp-makeup', tag: 'NEW'),
      _Cat('Fragrances', 'zp-fragrance'),
      _Cat('Men\'s Grooming', 'zp-men'),
      _Cat('Oral Care', 'zp-oral'),
      _Cat('Wellness', 'zp-wellness'),
    ]),
    _Section('Household Essentials', [
      _Cat('Cleaning', 'zp-clean'),
      _Cat('Laundry', 'zp-laundry'),
      _Cat('Pooja Needs', 'zp-pooja'),
      _Cat('Stationery', 'zp-station'),
    ]),
  ];

  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _cartBar(),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [_infoStrip(), for (final s in _sections) _section(s)],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Header: delivery time, address, profile and search
  // -------------------------------------------------------------------------
  Widget _header() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kTint, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt_rounded, color: kRed, size: 22),
                            SizedBox(width: 2),
                            Text(
                              'Delivery in 10 minutes',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: kText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: () => _snack('Choose address'),
                          child: const Row(
                            children: [
                              Text('Home', style: kBody),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '· 12, Main Road',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: kBodySub,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: kText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: kLine),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 22,
                      color: kText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _openExplore,
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kLine),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: kRed, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text("Search for 'milk'", style: kBodySub),
                      ),
                      Icon(Icons.mic_none_rounded, color: kSub, size: 20),
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

  Widget _infoStrip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _kTint,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.delivery_dining_rounded, color: kRed, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Free delivery on orders above ₹199',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Section with a 4-column wrap of category tiles
  // -------------------------------------------------------------------------
  Widget _section(_Section s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.title, style: kHeading),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 10.0;
              final w = (constraints.maxWidth - spacing * 3) / 4;
              return Wrap(
                spacing: spacing,
                runSpacing: 16,
                children: s.items.map((c) => _tile(c, w)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tile(_Cat c, double w) {
    return GestureDetector(
      onTap: _openExplore,
      child: SizedBox(
        width: w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _kTint,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _net(c.image),
                      ),
                    ),
                  ),
                  if (c.tag != null)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: const BoxDecoration(
                          color: kRed,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Text(
                          c.tag!,
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
            const SizedBox(height: 6),
            Text(
              c.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: kText,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Floating cart bar
  // -------------------------------------------------------------------------
  Widget _cartBar() {
    return SafeArea(
      child: GestureDetector(
        onTap: () => _snack('Cart opened'),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: kRed,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33D32F2F),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '2 items  ·  ₹248',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'View cart',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
            ],
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
        return const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: kRed),
          ),
        );
      },
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.image_not_supported_outlined, color: kSub, size: 20),
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
