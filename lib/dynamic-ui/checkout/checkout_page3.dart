import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckoutPage3 extends StatefulWidget {
  const CheckoutPage3({super.key});

  @override
  State<CheckoutPage3> createState() => _CheckoutPage3State();
}

class _Line {
  final String name;
  final String category;
  final double price;
  final int qty;
  const _Line(this.name, this.category, this.price, this.qty);
  double get total => price * qty;
}

class _CheckoutPage3State extends State<CheckoutPage3> {
  // Palette (same theme)
  static const _crimson = Color(0xFF9E1B32);
  static const _ink = Color(0xFF14161A);
  static const _muted = Color(0xFF6B7280);
  static const _border = Color(0xFFE2E4E9);
  static const _bg = Color(0xFFFAFAFB);
  static const _green = Color(0xFF16803C);
  static const _currency = '₹';

  static const _stepLabels = ['Shipping', 'Payment', 'Review'];

  // Colors used for the category share bar
  static const _categoryColors = [
    Color(0xFF9E1B32),
    Color(0xFF14161A),
    Color(0xFFD4A24C),
    Color(0xFF6B7280),
  ];

  // Demo cart: replace with your data
  final List<_Line> _items = const [
    _Line('Wireless Headphones', 'Electronics', 7999, 1),
    _Line('Fast Charging Cable (2m)', 'Electronics', 499, 2),
    _Line('Cotton Crew Neck T-Shirt', 'Fashion', 899, 2),
    _Line('Denim Jacket', 'Fashion', 2499, 1),
    _Line('Steel Water Bottle', 'Home & Kitchen', 649, 1),
  ];

  int _step = 0;
  bool _loading = false;

