import 'package:flutter/material.dart';

class CheckoutPage4 extends StatefulWidget {
  const CheckoutPage4({super.key});

  @override
  State<CheckoutPage4> createState() => _CheckoutPage4State();
}

class _Product {
  final String name;
  final String category;
  final IconData icon;
  final double price;
  int qty;
  _Product(this.name, this.category, this.icon, this.price, this.qty);
  double get total => price * qty;
}

class _CheckoutPage4State extends State<CheckoutPage4> {
  // Palette (same theme)
  static const _crimson = Color(0xFF9E1B32);
  static const _ink = Color(0xFF14161A);
  static const _muted = Color(0xFF6B7280);
  static const _border = Color(0xFFE2E4E9);
  static const _bg = Color(0xFFFAFAFB);
  static const _green = Color(0xFF16803C);
  static const _currency = '₹';

  static const _all = 'All';

  // Demo cart: replace with your data
  final List<_Product> _items = [
    _Product(
      'Wireless Headphones',
      'Electronics',
      Icons.headphones_rounded,
      7999,
      1,
    ),
    _Product(
      'Fast Charging Cable (2m)',
      'Electronics',
      Icons.cable_rounded,
      499,
      2,
    ),
    _Product(
      'Cotton Crew Neck T-Shirt',
      'Fashion',
      Icons.checkroom_rounded,
      899,
      2,
    ),
    _Product('Denim Jacket', 'Fashion', Icons.dry_cleaning_rounded, 2499, 1),
    _Product(
      'Steel Water Bottle',
      'Home & Kitchen',
      Icons.water_drop_outlined,
      649,
      1,
    ),
  ];

  String _selected = _all;
  bool _coupon = true;
  String _payment = 'UPI';
  bool _loading = false;

  // ---------- Calculations ----------
  double get _subtotal => _items.fold(0, (s, i) => s + i.total);
  int get _count => _items.fold(0, (s, i) => s + i.qty);
  double get _discount => _coupon ? _subtotal * 0.10 : 0;
  double get _delivery => (_subtotal >= 999 || _items.isEmpty) ? 0 : 49;
  double get _tax => (_subtotal - _discount) * 0.18;
  double get _total => _subtotal - _discount + _delivery + _tax;

  List<String> get _categories {
    final list = <String>[];
    for (final i in _items) {
      if (!list.contains(i.category)) list.add(i.category);
    }
    return list;
  }

  double _catTotal(String c) =>
      _items.where((i) => i.category == c).fold(0.0, (s, i) => s + i.total);

  int _catCount(String c) =>
      _items.where((i) => i.category == c).fold(0, (s, i) => s + i.qty);

  List<_Product> get _visible => _selected == _all
      ? _items
      : _items.where((i) => i.category == _selected).toList();

