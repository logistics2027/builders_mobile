import 'package:flutter/material.dart';

class CheckoutPage1 extends StatefulWidget {
  const CheckoutPage1({super.key});

  @override
  State<CheckoutPage1> createState() => _CheckoutPage1State();
}

class _CartItem {
  final String name;
  final String category;
  final IconData icon;
  final double price;
  int qty;

  _CartItem({
    required this.name,
    required this.category,
    required this.icon,
    required this.price,
    this.qty = 1,
  });

  double get total => price * qty;
}

class _CheckoutPage1State extends State<CheckoutPage1> {
  // Palette (same as the other pages)
  static const _crimson = Color(0xFF9E1B32);
  static const _ink = Color(0xFF14161A);
  static const _muted = Color(0xFF6B7280);
  static const _border = Color(0xFFE2E4E9);
  static const _bg = Color(0xFFFAFAFB);
  static const _green = Color(0xFF16803C);

  // Change this to your currency symbol
  static const _currency = '₹';

  final _promoController = TextEditingController();
  bool _promoApplied = false;
  String? _promoError;
  String _payment = 'upi';
  bool _loading = false;

  // Demo data: replace with your cart
  final List<_CartItem> _items = [
    _CartItem(
        name: 'Wireless Noise-Cancelling Headphones',
        category: 'Electronics',
        icon: Icons.headphones_rounded,
        price: 7999),
    _CartItem(
        name: 'Fast Charging Cable (2m)',
        category: 'Electronics',
        icon: Icons.cable_rounded,
        price: 499,
        qty: 2),
    _CartItem(
        name: 'Cotton Crew Neck T-Shirt',
        category: 'Fashion',
        icon: Icons.checkroom_rounded,
        price: 899,
        qty: 2),
    _CartItem(
        name: 'Stainless Steel Water Bottle',
        category: 'Home & Kitchen',
        icon: Icons.water_drop_outlined,
        price: 649),
  ];

  // ---------- Calculations ----------
  double get _subtotal => _items.fold(0, (s, i) => s + i.total);
  double get _discount => _promoApplied ? _subtotal * 0.10 : 0;
  double get _delivery => (_subtotal >= 999 || _items.isEmpty) ? 0 : 49;
  double get _tax => (_subtotal - _discount) * 0.18;
  double get _grandTotal => _subtotal - _discount + _delivery + _tax;
  int get _itemCount => _items.fold(0, (s, i) => s + i.qty);

  Map<String, List<_CartItem>> get _grouped {
    final map = <String, List<_CartItem>>{};
    for (final i in _items) {
      map.putIfAbsent(i.category, () => []).add(i);
    }
    return map;
  }