  // Shipping
  final _shipKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: 'John Doe');
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _pin = TextEditingController();
  int _delivery = 0; // 0 standard, 1 express

  // Payment
  final _cardKey = GlobalKey<FormState>();
  final _cardNumber = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  String _payment = 'upi';

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _address,
      _city,
      _pin,
      _cardNumber,
      _expiry,
      _cvv,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------- Calculations ----------
  double get _subtotal => _items.fold(0, (s, i) => s + i.total);
  int get _count => _items.fold(0, (s, i) => s + i.qty);
  double get _deliveryFee => _delivery == 1 ? 99 : (_subtotal >= 999 ? 0 : 49);
  double get _tax => _subtotal * 0.18;
  double get _total => _subtotal + _deliveryFee + _tax;

  Map<String, List<_Line>> get _grouped {
    final m = <String, List<_Line>>{};
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

  String get _paymentLabel => const {
    'upi': 'UPI',
    'card': 'Credit / Debit card',
    'netbanking': 'Net banking',
    'cod': 'Cash on delivery',
  }[_payment]!;

  // ---------- Navigation ----------
  Future<void> _next() async {
    if (_step == 0 && !(_shipKey.currentState?.validate() ?? false)) return;
    if (_step == 1 &&
        _payment == 'card' &&
        !(_cardKey.currentState?.validate() ?? false))
      return;

    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    setState(() => _loading = true);
    // TODO: call your payment / order API here
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _ink,
        behavior: SnackBarBehavior.floating,
        content: Text('Order placed • ${_money(_total)}'),
      ),
    );
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.maybePop(context);
    }
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: _ink,
          ),
          onPressed: _back,
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
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                'Step ${_step + 1} of 3',
                style: const TextStyle(fontSize: 13, color: _muted),
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _border),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: _progress(),
              ),
            ),
          ),
          const Divider(height: 1, color: _border),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: [
                        _shippingStep,
                        _paymentStep,
                        _reviewStep,
                      ][_step](),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  // ---------- Progress header ----------
  Widget _progress() {
    return Row(
      children: List.generate(3, (i) {
        final done = i < _step;
        final active = i == _step;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 2 ? 0 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: done || active ? _crimson : _border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (done) ...[
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 15,
                        color: _crimson,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      _stepLabels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active || done ? _ink : _muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ---------- Step 1: Shipping ----------
  Widget _shippingStep() {
    return Form(
      key: _shipKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading('Shipping details', 'Where should we deliver your order?'),
          _input(
            _name,
            'Full name',
            'John Doe',
            validator: (v) =>
                (v ?? '').trim().isEmpty ? 'Name is required' : null,
          ),
          _input(
            _phone,
            'Phone number',
            '98765 43210',
            keyboard: TextInputType.phone,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (v) =>
                (v ?? '').length != 10 ? 'Enter a 10-digit number' : null,
          ),
          _input(
            _address,
            'Address',
            'House no., street, area',
            validator: (v) =>
                (v ?? '').trim().isEmpty ? 'Address is required' : null,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _input(
                  _city,
                  'City',
                  'Bengaluru',
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _input(
                  _pin,
                  'PIN code',
                  '560001',
                  keyboard: TextInputType.number,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (v) =>
                      (v ?? '').length != 6 ? 'Enter 6 digits' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _label('Delivery speed'),
          _deliveryOption(
            0,
            'Standard delivery',
            'Arrives in 3–5 days',
            _subtotal >= 999 ? 'FREE' : _money(49),
          ),
          _deliveryOption(1, 'Express delivery', 'Arrives today', _money(99)),
        ],
      ),
    );
  }

  Widget _deliveryOption(int index, String title, String sub, String price) {
    final sel = _delivery == index;
    return GestureDetector(
      onTap: () => setState(() => _delivery = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel ? _crimson.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sel ? _crimson : _border,
            width: sel ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              index == 0 ? Icons.inventory_2_outlined : Icons.bolt_rounded,
              color: sel ? _crimson : _muted,
              size: 23,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: const TextStyle(fontSize: 12.5, color: _muted),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: price == 'FREE' ? _green : _ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Step 2: Payment ----------
  Widget _paymentStep() {
    final options = [
      (
        'upi',
        Icons.account_balance_wallet_outlined,
        'UPI',
        'Pay using any UPI app',
      ),
      (
        'card',
        Icons.credit_card_rounded,
        'Credit / Debit card',
        'Visa, Mastercard, RuPay',
      ),
      (
        'netbanking',
        Icons.account_balance_outlined,
        'Net banking',
        'All major banks',
      ),
      (
        'cod',
        Icons.payments_outlined,
        'Cash on delivery',
        'Pay when you receive',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          'Payment method',
          'All transactions are secure and encrypted.',
        ),
        ...options.map((o) {
          final sel = _payment == o.$1;
          return GestureDetector(
            onTap: () => setState(() => _payment = o.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: sel ? _crimson.withOpacity(0.04) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel ? _crimson : _border,
                  width: sel ? 1.6 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(o.$2, size: 24, color: sel ? _crimson : _muted),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          o.$3,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          o.$4,
                          style: const TextStyle(fontSize: 12.5, color: _muted),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    sel
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: sel ? _crimson : const Color(0xFFC4C8D0),
                    size: 22,
                  ),
                ],
              ),
            ),
          );
        }),
        if (_payment == 'card') ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Form(
              key: _cardKey,
              child: Column(
                children: [
                  _input(
                    _cardNumber,
                    'Card number',
                    '0000 0000 0000 0000',
                    keyboard: TextInputType.number,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      _GroupFormatter(),
                    ],
                    validator: (v) => (v ?? '').replaceAll(' ', '').length != 16
                        ? 'Enter 16 digits'
                        : null,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _input(
                          _expiry,
                          'Expiry',
                          'MM/YY',
                          keyboard: TextInputType.number,
                          formatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            _ExpiryFormatter(),
                          ],
                          validator: (v) =>
                              (v ?? '').length != 5 ? 'MM/YY' : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _input(
                          _cvv,
                          'CVV',
                          '•••',
                          keyboard: TextInputType.number,
                          obscure: true,
                          formatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          validator: (v) =>
                              (v ?? '').length < 3 ? 'Invalid' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ---------- Step 3: Review ----------
  Widget _reviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Review your order', 'Check everything before you pay.'),

        // Ship to / Pay with
        _infoRow(
          Icons.location_on_outlined,
          'Ship to',
          '${_name.text}\n${_address.text}, ${_city.text} - ${_pin.text}',
          0,
        ),
        const SizedBox(height: 10),
        _infoRow(Icons.credit_card_rounded, 'Pay with', _paymentLabel, 1),
        const SizedBox(height: 22),

        // Category breakdown
        _label('Spending by category'),
        _categoryBreakdown(),
        const SizedBox(height: 22),

        // Items per category
        _label('Items ($_count)'),
        ..._grouped.entries.map((e) => _categoryItems(e.key, e.value)),
        const SizedBox(height: 10),

        // Price details
        _label('Price details'),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              _priceRow('Subtotal', _money(_subtotal)),
              _priceRow(
                'Delivery',
                _deliveryFee == 0 ? 'FREE' : _money(_deliveryFee),
                color: _deliveryFee == 0 ? _green : null,
              ),
              _priceRow('GST (18%)', _money(_tax)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: _border),
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
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String title, String value, int editStep) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: _crimson),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12.5, color: _muted),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _step = editStep),
            style: TextButton.styleFrom(
              foregroundColor: _crimson,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 30),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryBreakdown() {
    final entries = _grouped.entries.toList();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          // Stacked share bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                for (int i = 0; i < entries.length; i++)
                  Expanded(
                    flex:
                        ((entries[i].value.fold<double>(
                                      0,
                                      (s, l) => s + l.total,
                                    ) /
                                    _subtotal) *
                                1000)
                            .round()
                            .clamp(1, 1000),
                    child: Container(
                      height: 10,
                      margin: EdgeInsets.only(
                        right: i == entries.length - 1 ? 0 : 2,
                      ),
                      color: _categoryColors[i % _categoryColors.length],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Legend with amounts
          for (int i = 0; i < entries.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Builder(
                builder: (_) {
                  final amt = entries[i].value.fold<double>(
                    0,
                    (s, l) => s + l.total,
                  );
                  final pct = (amt / _subtotal * 100).round();
                  return Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          color: _categoryColors[i % _categoryColors.length],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        entries[i].key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$pct%',
                        style: const TextStyle(fontSize: 12.5, color: _muted),
                      ),
                      const Spacer(),
                      Text(
                        _money(amt),
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _categoryItems(String category, List<_Line> items) {
    final total = items.fold<double>(0, (s, l) => s + l.total);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _crimson,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  _money(total),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          for (final l in items)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_money(l.price)} × ${l.qty}',
                          style: const TextStyle(fontSize: 12.5, color: _muted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _money(l.total),
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
    );
  }

  Widget _priceRow(String l, String v, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
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

  // ---------- Bottom bar ----------
  Widget _bottomBar() {
    final last = _step == 2;
    return Container(
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
                      Text(
                        '$_count items',
                        style: const TextStyle(fontSize: 12.5, color: _muted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _money(_total),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _loading ? null : _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: _crimson,
                          disabledBackgroundColor: _crimson.withOpacity(0.7),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (last) ...[
                                    const Icon(
                                      Icons.lock_outline_rounded,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    last ? 'Pay now' : 'Continue',
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  if (!last) ...[
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 19,
                                    ),
                                  ],
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

  // ---------- Shared bits ----------
  Widget _heading(String title, String sub) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _ink,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(sub, style: const TextStyle(fontSize: 14, color: _muted)),
      ],
    ),
  );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
    ),
  );

  Widget _input(
    TextEditingController c,
    String label,
    String hint, {
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
    bool obscure = false,
  }) {
    OutlineInputBorder b(Color col, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: col, width: w),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          TextFormField(
            controller: c,
            keyboardType: keyboard,
            inputFormatters: formatters,
            validator: validator,
            obscureText: obscure,
            cursorColor: _crimson,
            style: const TextStyle(fontSize: 15, color: _ink),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 15,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              border: b(_border),
              enabledBorder: b(_border),
              focusedBorder: b(_crimson, 1.6),
              errorBorder: b(const Color(0xFFD92D20)),
              focusedErrorBorder: b(const Color(0xFFD92D20), 1.6),
              errorStyle: const TextStyle(fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Input formatters ----------
class _GroupFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue now,
  ) {
    final digits = now.text.replaceAll(' ', '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue now,
  ) {
    final d = now.text.replaceAll('/', '');
    final text = d.length > 2 ? '${d.substring(0, 2)}/${d.substring(2)}' : d;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
