import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class CheckoutPage5 extends StatefulWidget {
  const CheckoutPage5({super.key});

  @override
  State<CheckoutPage5> createState() => _CheckoutPage5State();
}

class _Entry {
  final String name;
  final String category;
  final IconData icon;
  final double price;
  final int qty;
  const _Entry(this.name, this.category, this.icon, this.price, this.qty);
  double get total => price * qty;
}

class _CheckoutPage5State extends State<CheckoutPage5> {
  // Palette (same theme)
  static const _crimson = Color(0xFF9E1B32);
  static const _crimsonDark = Color(0xFF5E0E1D);
  static const _ink = Color(0xFF14161A);
  static const _muted = Color(0xFF6B7280);
  static const _border = Color(0xFFE2E4E9);
  static const _bg = Color(0xFFF6F6F8);
  static const _green = Color(0xFF16803C);
  static const _currency = '₹';

  // Demo cart: replace with your data
  final List<_Entry> _items = const [
    _Entry('Wireless Headphones', 'Electronics', Icons.headphones_rounded, 7999, 1),
    _Entry('Fast Charging Cable (2m)', 'Electronics', Icons.cable_rounded, 499, 2),
    _Entry('Cotton Crew Neck T-Shirt', 'Fashion', Icons.checkroom_rounded, 899, 2),
    _Entry('Denim Jacket', 'Fashion', Icons.dry_cleaning_rounded, 2499, 1),
    _Entry('Steel Water Bottle', 'Home & Kitchen', Icons.water_drop_outlined, 649, 1),
  ];

  final _promoController = TextEditingController();
  bool _promoApplied = false;
  String? _promoError;
  int _delivery = 0; // 0 standard, 1 express
  String _payment = 'UPI';
  bool _loading = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  // ---------- Calculations ----------
  double get _subtotal => _items.fold(0, (s, i) => s + i.total);
  int get _count => _items.fold(0, (s, i) => s + i.qty);
  double get _discount => _promoApplied ? _subtotal * 0.10 : 0;
  double get _deliveryFee => _delivery == 1 ? 99 : (_subtotal >= 999 ? 0 : 49);
  double get _tax => (_subtotal - _discount) * 0.18;
  double get _total => _subtotal - _discount + _deliveryFee + _tax;

  Map<String, List<_Entry>> get _grouped {
    final m = <String, List<_Entry>>{};
    for (final i in _items) {
      m.putIfAbsent(i.category, () => []).add(i);
    }
    return m;
  }

  double _catTotal(List<_Entry> l) => l.fold(0.0, (s, i) => s + i.total);
  int _catCount(List<_Entry> l) => l.fold(0, (s, i) => s + i.qty);