  String _money(double v) {
    final p = v.toStringAsFixed(2).split('.');
    final whole = p[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '$_currency$whole.${p[1]}';
  }

  void _changeQty(_Product item, int delta) {
    setState(() {
      item.qty += delta;
      if (item.qty <= 0) _items.remove(item);
      if (_selected != _all && !_categories.contains(_selected)) {
        _selected = _all;
      }
    });
  }

  Future<void> _pay() async {
    setState(() => _loading = true);
    // TODO: call your payment API here
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _ink,
        behavior: SnackBarBehavior.floating,
        content: Text('Payment of ${_money(_total)} successful'),
      ),
    );
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: _ink,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ink,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          // On phones, keep the total visible in the app bar
          if (!wide && _items.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _crimson.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _money(_total),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: _crimson,
                  ),
                ),
              ),
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _border),
        ),
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 16, color: _muted),
              ),
            )
          : wide
          ? _wideLayout()
          : _narrowLayout(),
    );
  }

  Widget _narrowLayout() => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          ..._formChildren(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _billCard(),
          ),
        ],
      ),
    ),
  );

  Widget _wideLayout() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 6,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: _formChildren(),
        ),
      ),
      Expanded(
        flex: 4,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 20, 24, 32),
          child: _billCard(),
        ),
      ),
    ],
  );

  List<Widget> _formChildren() => [
    const SizedBox(height: 20),
    _sectionHeader('Your order', '$_count items'),
    const SizedBox(height: 12),
    _categoryChips(),
    const SizedBox(height: 14),
    _categorySummaryStrip(),
    const SizedBox(height: 10),
    _itemsList(),
    const SizedBox(height: 24),
    _sectionHeader('Deliver to', null),
    const SizedBox(height: 12),
    _addressTile(),
    const SizedBox(height: 24),
    _sectionHeader('Payment method', null),
    const SizedBox(height: 12),
    _paymentTiles(),
    const SizedBox(height: 16),
    _couponTile(),
  ];

  // ---------- Sections ----------
  Widget _sectionHeader(String title, String? trailing) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _ink,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(trailing, style: const TextStyle(fontSize: 13, color: _muted)),
      ],
    ),
  );

  Widget _categoryChips() {
    final cats = [_all, ..._categories];
    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final c = cats[i];
          final sel = _selected == c;
          final amount = c == _all ? _subtotal : _catTotal(c);
          return GestureDetector(
            onTap: () => setState(() => _selected = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: sel ? _crimson : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sel ? _crimson : _border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : _muted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _money(amount),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: sel ? Colors.white : _ink,
                      letterSpacing: -0.2,
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

  Widget _categorySummaryStrip() {
    final isAll = _selected == _all;
    final count = isAll ? _count : _catCount(_selected);
    final amount = isAll ? _subtotal : _catTotal(_selected);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _crimson.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isAll ? Icons.shopping_bag_outlined : Icons.sell_outlined,
            size: 18,
            color: _crimson,
          ),
          const SizedBox(width: 10),
          Text(
            isAll ? 'All categories' : _selected,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '• $count ${count == 1 ? 'item' : 'items'}',
            style: const TextStyle(fontSize: 13, color: _muted),
          ),
          const Spacer(),
          Text(
            _money(amount),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _crimson,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemsList() {
    final list = _visible;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < list.length; i++) ...[
            _itemRow(list[i]),
            if (i != list.length - 1)
              const Divider(
                height: 1,
                color: _border,
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }

  Widget _itemRow(_Product item) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            // Swap for Image.network(...) to show real product photos
            child: Icon(item.icon, size: 24, color: _muted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selected == _all)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      item.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _crimson,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_money(item.price)} × ${item.qty}',
                  style: const TextStyle(fontSize: 12.5, color: _muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _money(item.total),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              _stepper(item),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepper(_Product item) {
    Widget btn(IconData icon, VoidCallback onTap) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 28,
        width: 28,
        child: Icon(icon, size: 15, color: _ink),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(
            item.qty == 1 ? Icons.delete_outline_rounded : Icons.remove,
            () => _changeQty(item, -1),
          ),
          SizedBox(
            width: 24,
            child: Text(
              '${item.qty}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
            ),
          ),
          btn(Icons.add, () => _changeQty(item, 1)),
        ],
      ),
    );
  }

  Widget _addressTile() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border),
    ),
    child: Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: _crimson.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.home_outlined, color: _crimson, size: 22),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Home • John Doe',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              SizedBox(height: 3),
              Text(
                '42, Park Avenue, Main Road, City - 560001',
                style: TextStyle(fontSize: 13, color: _muted, height: 1.4),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: _crimson,
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 30),
          ),
          child: const Text(
            'Change',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  Widget _paymentTiles() {
    final methods = [
      ('UPI', Icons.account_balance_wallet_outlined),
      ('Card', Icons.credit_card_rounded),
      ('Banking', Icons.account_balance_outlined),
      ('COD', Icons.payments_outlined),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (int i = 0; i < methods.length; i++) ...[
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _payment = methods[i].$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _payment == methods[i].$1
                        ? _crimson.withOpacity(0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _payment == methods[i].$1 ? _crimson : _border,
                      width: _payment == methods[i].$1 ? 1.6 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        methods[i].$2,
                        size: 23,
                        color: _payment == methods[i].$1 ? _crimson : _muted,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        methods[i].$1,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: _payment == methods[i].$1 ? _crimson : _ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (i != methods.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }

  Widget _couponTile() => GestureDetector(
    onTap: () => setState(() => _coupon = !_coupon),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _coupon ? _green : _border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 21,
            color: _coupon ? _green : _muted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _coupon
                  ? 'SAVE10 applied: you save ${_money(_discount)}'
                  : 'Tap to apply coupon SAVE10',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _coupon ? _green : _ink,
              ),
            ),
          ),
          Icon(
            _coupon
                ? Icons.check_circle_rounded
                : Icons.add_circle_outline_rounded,
            size: 21,
            color: _coupon ? _green : _muted,
          ),
        ],
      ),
    ),
  );

  // ---------- Bill summary card (replaces the bottom panel) ----------
  Widget _billCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Crimson header with the total
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: const BoxDecoration(
              color: _crimson,
              borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BILL SUMMARY',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white70,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _money(_total),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_count items',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BY CATEGORY',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _muted,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                // Category rows with share bars
                for (final c in _categories) _categoryBillRow(c),

                const SizedBox(height: 6),
                const Divider(height: 1, color: _border),
                const SizedBox(height: 10),

                _row('Subtotal', _money(_subtotal)),
                if (_coupon)
                  _row(
                    'Discount (SAVE10)',
                    '- ${_money(_discount)}',
                    color: _green,
                  ),
                _row(
                  'Delivery',
                  _delivery == 0 ? 'FREE' : _money(_delivery),
                  color: _delivery == 0 ? _green : null,
                ),
                _row('GST (18%)', _money(_tax)),

                const SizedBox(height: 10),
                const _Dashed(),
                const SizedBox(height: 14),

                Row(
                  children: [
                    const Text(
                      'Total payable',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _money(_total),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _crimson,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _loading ? null : _pay,
                    style: FilledButton.styleFrom(
                      backgroundColor: _ink,
                      disabledBackgroundColor: _ink.withOpacity(0.7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_outline_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Pay ${_money(_total)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user_outlined, size: 15, color: _muted),
                    SizedBox(width: 6),
                    Text(
                      'Secure, encrypted payment',
                      style: TextStyle(fontSize: 12.5, color: _muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryBillRow(String c) {
    final amount = _catTotal(c);
    final share = _subtotal == 0 ? 0.0 : amount / _subtotal;
    final count = _catCount(c);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                c,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count ${count == 1 ? 'item' : 'items'}',
                style: const TextStyle(fontSize: 12, color: _muted),
              ),
              const Spacer(),
              Text(
                _money(amount),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: share,
              minHeight: 5,
              backgroundColor: const Color(0xFFF0F1F4),
              valueColor: const AlwaysStoppedAnimation(_crimson),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: _muted)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: color ?? _ink,
          ),
        ),
      ],
    ),
  );
}

class _Dashed extends StatelessWidget {
  const _Dashed();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const dash = 6.0, gap = 5.0;
        final count = (c.maxWidth / (dash + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(
              width: dash,
              height: 1.4,
              color: const Color(0xFFD1D5DB),
            ),
          ),
        );
      },
    );
  }
}
