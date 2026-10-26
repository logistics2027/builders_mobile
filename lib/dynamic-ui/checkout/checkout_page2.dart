import 'package:flutter/material.dart';

class CheckoutPage2 extends StatefulWidget {
  const CheckoutPage2({super.key});

  @override
  State<CheckoutPage2> createState() => _CheckoutPage2State();
}

class _Item {
  final String name;
  final String category;
  final double price;
  final int qty;
  const _Item(this.name, this.category, this.price, this.qty);
  double get total => price * qty;
}

class _CheckoutPage2State extends State<CheckoutPage2> {
  // Palette (same theme)
  static const _crimson = Color(0xFF9E1B32);
  static const _crimsonDark = Color(0xFF5E0E1D);
  static const _ink = Color(0xFF14161A);
  static const _muted = Color(0xFF6B7280);
  static const _border = Color(0xFFE2E4E9);
  static const _bg = Color(0xFFF4F4F6);
  static const _green = Color(0xFF16803C);
  static const _currency = '₹';

  // Demo cart: replace with your data
  final List<_Item> _items = const [
    _Item('Wireless Headphones', 'Electronics', 7999, 1),
    _Item('Fast Charging Cable (2m)', 'Electronics', 499, 2),
    _Item('Cotton Crew Neck T-Shirt', 'Fashion', 899, 2),
    _Item('Denim Jacket', 'Fashion', 2499, 1),
    _Item('Steel Water Bottle', 'Home & Kitchen', 649, 1),
  ];

  static const _categoryIcons = {
    'Electronics': Icons.devices_rounded,
    'Fashion': Icons.checkroom_rounded,
    'Home & Kitchen': Icons.kitchen_rounded,
  };

  bool _couponOn = true;
  int _delivery = 0; // 0 = standard, 1 = express
  String _payment = 'UPI';
  bool _loading = false;

  // ---------- Calculations ----------
  double get _subtotal => _items.fold(0, (s, i) => s + i.total);
  int get _count => _items.fold(0, (s, i) => s + i.qty);
  double get _discount => _couponOn ? _subtotal * 0.10 : 0;
  double get _deliveryFee => _delivery == 1 ? 99 : (_subtotal >= 999 ? 0 : 49);
  double get _tax => (_subtotal - _discount) * 0.18;
  double get _total => _subtotal - _discount + _deliveryFee + _tax;

  Map<String, List<_Item>> get _grouped {
    final m = <String, List<_Item>>{};
    for (final i in _items) {
      m.putIfAbsent(i.category, () => []).add(i);
    }
    return m;
  }

