import 'package:flutter/material.dart';

enum _Status { processing, shipped, delivered, cancelled }

class _OItem {
  final String name;
  final String category;
  final double price;
  final int qty;
  const _OItem(this.name, this.category, this.price, this.qty);
  double get total => price * qty;
}

class _Order {
  final String id;
  final String date;
  final _Status status;
  final String eta;
  final double deliveryFee;
  final List<_OItem> items;
  const _Order({
    required this.id,
    required this.date,
    required this.status,
    required this.eta,
    required this.deliveryFee,
    required this.items,
  });

  double get subtotal => items.fold(0, (s, i) => s + i.total);
  double get tax => subtotal * 0.18;
  double get total => subtotal + deliveryFee + tax;
  int get count => items.fold(0, (s, i) => s + i.qty);

  Map<String, List<_OItem>> get grouped {
    final m = <String, List<_OItem>>{};
    for (final i in items) {
      m.putIfAbsent(i.category, () => []).add(i);
    }
    return m;
  }
}

// Palette (same theme)
const _crimson = Color(0xFF9E1B32);
const _ink = Color(0xFF14161A);
const _muted = Color(0xFF6B7280);
const _border = Color(0xFFE2E4E9);
const _bg = Color(0xFFFAFAFB);
const _green = Color(0xFF16803C);
const _amber = Color(0xFFB45309);
const _blue = Color(0xFF1D4ED8);
const _currency = '₹';

String _money(double v) {
  final p = v.toStringAsFixed(2).split('.');
  final whole =
      p[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '$_currency$whole.${p[1]}';
}

class OrderPage1 extends StatefulWidget {
  const OrderPage1({super.key});

  @override
  State<OrderPage1> createState() => _OrderPage1State();
}

class _OrderPage1State extends State<OrderPage1> {
  // Demo data: replace with your orders
  final List<_Order> _orders = const [
    _Order(
      id: 'ORD-10248',
      date: '24 Oct 2026',
      status: _Status.shipped,
      eta: 'Arriving tomorrow',
      deliveryFee: 0,
      items: [
        _OItem('Wireless Headphones', 'Electronics', 7999, 1),
        _OItem('Fast Charging Cable (2m)', 'Electronics', 499, 2),
        _OItem('Cotton Crew Neck T-Shirt', 'Fashion', 899, 2),
      ],
    ),
    _Order(
      id: 'ORD-10231',
      date: '22 Oct 2026',
      status: _Status.processing,
      eta: 'Arriving in 3–5 days',
      deliveryFee: 49,
      items: [
        _OItem('Steel Water Bottle', 'Home & Kitchen', 649, 1),
      ],
    ),
    _Order(
      id: 'ORD-10174',
      date: '12 Oct 2026',
      status: _Status.delivered,
      eta: 'Delivered on 15 Oct',
      deliveryFee: 0,
      items: [
        _OItem('Denim Jacket', 'Fashion', 2499, 1),
        _OItem('Running Shoes', 'Fashion', 3299, 1),
        _OItem('Non-stick Pan', 'Home & Kitchen', 1199, 1),
      ],
    ),
    _Order(
      id: 'ORD-10102',
      date: '02 Oct 2026',
      status: _Status.cancelled,
      eta: 'Cancelled by you',
      deliveryFee: 0,
      items: [
        _OItem('Bluetooth Speaker', 'Electronics', 2999, 1),
      ],
    ),
  ];

  static const _tabs = ['All', 'Active', 'Delivered', 'Cancelled'];
  int _tab = 0;

  List<_Order> get _filtered {
    switch (_tab) {
      case 1:
        return _orders
            .where((o) =>
                o.status == _Status.processing || o.status == _Status.shipped)
            .toList();
      case 2:
        return _orders.where((o) => o.status == _Status.delivered).toList();
      case 3:
        return _orders.where((o) => o.status == _Status.cancelled).toList();
      default:
        return _orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: _ink),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('My orders',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _ink,
                letterSpacing: -0.3)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: _ink),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _border),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              _tabBar(),
              Expanded(
                child: list.isEmpty
                    ? _empty()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                        itemCount: list.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 16),
                        itemBuilder: (_, i) =>
                            _OrderCard(key: ValueKey(list[i].id), order: list[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabBar() {
    int countFor(int i) {
      switch (i) {
        case 1:
          return _orders
              .where((o) =>
                  o.status == _Status.processing ||
                  o.status == _Status.shipped)
              .length;
        case 2:
          return _orders.where((o) => o.status == _Status.delivered).length;
        case 3:
          return _orders.where((o) => o.status == _Status.cancelled).length;
        default:
          return _orders.length;
      }
    }

    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final sel = _tab == i;
          return GestureDetector(
            onTap: () => setState(() => _tab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? _crimson : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sel ? _crimson : _border),
              ),
              child: Row(
                children: [
                  Text(_tabs[i],
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : _ink)),
                  const SizedBox(width: 8),
                  Text('${countFor(i)}',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white70 : _muted)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: _crimson.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  size: 32, color: _crimson),
            ),
            const SizedBox(height: 16),
            const Text('No orders here',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
            const SizedBox(height: 4),
            const Text('Orders in this tab will show up here.',
                style: TextStyle(fontSize: 13.5, color: _muted)),
          ],
        ),
      );
}

