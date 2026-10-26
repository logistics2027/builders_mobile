import 'package:flutter/material.dart';

const _crimson = Color(0xFF9E1B32);
const _ink = Color(0xFF14161A);
const _muted = Color(0xFF6B7280);
const _border = Color(0xFFE2E4E9);
const _bg = Color(0xFFFAFAFB);
const _green = Color(0xFF16803C);
const _amber = Color(0xFFB45309);
const _blue = Color(0xFF1D4ED8);
const _currency = '₹';

// ───────────────────────── Sample data ─────────────────────────

class _Item {
  final String name;
  final String variant;
  final int qty;
  final double price;
  const _Item(this.name, this.variant, this.qty, this.price);
  double get total => qty * price;
}

class _Step {
  final String title;
  final String subtitle;
  final String time;
  final _StepState state;
  const _Step(this.title, this.subtitle, this.time, this.state);
}

enum _StepState { done, active, pending }

const _items = [
  _Item('Wireless Headphones', 'Midnight Black', 1, 4999),
  _Item('USB-C Fast Charger', '65W · White', 2, 1299),
  _Item('Leather Phone Case', 'Tan · iPhone 15', 1, 899),
];

const _steps = [
  _Step('Order placed', 'We received your order', '10:02 AM', _StepState.done),
  _Step('Packed & verified', 'Quality check passed', '10:40 AM', _StepState.done),
  _Step('Out for delivery', 'Rahul is on the way', '04:55 PM', _StepState.active),
  _Step('Delivered', 'Estimated by 06:30 PM', '—', _StepState.pending),
];

String _fmt(double v) {
  final s = v.toStringAsFixed(0);
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    buf.write(s[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1 && fromEnd > 3) buf.write(',');
  }
  return '$_currency${buf.toString()}';
}

// ───────────────────────── Page ─────────────────────────

class OrderPage2 extends StatelessWidget {
  const OrderPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final subtotal = _items.fold<double>(0, (a, b) => a + b.total);
    const delivery = 49.0;
    const discount = 300.0;
    final total = subtotal + delivery - discount;

    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: const _BottomActions(),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: _TopBar()),
            const SliverToBoxAdapter(child: _StatusHero()),
            const SliverToBoxAdapter(child: _SectionLabel('Tracking')),
            const SliverToBoxAdapter(child: _Timeline()),
            SliverToBoxAdapter(
              child: _SectionLabel('Items · ${_items.length}'),
            ),
            const SliverToBoxAdapter(child: _ItemsCard()),
            const SliverToBoxAdapter(child: _SectionLabel('Delivery & payment')),
            const SliverToBoxAdapter(child: _InfoCard()),
            const SliverToBoxAdapter(child: _SectionLabel('Receipt')),
            SliverToBoxAdapter(
              child: _Receipt(
                subtotal: subtotal,
                delivery: delivery,
                discount: discount,
                total: total,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Top bar ─────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _RoundIcon(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                    color: _muted,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '#ORD-20481',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          _RoundIcon(icon: Icons.ios_share_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: _border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 20, color: _ink),
        ),
      ),
    );
  }
}

// ───────────────────────── Hero ─────────────────────────