  String _money(double v) {
    final p = v.toStringAsFixed(2).split('.');
    final whole = p[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '$_currency$whole.${p[1]}';
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
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
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
          'Secure checkout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ink,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              _steps(),
              const SizedBox(height: 20),
              _heroCard(),
              const SizedBox(height: 28),
              _title('Items by category'),
              ..._grouped.entries.map((e) => _categoryTile(e.key, e.value)),
              const SizedBox(height: 16),
              _title('Delivery speed'),
              _deliveryTiles(),
              const SizedBox(height: 22),
              _couponTile(),
              const SizedBox(height: 28),
              _title('Pay with'),
              _paymentGrid(),
              const SizedBox(height: 28),
              _title('Bill details'),
              _receipt(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomPay(),
    );
  }

  // ---------- Pieces ----------
  Widget _title(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _ink,
        letterSpacing: -0.2,
      ),
    ),
  );

  Widget _steps() {
    Widget dot(String label, bool done, bool active) => Column(
      children: [
        Container(
          height: 26,
          width: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done || active ? _crimson : Colors.white,
            border: Border.all(color: done || active ? _crimson : _border),
          ),
          child: done
              ? const Icon(Icons.check, size: 15, color: Colors.white)
              : active
              ? const Icon(Icons.circle, size: 8, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active || done ? _ink : _muted,
          ),
        ),
      ],
    );

    Widget line(bool filled) => Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: filled ? _crimson : _border,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        dot('Cart', true, false),
        line(true),
        dot('Payment', false, true),
        line(false),
        dot('Done', false, false),
      ],
    );
  }

  Widget _heroCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [_crimson, _crimsonDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: _crimson.withOpacity(0.25),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'AMOUNT TO PAY',
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.white70,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
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
        const SizedBox(height: 10),
        Text(
          _money(_total),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            if (_discount > 0) ...[
              const Icon(
                Icons.savings_outlined,
                size: 17,
                color: Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(
                'You save ${_money(_discount)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
            ],
            const Icon(
              Icons.local_shipping_outlined,
              size: 17,
              color: Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              _delivery == 1 ? 'Arrives today' : 'Arrives in 3–5 days',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _categoryTile(String category, List<_Item> items) {
    final catTotal = items.fold<double>(0, (s, i) => s + i.total);
    final count = items.fold<int>(0, (s, i) => s + i.qty);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          iconColor: _muted,
          collapsedIconColor: _muted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          leading: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: _crimson.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _categoryIcons[category] ?? Icons.category_outlined,
              size: 21,
              color: _crimson,
            ),
          ),
          title: Text(
            category,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          subtitle: Text(
            '$count ${count == 1 ? 'item' : 'items'}',
            style: const TextStyle(fontSize: 12.5, color: _muted),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _money(catTotal),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _crimson,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more_rounded, color: _muted),
            ],
          ),
          children: [
            const Divider(height: 1, color: _border),
            const SizedBox(height: 10),
            for (final i in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            i.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${_money(i.price)}  ×  ${i.qty}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: _muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _money(i.total),
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _deliveryTiles() {
    Widget tile(int index, String name, String eta, String price) {
      final sel = _delivery == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _delivery = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: sel ? _crimson.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: sel ? _crimson : _border,
                width: sel ? 1.6 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      index == 0
                          ? Icons.inventory_2_outlined
                          : Icons.bolt_rounded,
                      size: 20,
                      color: sel ? _crimson : _muted,
                    ),
                    const Spacer(),
                    Icon(
                      sel ? Icons.check_circle_rounded : Icons.circle_outlined,
                      size: 19,
                      color: sel ? _crimson : const Color(0xFFC4C8D0),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(eta, style: const TextStyle(fontSize: 12, color: _muted)),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: price == 'FREE' ? _green : _ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tile(0, 'Standard', '3–5 days', _subtotal >= 999 ? 'FREE' : _money(49)),
        const SizedBox(width: 12),
        tile(1, 'Express', 'Today', _money(99)),
      ],
    );
  }

  Widget _couponTile() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border),
    ),
    child: Row(
      children: [
        const Icon(Icons.local_offer_outlined, size: 22, color: _crimson),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SAVE10',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '10% off on your order',
                style: TextStyle(fontSize: 12.5, color: _muted),
              ),
            ],
          ),
        ),
        Switch(
          value: _couponOn,
          activeColor: Colors.white,
          activeTrackColor: _crimson,
          onChanged: (v) => setState(() => _couponOn = v),
        ),
      ],
    ),
  );

  Widget _paymentGrid() {
    final methods = [
      ('UPI', Icons.account_balance_wallet_outlined),
      ('Card', Icons.credit_card_rounded),
      ('Net banking', Icons.account_balance_outlined),
      ('Cash on delivery', Icons.payments_outlined),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.6,
      children: methods.map((m) {
        final sel = _payment == m.$1;
        return GestureDetector(
          onTap: () => setState(() => _payment = m.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: sel ? _crimson : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sel ? _crimson : _border),
            ),
            child: Row(
              children: [
                Icon(m.$2, size: 21, color: sel ? Colors.white : _muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    m.$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : _ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _receipt() {
    Widget row(String l, String v, {Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(l, style: const TextStyle(fontSize: 14, color: _muted)),
          const Spacer(),
          Text(
            v,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: color ?? _ink,
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          // Per-category amounts
          for (final e in _grouped.entries)
            row(e.key, _money(e.value.fold<double>(0, (s, i) => s + i.total))),
          const SizedBox(height: 4),
          row('Subtotal', _money(_subtotal)),
          if (_couponOn)
            row('Discount (SAVE10)', '- ${_money(_discount)}', color: _green),
          row(
            'Delivery',
            _deliveryFee == 0 ? 'FREE' : _money(_deliveryFee),
            color: _deliveryFee == 0 ? _green : null,
          ),
          row('GST (18%)', _money(_tax)),

          // Ticket-style tear line
          SizedBox(
            height: 28,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 1),
                  painter: _DashedLinePainter(),
                ),
                Positioned(left: -30, child: _notch()),
                Positioned(right: -30, child: _notch()),
              ],
            ),
          ),

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
        ],
      ),
    );
  }

  Widget _notch() => Container(
    height: 20,
    width: 20,
    decoration: const BoxDecoration(color: _bg, shape: BoxShape.circle),
  );

  Widget _bottomPay() => Container(
    color: _bg,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _pay,
                style: FilledButton.styleFrom(
                  backgroundColor: _ink,
                  disabledBackgroundColor: _ink.withOpacity(0.7),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
                          const Icon(Icons.lock_outline_rounded, size: 19),
                          const SizedBox(width: 10),
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
          ),
        ),
      ),
    ),
  );
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1.4;
    const dash = 6.0;
    const gap = 5.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