class _OrderCard extends StatefulWidget {
  final _Order order;
  const _OrderCard({super.key, required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _open = false;

  _Order get o => widget.order;

  Color get _statusColor {
    switch (o.status) {
      case _Status.processing:
        return _amber;
      case _Status.shipped:
        return _blue;
      case _Status.delivered:
        return _green;
      case _Status.cancelled:
        return _muted;
    }
  }

  String get _statusLabel {
    switch (o.status) {
      case _Status.processing:
        return 'Processing';
      case _Status.shipped:
        return 'Shipped';
      case _Status.delivered:
        return 'Delivered';
      case _Status.cancelled:
        return 'Cancelled';
    }
  }

  IconData get _statusIcon {
    switch (o.status) {
      case _Status.processing:
        return Icons.hourglass_bottom_rounded;
      case _Status.shipped:
        return Icons.local_shipping_outlined;
      case _Status.delivered:
        return Icons.check_circle_outline_rounded;
      case _Status.cancelled:
        return Icons.cancel_outlined;
    }
  }

  bool get _active =>
      o.status == _Status.processing || o.status == _Status.shipped;

  @override
  Widget build(BuildContext context) {
    final groups = o.grouped;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: id, date, status
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#${o.id}',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                              letterSpacing: -0.2)),
                      const SizedBox(height: 3),
                      Text('${o.date}  •  ${o.count} items',
                          style:
                              const TextStyle(fontSize: 12.5, color: _muted)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, size: 14, color: _statusColor),
                      const SizedBox(width: 5),
                      Text(_statusLabel,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _statusColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _border),

          // Category amounts
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Column(
              children: [
                for (final e in groups.entries) _categoryRow(e.key, e.value),
              ],
            ),
          ),

          // Expanded details
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        for (final e in groups.entries) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 6),
                            child: Text(e.key.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: _crimson,
                                    letterSpacing: 1)),
                          ),
                          for (final it in e.value) _itemLine(it),
                        ],
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: _border),
                        const SizedBox(height: 8),
                        _line('Subtotal', _money(o.subtotal)),
                        _line('Delivery',
                            o.deliveryFee == 0 ? 'FREE' : _money(o.deliveryFee),
                            color: o.deliveryFee == 0 ? _green : null),
                        _line('GST (18%)', _money(o.tax)),
                        if (_active) ...[
                          const SizedBox(height: 14),
                          _tracker(),
                        ],
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),

          // Total row
          Container(
            margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: _crimson.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text('Order total',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
                const Spacer(),
                Text(_money(o.total),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _crimson,
                        letterSpacing: -0.3)),
              ],
            ),
          ),

          // ETA + toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
            child: Row(
              children: [
                Icon(_statusIcon, size: 16, color: _statusColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(o.eta,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _ink)),
                ),
                TextButton(
                  onPressed: () => setState(() => _open = !_open),
                  style: TextButton.styleFrom(
                    foregroundColor: _crimson,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 34),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_open ? 'Hide details' : 'View details',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      Icon(
                          _open
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Row(
              children: [
                Expanded(child: _primaryAction()),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _ink,
                        side: const BorderSide(color: _border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                          o.status == _Status.delivered ? 'Invoice' : 'Help',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryAction() {
    final label = _active ? 'Track order' : 'Reorder';
    final icon = _active ? Icons.near_me_outlined : Icons.replay_rounded;
    return SizedBox(
      height: 44,
      child: FilledButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 18),
        label: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        style: FilledButton.styleFrom(
          backgroundColor: _crimson,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _categoryRow(String category, List<_OItem> items) {
    final count = items.fold<int>(0, (s, i) => s + i.qty);
    final amount = items.fold<double>(0, (s, i) => s + i.total);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            height: 8,
            width: 8,
            decoration: const BoxDecoration(
                color: _crimson, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(category,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: _ink)),
          const SizedBox(width: 8),
          Text('$count ${count == 1 ? 'item' : 'items'}',
              style: const TextStyle(fontSize: 12.5, color: _muted)),
          const Spacer(),
          Text(_money(amount),
              style: const TextStyle(
                  fontSize: 14.5, fontWeight: FontWeight.w700, color: _ink)),
        ],
      ),
    );
  }

  Widget _itemLine(_OItem it) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(it.name,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: _ink)),
                  const SizedBox(height: 2),
                  Text('${_money(it.price)} × ${it.qty}',
                      style: const TextStyle(fontSize: 12, color: _muted)),
                ],
              ),
            ),
            Text(_money(it.total),
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _ink)),
          ],
        ),
      );

  Widget _line(String l, String v, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(l, style: const TextStyle(fontSize: 13.5, color: _muted)),
            const Spacer(),
            Text(v,
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: color ?? _ink)),
          ],
        ),
      );

  // 4-step timeline: Placed → Packed → Shipped → Delivered
  Widget _tracker() {
    const labels = ['Placed', 'Packed', 'Shipped', 'Delivered'];
    final current = o.status == _Status.processing ? 1 : 2;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final done = i <= current;
          final isCurrent = i == current;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == 0
                            ? Colors.transparent
                            : (i <= current ? _crimson : _border),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? _crimson : Colors.white,
                        border: Border.all(
                            color: done ? _crimson : _border, width: 1.5),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                    color: _crimson.withOpacity(0.25),
                                    blurRadius: 0,
                                    spreadRadius: 4)
                              ]
                            : null,
                      ),
                      child: done
                          ? const Icon(Icons.check,
                              size: 12, color: Colors.white)
                          : null,
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == labels.length - 1
                            ? Colors.transparent
                            : (i < current ? _crimson : _border),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(labels[i],
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: done ? _ink : _muted)),
              ],
            ),
          );
        }),
      ),
    );
  }
}