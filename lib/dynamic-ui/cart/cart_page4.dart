import 'package:flutter/material.dart';

class CartPage4 extends StatefulWidget {
  const CartPage4({super.key});

  @override
  State<CartPage4> createState() => _CartPage4State();
}

class _CartItem {
  final String name;
  final String variant;
  final double price;
  final IconData icon;
  int qty;

  _CartItem({
    required this.name,
    required this.variant,
    required this.price,
    required this.icon,
    this.qty = 1,
  });
}

class _CartPage4State extends State<CartPage4> {
  // Theme
  static const Color primary = Color(0xFFD32F2F);
  static const Color primarySoft = Color(0xFFFDECEC);
  static const Color bg = Color(0xFFF6F6F8);
  static const Color textDark = Color(0xFF1F2024);
  static const Color textMuted = Color(0xFF7A7D85);
  static const Color border = Color(0xFFE9E9ED);
  static const double r = 12;

  final TextEditingController _promo = TextEditingController();
  double _discount = 0;

  final List<_CartItem> _items = [
    _CartItem(
        name: 'Wireless Headphones',
        variant: 'Black · Over-ear',
        price: 2499,
        icon: Icons.headphones_rounded),
    _CartItem(
        name: 'Smart Watch',
        variant: 'Silver · 44mm',
        price: 3999,
        icon: Icons.watch_rounded),
    _CartItem(
        name: 'Power Bank',
        variant: '20000 mAh',
        price: 1299,
        icon: Icons.battery_charging_full_rounded,
        qty: 2),
  ];

  double get _subtotal =>
      _items.fold(0, (s, i) => s + i.price * i.qty);
  double get _delivery => _items.isEmpty || _subtotal > 5000 ? 0 : 49;
  double get _total => _subtotal - _discount + _delivery;
  int get _count => _items.fold(0, (s, i) => s + i.qty);

  @override
  void dispose() {
    _promo.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promo.text.trim().toUpperCase();
    setState(() => _discount = code == 'SAVE10' ? _subtotal * 0.10 : 0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: code == 'SAVE10' ? Colors.green[700] : primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
        content: Text(code == 'SAVE10'
            ? 'Promo applied: 10% off'
            : 'Invalid promo code'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: textDark),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Shopping Cart',
            style: TextStyle(
                color: textDark, fontSize: 17, fontWeight: FontWeight.w600)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),
      body: _items.isEmpty ? _empty() : _content(),
      bottomNavigationBar: _items.isEmpty ? null : _checkoutBar(),
    );
  }

  // ---------- Content ----------

  Widget _content() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
          child: Text('$_count items in your cart',
              style: const TextStyle(
                  fontSize: 13,
                  color: textMuted,
                  fontWeight: FontWeight.w500)),
        ),
        ...List.generate(_items.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _itemCard(_items[i], i),
            )),
        const SizedBox(height: 4),
        _promoCard(),
        const SizedBox(height: 8),
        _summaryCard(),
      ],
    );
  }

  Widget _itemCard(_CartItem item, int index) {
    return Dismissible(
      key: ObjectKey(item),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => setState(() => _items.removeAt(index)),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(r),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: primarySoft,
                borderRadius: BorderRadius.circular(r),
              ),
              child: Icon(item.icon, color: primary, size: 30),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: textDark)),
                  const SizedBox(height: 2),
                  Text(item.variant,
                      style:
                          const TextStyle(fontSize: 12, color: textMuted)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_money(item.price * item.qty),
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: primary)),
                      _qty(item),
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

  Widget _qty(_CartItem item) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(Icons.remove_rounded, () {
            if (item.qty > 1) setState(() => item.qty--);
          }),
          SizedBox(
            width: 24,
            child: Text('${item.qty}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textDark)),
          ),
          _qtyBtn(Icons.add_rounded, () => setState(() => item.qty++)),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(r),
      onTap: onTap,
      child: SizedBox(
        width: 28,
        height: 30,
        child: Icon(icon, size: 16, color: primary),
      ),
    );
  }

  Widget _promoCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined, color: primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _promo,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Promo code (try SAVE10)',
                hintStyle: TextStyle(fontSize: 13, color: textMuted),
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(
            height: 34,
            child: ElevatedButton(
              onPressed: _applyPromo,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(r)),
              ),
              child: const Text('Apply',
                  style:
                      TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textDark)),
          const SizedBox(height: 10),
          _line('Subtotal', _money(_subtotal)),
          if (_discount > 0)
            _line('Discount', '- ${_money(_discount)}',
                valueColor: Colors.green[700]),
          _line('Delivery', _delivery == 0 ? 'Free' : _money(_delivery),
              valueColor: _delivery == 0 ? Colors.green[700] : null),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, color: border),
          ),
          _line('Total', _money(_total), bold: true),
        ],
      ),
    );
  }

  Widget _line(String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: bold ? 15 : 13.5,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  color: bold ? textDark : textMuted)),
          Text(value,
              style: TextStyle(
                  fontSize: bold ? 17 : 13.5,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: valueColor ?? (bold ? primary : textDark))),
        ],
      ),
    );
  }

  // ---------- Bottom bar ----------

  Widget _checkoutBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Total',
                    style: TextStyle(fontSize: 12, color: textMuted)),
                Text(_money(_total),
                    style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: textDark)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Proceed to Checkout',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: primarySoft, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_cart_outlined,
                size: 44, color: primary),
          ),
          const SizedBox(height: 12),
          const Text('Your cart is empty',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textDark)),
          const SizedBox(height: 4),
          const Text('Add items to get started',
              style: TextStyle(fontSize: 13, color: textMuted)),
        ],
      ),
    );
  }

  // ---------- Helpers ----------

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: border),
      );

  String _money(double v) => '₹${v.toStringAsFixed(0)}';
}