  String _money(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '$_currency$whole.${parts[1]}';
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  // ---------- Actions ----------
  void _changeQty(_CartItem item, int delta) {
    setState(() {
      item.qty += delta;
      if (item.qty <= 0) _items.remove(item);
    });
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    setState(() {
      if (code == 'SAVE10') {
        _promoApplied = true;
        _promoError = null;
      } else {
        _promoApplied = false;
        _promoError = 'Invalid promo code';
      }
    });
  }

  Future<void> _placeOrder() async {
    setState(() => _loading = true);
    // TODO: call your payment / order API here
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _ink,
        behavior: SnackBarBehavior.floating,
        content: Text('Order placed • ${_money(_grandTotal)}'),
      ),
    );
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: _ink),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Checkout',
            style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: _ink,
                letterSpacing: -0.4)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _border),
        ),
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text('Your cart is empty',
                  style: TextStyle(fontSize: 16, color: _muted)))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                    _sectionTitle('Delivery address'),
                    _addressCard(),
                    const SizedBox(height: 24),
                    _sectionTitle('Order items',
                        trailing: '$_itemCount items'),
                    ..._grouped.entries
                        .map((e) => _categoryCard(e.key, e.value)),
                    const SizedBox(height: 12),
                    _sectionTitle('Promo code'),
                    _promoCard(),
                    const SizedBox(height: 24),
                    _sectionTitle('Payment method'),
                    _paymentCard(),
                    const SizedBox(height: 24),
                    _sectionTitle('Price details'),
                    _summaryCard(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _items.isEmpty ? null : _bottomBar(),
    );
  }

  // ---------- Sections ----------
  Widget _sectionTitle(String text, {String? trailing}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Text(text,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                    letterSpacing: -0.2)),
            const Spacer(),
            if (trailing != null)
              Text(trailing,
                  style: const TextStyle(fontSize: 13, color: _muted)),
          ],
        ),
      );

  Widget _card({required Widget child, EdgeInsets? padding}) => Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: child,
      );

  Widget _addressCard() => _card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: _crimson.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.location_on_outlined,
                  color: _crimson, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('John Doe',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _ink)),
                  SizedBox(height: 4),
                  Text(
                    '42, Park Avenue, Main Road,\nCity - 560001',
                    style:
                        TextStyle(fontSize: 13.5, color: _muted, height: 1.45),
                  ),
                  SizedBox(height: 4),
                  Text('+91 98765 43210',
                      style: TextStyle(fontSize: 13.5, color: _muted)),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                  foregroundColor: _crimson,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 30)),
              child: const Text('Change',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );

  Widget _categoryCard(String category, List<_CartItem> items) {
    final count = items.fold<int>(0, (s, i) => s + i.qty);
    final catTotal = items.fold<double>(0, (s, i) => s + i.total);

    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Category header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _crimson.withOpacity(0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              border: const Border(bottom: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _crimson,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.8),
                  ),
                ),
                const SizedBox(width: 10),
                Text('$count ${count == 1 ? 'item' : 'items'}',
                    style: const TextStyle(fontSize: 12.5, color: _muted)),
                const Spacer(),
                Text(_money(catTotal),
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
              ],
            ),
          ),
          // Items
          for (int i = 0; i < items.length; i++) ...[
            _itemRow(items[i]),
            if (i != items.length - 1)
              const Divider(height: 1, color: _border, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }

  Widget _itemRow(_CartItem item) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            // Replace with Image.network(...) for real product photos
            child: Icon(item.icon, size: 28, color: _muted),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                        height: 1.3)),
                const SizedBox(height: 4),
                Text('${_money(item.price)} each',
                    style: const TextStyle(fontSize: 12.5, color: _muted)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _qtyStepper(item),
                    const Spacer(),
                    Text(_money(item.total),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                            letterSpacing: -0.2)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyStepper(_CartItem item) {
    Widget btn(IconData icon, VoidCallback onTap) => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 30,
            width: 30,
            child: Icon(icon, size: 16, color: _ink),
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
          btn(item.qty == 1 ? Icons.delete_outline_rounded : Icons.remove,
              () => _changeQty(item, -1)),
          SizedBox(
            width: 28,
            child: Text('${item.qty}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: _ink)),
          ),
          btn(Icons.add, () => _changeQty(item, 1)),
        ],
      ),
    );
  }

  Widget _promoCard() => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(fontSize: 15, color: _ink),
                    cursorColor: _crimson,
                    decoration: InputDecoration(
                      hintText: 'Enter promo code',
                      hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF), fontSize: 15),
                      prefixIcon: const Icon(Icons.local_offer_outlined,
                          size: 20, color: _muted),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: _crimson, width: 1.6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _applyPromo,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _crimson,
                      side: const BorderSide(color: _crimson),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Apply',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            if (_promoApplied) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 16, color: _green),
                  const SizedBox(width: 6),
                  Text('SAVE10 applied: you saved ${_money(_discount)}',
                      style: const TextStyle(
                          fontSize: 13,
                          color: _green,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
            if (_promoError != null) ...[
              const SizedBox(height: 10),
              Text(_promoError!,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFFD92D20))),
            ],
          ],
        ),
      );

  Widget _paymentCard() {
    final options = [
      ('upi', Icons.account_balance_wallet_outlined, 'UPI', 'Pay using any UPI app'),
      ('card', Icons.credit_card_rounded, 'Credit / Debit card', 'Visa, Mastercard, RuPay'),
      ('netbanking', Icons.account_balance_outlined, 'Net banking', 'All major banks'),
      ('cod', Icons.payments_outlined, 'Cash on delivery', 'Pay when you receive'),
    ];

    return Column(
      children: options.map((o) {
        final selected = _payment == o.$1;
        return GestureDetector(
          onTap: () => setState(() => _payment = o.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? _crimson.withOpacity(0.04) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: selected ? _crimson : _border,
                  width: selected ? 1.6 : 1),
            ),
            child: Row(
              children: [
                Icon(o.$2, size: 24, color: selected ? _crimson : _muted),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.$3,
                          style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: _ink)),
                      const SizedBox(height: 2),
                      Text(o.$4,
                          style:
                              const TextStyle(fontSize: 12.5, color: _muted)),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? _crimson : const Color(0xFFC4C8D0),
                  size: 22,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _summaryCard() => _card(
        child: Column(
          children: [
            _summaryRow('Subtotal ($_itemCount items)', _money(_subtotal)),
            if (_promoApplied)
              _summaryRow('Promo discount (10%)', '- ${_money(_discount)}',
                  valueColor: _green),
            _summaryRow('Delivery fee',
                _delivery == 0 ? 'FREE' : _money(_delivery),
                valueColor: _delivery == 0 ? _green : null),
            _summaryRow('GST (18%)', _money(_tax)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: _border),
            ),
            Row(
              children: [
                const Text('Total payable',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
                const Spacer(),
                Text(_money(_grandTotal),
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _crimson,
                        letterSpacing: -0.5)),
              ],
            ),
            if (_delivery > 0) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add ${_money(999 - _subtotal)} more for free delivery',
                  style: const TextStyle(fontSize: 12.5, color: _muted),
                ),
              ),
            ],
          ],
        ),
      );

  Widget _summaryRow(String label, String value, {Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(fontSize: 14, color: _muted)),
            const Spacer(),
            Text(value,
                style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? _ink)),
          ],
        ),
      );

  // ---------- Sticky bottom bar ----------
  Widget _bottomBar() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: _border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total',
                            style: TextStyle(fontSize: 12.5, color: _muted)),
                        const SizedBox(height: 2),
                        Text(_money(_grandTotal),
                            style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: _ink,
                                letterSpacing: -0.5)),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _loading ? null : _placeOrder,
                          style: FilledButton.styleFrom(
                            backgroundColor: _crimson,
                            disabledBackgroundColor:
                                _crimson.withOpacity(0.7),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock_outline_rounded, size: 18),
                                    SizedBox(width: 8),
                                    Text('Place order',
                                        style: TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2)),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}