class _StatusHero extends StatelessWidget {
  const _StatusHero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1C1F26), _ink],
            ),
          ),
          child: Stack(
            children: [
              // decorative concentric arcs
              Positioned(
                right: -60,
                top: -60,
                child: CustomPaint(
                  size: const Size(220, 220),
                  painter: _RingsPainter(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const _Pill(
                          label: 'OUT FOR DELIVERY',
                          color: _blue,
                          onDark: true,
                        ),
                        const Spacer(),
                        Text(
                          'Sat, 24 Oct',
                          style: TextStyle(
                            color: Colors.white.withAlpha(150),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'ARRIVING IN',
                      style: TextStyle(
                        color: Colors.white.withAlpha(140),
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          '18',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 64,
                            height: 1,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'min',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const _SegmentBar(total: 4, filled: 3),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withAlpha(24)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: _crimson,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              'R',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rahul Verma',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Your delivery partner · 4.9 ★',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _HeroAction(icon: Icons.chat_bubble_outline_rounded),
                          const SizedBox(width: 8),
                          _HeroAction(icon: Icons.call_outlined),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  final IconData icon;
  const _HeroAction({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(24),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}

class _SegmentBar extends StatelessWidget {
  final int total;
  final int filled;
  const _SegmentBar({required this.total, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final on = i < filled;
        final current = i == filled - 1;
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: on ? (current ? Colors.white : _crimson) : Colors.white24,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

class _RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(
        c,
        i * 26.0,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withAlpha(14 + (4 - i) * 4),
      );
    }
    canvas.drawCircle(c, 6, Paint()..color = _crimson);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ───────────────────────── Pills & labels ─────────────────────────

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final bool onDark;
  const _Pill({required this.label, required this.color, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final fg = onDark ? Colors.white : color;
    final bg = onDark ? color.withAlpha(200) : color.withAlpha(24);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 10.5,
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: _crimson,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }
}

// ───────────────────────── Timeline ─────────────────────────

class _Timeline extends StatelessWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Column(
        children: List.generate(_steps.length, (i) {
          return _TimelineRow(step: _steps[i], isLast: i == _steps.length - 1);
        }),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final _Step step;
  final bool isLast;
  const _TimelineRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final done = step.state == _StepState.done;
    final active = step.state == _StepState.active;
    final dotColor = done ? _green : (active ? _crimson : _border);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: done ? _green : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: dotColor, width: active ? 6 : 2),
                  ),
                  child: done
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: done ? _green : _border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 12 : 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: step.state == _StepState.pending
                                ? _muted
                                : _ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          step.subtitle,
                          style: const TextStyle(fontSize: 12.5, color: _muted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    step.time,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active ? _crimson : _muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Items ─────────────────────────

class _ItemsCard extends StatelessWidget {
  const _ItemsCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _border),
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: _muted,
                              size: 24,
                            ),
                          ),
                          Positioned(
                            right: -1,
                            top: -1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: const BoxDecoration(
                                color: _crimson,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(14),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                              child: Text(
                                '×${item.qty}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.variant,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: _muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _fmt(item.total),
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                  ],
                ),
              ),
              if (i != _items.length - 1)
                const Divider(height: 1, indent: 82, color: _border),
            ],
          );
        }),
      ),
    );
  }
}

// ───────────────────────── Info ─────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return const _Card(
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.location_on_outlined,
            tint: _crimson,
            title: 'Home',
            body: '12, 4th Cross, Indiranagar,\nBengaluru, Karnataka 560038',
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: _border),
          ),
          _InfoRow(
            icon: Icons.account_balance_wallet_outlined,
            tint: _green,
            title: 'Paid via UPI',
            body: 'rahul@okbank · Payment successful',
            trailing: _Pill(label: 'PAID', color: _green),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: _border),
          ),
          _InfoRow(
            icon: Icons.verified_user_outlined,
            tint: _amber,
            title: 'Delivery OTP',
            body: 'Share this code with the partner',
            trailing: Text(
              '4 8 2 9',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String title;
  final String body;
  final Widget? trailing;
  const _InfoRow({
    required this.icon,
    required this.tint,
    required this.title,
    required this.body,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tint.withAlpha(22),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: tint),
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
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: _muted,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

// ───────────────────────── Receipt (ticket) ─────────────────────────

class _Receipt extends StatelessWidget {
  final double subtotal;
  final double delivery;
  final double discount;
  final double total;
  const _Receipt({
    required this.subtotal,
    required this.delivery,
    required this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _TicketPart(
            top: true,
            child: Column(
              children: [
                _BillRow('Subtotal', _fmt(subtotal)),
                const SizedBox(height: 10),
                _BillRow('Delivery fee', _fmt(delivery)),
                const SizedBox(height: 10),
                _BillRow('Coupon · WELCOME300', '− ${_fmt(discount)}',
                    valueColor: _green),
              ],
            ),
          ),
          _TicketPart(
            top: false,
            child: Column(
              children: [
                const _Dashed(),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL PAID',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.8,
                              fontWeight: FontWeight.w800,
                              color: _muted,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Inclusive of all taxes',
                            style: TextStyle(fontSize: 12, color: _muted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _fmt(total),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: _crimson,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _Barcode(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _BillRow(this.label, this.value, {this.valueColor = _ink});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13.5, color: _muted),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _TicketPart extends StatelessWidget {
  final bool top;
  final Widget child;
  const _TicketPart({required this.top, required this.child});

  @override
  Widget build(BuildContext context) {
    final clipper = _TicketClipper(top: top);
    return CustomPaint(
      foregroundPainter: _TicketBorder(clipper),
      child: ClipPath(
        clipper: clipper,
        child: Container(
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(18, top ? 18 : 6, 18, top ? 18 : 18),
          child: child,
        ),
      ),
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  final bool top;
  const _TicketClipper({required this.top});

  static const double r = 20; // card corner radius
  static const double n = 11; // notch radius

  @override
  Path getClip(Size s) {
    final p = Path();
    if (top) {
      p.moveTo(0, r);
      p.arcToPoint(const Offset(r, 0), radius: const Radius.circular(r));
      p.lineTo(s.width - r, 0);
      p.arcToPoint(Offset(s.width, r), radius: const Radius.circular(r));
      p.lineTo(s.width, s.height - n);
      p.arcToPoint(
        Offset(s.width, s.height),
        radius: const Radius.circular(n),
        clockwise: false,
      );
      p.lineTo(0, s.height);
      p.lineTo(0, s.height - n);
      p.arcToPoint(
        Offset(0, s.height - n * 2 + n),
        radius: const Radius.circular(n),
        clockwise: false,
      );
      p.close();
    } else {
      p.moveTo(0, 0);
      p.lineTo(s.width, 0);
      p.lineTo(s.width, n);
      p.arcToPoint(
        Offset(s.width, 0),
        radius: const Radius.circular(n),
        clockwise: false,
      );
      p.moveTo(s.width, 0);
      p.lineTo(s.width, s.height - r);
      p.arcToPoint(Offset(s.width - r, s.height),
          radius: const Radius.circular(r));
      p.lineTo(r, s.height);
      p.arcToPoint(Offset(0, s.height - r), radius: const Radius.circular(r));
      p.lineTo(0, 0);
      p.close();
    }
    return p;
  }

  @override
  bool shouldReclip(covariant _TicketClipper old) => old.top != top;
}

class _TicketBorder extends CustomPainter {
  final _TicketClipper clipper;
  _TicketBorder(this.clipper);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      clipper.getClip(size),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _border,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Dashed extends StatelessWidget {
  const _Dashed();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final count = (c.maxWidth / 9).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(width: 5, height: 1.4, color: _border),
          ),
        );
      },
    );
  }
}

class _Barcode extends StatelessWidget {
  const _Barcode();

  @override
  Widget build(BuildContext context) {
    const pattern = [2, 1, 3, 1, 2, 4, 1, 2, 1, 3, 2, 1, 4, 1, 2, 3, 1, 2, 1, 4, 2, 1, 3, 1, 2, 1, 3, 2, 1, 4, 1, 2];
    return Column(
      children: [
        SizedBox(
          height: 34,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < pattern.length; i++)
                Container(
                  width: pattern[i].toDouble(),
                  color: i.isEven ? _ink : Colors.transparent,
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'ORD 2048 1992 7731',
          style: TextStyle(
            fontSize: 10.5,
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
            color: _muted,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Bottom actions ─────────────────────────

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.headset_mic_outlined, size: 18),
              label: const Text('Help'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _ink,
                side: const BorderSide(color: _border),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.navigation_rounded, size: 18),
              label: const Text('Track live'),
              style: FilledButton.styleFrom(
                backgroundColor: _crimson,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}