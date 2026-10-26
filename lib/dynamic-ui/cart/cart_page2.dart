import 'package:flutter/material.dart';

// ─── Theme ────────────────────────────────────────────────────────────────

abstract final class _C {
  static const accent = Color(0xFFE53935);
  static const ink = Color(0xFF1C1C1E);
  static const muted = Color(0xFF8E8E93);
  static const surface = Color(0xFFF5F5F7);
  static const radius = 16.0;
}

// ─── Model ────────────────────────────────────────────────────────────────

class CartItem {
  CartItem({
    required this.name,
    required this.variant,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  final String name;
  final String variant;
  final double price;
  final String imageUrl;
  int quantity;

  double get total => price * quantity;
}

String _money(double v) => '\$${v.toStringAsFixed(2)}';

// ─── Page ─────────────────────────────────────────────────────────────────

class CartPage2 extends StatefulWidget {
  const CartPage2({super.key});

  @override
  State<CartPage2> createState() => _CartPage2State();
}

class _CartPage2State extends State<CartPage2> {
  static const _shippingFee = 6.0;

  final List<CartItem> _items = [
    CartItem(
      name: 'Air Runner Sneakers',
      variant: 'Size 9 · Crimson',
      price: 89.99,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500',
    ),
    CartItem(
      name: 'Classic Chrono Watch',
      variant: 'Black · 44mm',
      price: 149.00,
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500',
    ),
    CartItem(
      name: 'Urban Daypack',
      variant: 'Slate · 25L',
      price: 59.50,
      imageUrl:
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500',
    ),
  ];

  double get _subtotal => _items.fold(0, (sum, i) => sum + i.total);
  double get _shipping => _subtotal > 200 ? 0 : _shippingFee;
  double get _total => _subtotal + _shipping;

  void _changeQuantity(CartItem item, int delta) {
    final next = item.quantity + delta;
    if (next < 1) return;
    setState(() => item.quantity = next);
  }

  void _remove(CartItem item) => setState(() => _items.remove(item));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: _C.ink,
        title: const Text(
          'Cart',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: _items.isEmpty
          ? const _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: _C.surface),
                    itemBuilder: (_, i) {
                      final item = _items[i];
                      return _CartTile(
                        item: item,
                        onIncrement: () => _changeQuantity(item, 1),
                        onDecrement: () => _changeQuantity(item, -1),
                        onRemove: () => _remove(item),
                      );
                    },
                  ),
                ),
                _CheckoutPanel(
                  subtotal: _subtotal,
                  shipping: _shipping,
                  total: _total,
                  onCheckout: () {},
                ),
              ],
            ),
    );
  }
}

// ─── Cart tile ────────────────────────────────────────────────────────────

class _CartTile extends StatelessWidget {
  const _CartTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _ProductImage(url: item.imageUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _C.ink,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: _C.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.variant,
                  style: const TextStyle(fontSize: 13, color: _C.muted),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _money(item.total),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.ink,
                      ),
                    ),
                    _QuantityStepper(
                      quantity: item.quantity,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
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
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});

  final String url;
  static const double _size = 84;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_C.radius),
      child: Image.network(
        url,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : const _ImagePlaceholder(loading: true),
        errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.loading = false});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _ProductImage._size,
      height: _ProductImage._size,
      color: _C.surface,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _C.accent,
              ),
            )
          : const Icon(Icons.image_not_supported_outlined, color: _C.muted),
    );
  }
}

// ─── Quantity stepper ─────────────────────────────────────────────────────

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(_C.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: Icons.remove_rounded, onTap: onDecrement),
          SizedBox(
            width: 24,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _C.ink,
              ),
            ),
          ),
          _StepButton(icon: Icons.add_rounded, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(_C.radius),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 16, color: _C.ink),
      ),
    );
  }
}

// ─── Checkout panel ───────────────────────────────────────────────────────

class _CheckoutPanel extends StatelessWidget {
  const _CheckoutPanel({
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.onCheckout,
  });

  final double subtotal;
  final double shipping;
  final double total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: const BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryRow(label: 'Subtotal', value: _money(subtotal)),
            const SizedBox(height: 10),
            _SummaryRow(
              label: 'Shipping',
              value: shipping == 0 ? 'Free' : _money(shipping),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: Color(0xFFE0E0E3)),
            ),
            _SummaryRow(label: 'Total', value: _money(total), emphasized: true),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: onCheckout,
                style: FilledButton.styleFrom(
                  backgroundColor: _C.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_C.radius),
                  ),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: emphasized ? 16 : 14,
      fontWeight: emphasized ? FontWeight.w700 : FontWeight.w400,
      color: emphasized ? _C.ink : _C.muted,
    );
    final valueStyle = TextStyle(
      fontSize: emphasized ? 20 : 14,
      fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
      color: _C.ink,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 56, color: _C.muted),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _C.ink,
            ),
          ),
        ],
      ),
    );
  }
}
