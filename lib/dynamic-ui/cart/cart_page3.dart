import 'package:flutter/material.dart';

class CartPage3 extends StatefulWidget {
  const CartPage3({super.key});

  @override
  State<CartPage3> createState() => _CartPage3State();
}

class _CartItem {
  final String name;
  final String subtitle;
  final double price;
  final IconData icon;
  int qty;

  _CartItem({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.icon,
    this.qty = 1,
  });
}

class _CartPage3State extends State<CartPage3> {
  static const Color red = Color(0xFFD32F2F);
  static const Color redLight = Color(0xFFFFEBEE);
  static const double radius = 12;

  final List<_CartItem> items = [
    _CartItem(
        name: 'Margherita Pizza',
        subtitle: 'Medium · Extra cheese',
        price: 299,
        icon: Icons.local_pizza),
    _CartItem(
        name: 'Veg Burger',
        subtitle: 'With fries',
        price: 149,
        icon: Icons.lunch_dining,
        qty: 2),
    _CartItem(
        name: 'Cold Coffee',
        subtitle: 'Large',
        price: 99,
        icon: Icons.local_cafe),
  ];

  double get subtotal =>
      items.fold(0, (sum, i) => sum + i.price * i.qty);
  double get delivery => items.isEmpty ? 0 : 30;
  double get total => subtotal + delivery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: red,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('My Cart (${items.length})',
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text('Your cart is empty',
                  style: TextStyle(color: red, fontSize: 16)))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) => _cartTile(items[i], i),
                  ),
                ),
                _summary(),
              ],
            ),
    );
  }

  Widget _cartTile(_CartItem item, int index) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: redLight,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Icon(item.icon, color: red, size: 28),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text('₹${item.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: red)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => setState(() => items.removeAt(index)),
                child: const Icon(Icons.delete_outline, color: red, size: 20),
              ),
              const SizedBox(height: 6),
              _qtyControl(item),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyControl(_CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: redLight,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyButton(Icons.remove, () {
            if (item.qty > 1) setState(() => item.qty--);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('${item.qty}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          _qtyButton(Icons.add, () => setState(() => item.qty++)),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: red),
      ),
    );
  }

  Widget _summary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _row('Subtotal', subtotal),
            const SizedBox(height: 4),
            _row('Delivery', delivery),
            const Divider(height: 12),
            _row('Total', total, bold: true),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius)),
                ),
                child: const Text('Checkout',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 16 : 13,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: bold ? red : Colors.black87,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('₹${value.toStringAsFixed(0)}', style: style),
      ],
    );
  }
}