  String _money(double v) {
    final p = v.toStringAsFixed(2).split('.');
    final whole =
        p[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '$_currency$whole.${p[1]}';
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

  Future<void> _pay() async {
    setState(() => _loading = true);
    // TODO: call your payment API here
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: _ink,
      behavior: SnackBarBehavior.floating,
      content: Text('Payment of ${_money(_total)} successful'),
    ));
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _collapsingHeader(),

                  // Category sections with sticky headers
                  for (final e in _grouped.entries)
                    SliverStickyHeader(
                      header: _CategoryHeader(
                        title: e.key,
                        count: _catCount(e.value),
                        amount: _money(_catTotal(e.value)),
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) =>
                              _itemRow(e.value[i], i == e.value.length - 1),
                          childCount: e.value.length,
                        ),
                      ),
                    ),

                  _box(const SizedBox(height: 28)),
                  _box(_title('Delivery speed')),
                  _box(_deliveryOptions()),
                  _box(const SizedBox(height: 28)),
                  _box(_title('Payment method')),
                  _box(_paymentList()),
                  _box(const SizedBox(height: 28)),
                  _box(_title('Promo code')),
                  _box(_promoField()),
                  _box(const SizedBox(height: 28)),
                  _box(_title('Bill details')),
                  _box(_billCard()),
                  SliverToBoxAdapter(
                      child: SizedBox(height: 110 + bottomInset)),
                ],
              ),

              // Floating pay pill
              Positioned(
                left: 20,
                right: 20,
                bottom: bottomInset + 16,
                child: _payPill(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Header ----------
  Widget _collapsingHeader() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 220,
      backgroundColor: _crimsonDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: Colors.white),
        onPressed: () => Navigator.maybePop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        expandedTitleScale: 2.1,
        titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 16),
        centerTitle: false,
        title: Text(
          _money(_total),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_crimson, _crimsonDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -30,
                child: Container(
                  height: 190,
                  width: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.08), width: 1),
                  ),
                ),
              ),
              const Positioned(
                left: 20,
                bottom: 82,
                child: Text('TOTAL PAYABLE',
                    style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white70,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600)),
              ),
              Positioned(
                left: 20,
                bottom: 12,
                child: Row(
                  children: [
                    if (_promoApplied) ...[
                      _pill(Icons.savings_outlined,
                          'Saved ${_money(_discount)}'),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              Positioned(
                right: 20,
                bottom: 18,
                child: _pill(Icons.shopping_bag_outlined, '$_count items'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(text,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );

  // ---------- Helpers ----------
  Widget _box(Widget child) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: child,
        ),
      );

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(t,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _ink,
                letterSpacing: -0.2)),
      );

  // ---------- Items ----------
  Widget _itemRow(_Entry item, bool last) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: last ? _border : const Color(0xFFF0F1F4)),
        ),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                // Swap for Image.network(...) for real product photos
                child: Icon(item.icon, size: 25, color: _muted),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _ink,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text('${item.qty}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
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
                        height: 1.25)),
                const SizedBox(height: 4),
                Text('${_money(item.price)} × ${item.qty}',
                    style: const TextStyle(fontSize: 12.5, color: _muted)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(_money(item.total),
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: -0.2)),
        ],
      ),
    );
  }

  // ---------- Delivery ----------
  Widget _deliveryOptions() {
    Widget option(int index, String title, String eta, String price) {
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
                  color: sel ? _crimson : _border, width: sel ? 1.6 : 1),
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
                        color: sel ? _crimson : _muted),
                    const Spacer(),
                    Text(price,
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: price == 'FREE' ? _green : _ink)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
                const SizedBox(height: 2),
                Text(eta,
                    style: const TextStyle(fontSize: 12, color: _muted)),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        option(0, 'Standard', '3–5 days',
            _subtotal >= 999 ? 'FREE' : _money(49)),
        const SizedBox(width: 12),
        option(1, 'Express', 'Arrives today', _money(99)),
      ],
    );
  }

  // ---------- Payment ----------
  Widget _paymentList() {
    final methods = [
      ('UPI', Icons.account_balance_wallet_outlined, 'Pay using any UPI app'),
      ('Card', Icons.credit_card_rounded, 'Credit or debit card'),
      ('Net banking', Icons.account_balance_outlined, 'All major banks'),
      ('Cash on delivery', Icons.payments_outlined, 'Pay when you receive'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < methods.length; i++) ...[
            InkWell(
              onTap: () => setState(() => _payment = methods[i].$1),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(i == 0 ? 14 : 0),
                bottom: Radius.circular(i == methods.length - 1 ? 14 : 0),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(methods[i].$2,
                        size: 22,
                        color: _payment == methods[i].$1 ? _crimson : _muted),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(methods[i].$1,
                              style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: _ink)),
                          const SizedBox(height: 2),
                          Text(methods[i].$3,
                              style: const TextStyle(
                                  fontSize: 12.5, color: _muted)),
                        ],
                      ),
                    ),
                    Icon(
                      _payment == methods[i].$1
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      size: 22,
                      color: _payment == methods[i].$1
                          ? _crimson
                          : const Color(0xFFC4C8D0),
                    ),
                  ],
                ),
              ),
            ),
            if (i != methods.length - 1)
              const Divider(height: 1, color: _border, indent: 52),
          ],
        ],
      ),
    );
  }

  // ---------- Promo ----------
  Widget _promoField() {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c, width: w),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoController,
                textCapitalization: TextCapitalization.characters,
                cursorColor: _crimson,
                style: const TextStyle(fontSize: 15, color: _ink),
                decoration: InputDecoration(
                  hintText: 'Enter code (try SAVE10)',
                  hintStyle:
                      const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                  prefixIcon: const Icon(Icons.local_offer_outlined,
                      size: 20, color: _muted),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                  border: b(_border),
                  enabledBorder: b(_border),
                  focusedBorder: b(_crimson, 1.6),
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
              const Icon(Icons.check_circle_rounded, size: 16, color: _green),
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
              style: const TextStyle(fontSize: 13, color: Color(0xFFD92D20))),
        ],
      ],
    );
  }

  // ---------- Bill ----------
  Widget _billCard() {
    Widget row(String l, String v, {Color? color, String? sub}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Text(l, style: const TextStyle(fontSize: 14, color: _muted)),
              if (sub != null) ...[
                const SizedBox(width: 8),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
              const Spacer(),
              Text(v,
                  style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: color ?? _ink)),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          for (final e in _grouped.entries)
            row(e.key, _money(_catTotal(e.value)),
                sub: '${_catCount(e.value)} items'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: _border),
          ),
          row('Subtotal', _money(_subtotal)),
          if (_promoApplied)
            row('Discount (SAVE10)', '- ${_money(_discount)}', color: _green),
          row('Delivery', _deliveryFee == 0 ? 'FREE' : _money(_deliveryFee),
              color: _deliveryFee == 0 ? _green : null),
          row('GST (18%)', _money(_tax)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
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
              Text(_money(_total),
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _crimson,
                      letterSpacing: -0.5)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Floating pay pill ----------
  Widget _payPill() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 8, 8, 8),
      decoration: BoxDecoration(
        color: _ink,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_count items • $_payment',
                  style:
                      const TextStyle(fontSize: 11.5, color: Colors.white60)),
              const SizedBox(height: 2),
              Text(_money(_total),
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.4)),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _loading ? null : _pay,
              style: FilledButton.styleFrom(
                backgroundColor: _crimson,
                disabledBackgroundColor: _crimson.withOpacity(0.6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Pay now',
                            style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 19),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky header for each category section.
class _CategoryHeader extends StatelessWidget {
  final String title;
  final int count;
  final String amount;

  const _CategoryHeader({
    required this.title,
    required this.count,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFFBF3F4),
        border: Border(
          top: BorderSide(color: Color(0xFFE2E4E9)),
          bottom: BorderSide(color: Color(0xFFE2E4E9)),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 8,
            width: 8,
            decoration: const BoxDecoration(
                color: Color(0xFF9E1B32), shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF14161A),
                  letterSpacing: 1)),
          const SizedBox(width: 10),
          Text('$count ${count == 1 ? 'item' : 'items'}',
              style:
                  const TextStyle(fontSize: 12.5, color: Color(0xFF6B7280))),
          const Spacer(),
          Text(amount,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF9E1B32))),
        ],
      ),
    );
  }
}