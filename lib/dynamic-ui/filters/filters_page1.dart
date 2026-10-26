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

// ───────────────────────── Model ─────────────────────────

enum SortOption {
  relevance('Relevance', Icons.auto_awesome_rounded),
  priceLow('Price: Low to High', Icons.trending_up_rounded),
  priceHigh('Price: High to Low', Icons.trending_down_rounded),
  newest('Newest first', Icons.new_releases_outlined),
  rating('Top rated', Icons.star_rounded);

  final String label;
  final IconData icon;
  const SortOption(this.label, this.icon);
}

/// Returned from FilterPage1 via Navigator.pop when the user applies filters.
class ProductFilter {
  static const double minPrice = 0;
  static const double maxPrice = 50000;

  final SortOption sort;
  final Set<String> categories;
  final Set<String> brands;
  final Set<String> colors;
  final RangeValues price;
  final double minRating; // 0 = any
  final bool inStockOnly;
  final bool onSaleOnly;
  final bool freeDelivery;

  const ProductFilter({
    this.sort = SortOption.relevance,
    this.categories = const {},
    this.brands = const {},
    this.colors = const {},
    this.price = const RangeValues(minPrice, maxPrice),
    this.minRating = 0,
    this.inStockOnly = false,
    this.onSaleOnly = false,
    this.freeDelivery = false,
  });

  bool get priceChanged => price.start > minPrice || price.end < maxPrice;

  int get activeCount =>
      (sort != SortOption.relevance ? 1 : 0) +
      categories.length +
      brands.length +
      colors.length +
      (priceChanged ? 1 : 0) +
      (minRating > 0 ? 1 : 0) +
      (inStockOnly ? 1 : 0) +
      (onSaleOnly ? 1 : 0) +
      (freeDelivery ? 1 : 0);

  ProductFilter copyWith({
    SortOption? sort,
    Set<String>? categories,
    Set<String>? brands,
    Set<String>? colors,
    RangeValues? price,
    double? minRating,
    bool? inStockOnly,
    bool? onSaleOnly,
    bool? freeDelivery,
  }) {
    return ProductFilter(
      sort: sort ?? this.sort,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      colors: colors ?? this.colors,
      price: price ?? this.price,
      minRating: minRating ?? this.minRating,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      onSaleOnly: onSaleOnly ?? this.onSaleOnly,
      freeDelivery: freeDelivery ?? this.freeDelivery,
    );
  }
}

// ───────────────────────── Static options ─────────────────────────
// Replace these with data from your API / product catalogue.

class _Cat {
  final String name;
  final IconData icon;
  const _Cat(this.name, this.icon);
}

const _categoryOptions = [
  _Cat('Electronics', Icons.devices_rounded),
  _Cat('Fashion', Icons.checkroom_rounded),
  _Cat('Home', Icons.chair_alt_rounded),
  _Cat('Beauty', Icons.spa_outlined),
  _Cat('Sports', Icons.sports_basketball_rounded),
  _Cat('Books', Icons.menu_book_rounded),
];

const _brandOptions = [
  'Apple',
  'Samsung',
  'Sony',
  'Nike',
  'Puma',
  'Boat',
  'Philips',
  'Levi\'s',
];

class _Swatch {
  final String name;
  final Color color;
  const _Swatch(this.name, this.color);
}

const _colorOptions = [
  _Swatch('Black', Color(0xFF14161A)),
  _Swatch('White', Color(0xFFFFFFFF)),
  _Swatch('Crimson', Color(0xFF9E1B32)),
  _Swatch('Blue', Color(0xFF1D4ED8)),
  _Swatch('Green', Color(0xFF16803C)),
  _Swatch('Amber', Color(0xFFB45309)),
  _Swatch('Grey', Color(0xFF9CA3AF)),
];

const _pricePresets = [
  RangeValues(0, 1000),
  RangeValues(1000, 5000),
  RangeValues(5000, 15000),
  RangeValues(15000, 50000),
];

String _money(double v) {
  final s = v.round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final left = s.length - i;
    b.write(s[i]);
    if (left > 1 && left % 3 == 1) b.write(',');
  }
  return '$_currency${b.toString()}';
}

// ───────────────────────── Page ─────────────────────────

class FilterPage1 extends StatefulWidget {
  /// Filters currently applied (so the page opens pre-filled).
  final ProductFilter initial;

  /// Optional live result count for the apply button.
  /// Hook this to your product list / API: `(f) => products.where(...).length`.
  final int Function(ProductFilter filter)? resultCount;

  const FilterPage1({
    super.key,
    this.initial = const ProductFilter(),
    this.resultCount,
  });

  @override
  State<FilterPage1> createState() => _FilterPage1State();
}

class _FilterPage1State extends State<FilterPage1> {
  late ProductFilter _f = widget.initial;

  void _update(ProductFilter f) => setState(() => _f = f);

  Set<String> _toggle(Set<String> set, String v) {
    final next = {...set};
    next.contains(v) ? next.remove(v) : next.add(v);
    return next;
  }

  void _reset() => setState(() => _f = const ProductFilter());

  void _apply() => Navigator.pop(context, _f);

  @override
  Widget build(BuildContext context) {
    final count = widget.resultCount?.call(_f);

    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: _ApplyBar(
        activeCount: _f.activeCount,
        resultCount: count,
        onReset: _f.activeCount == 0 ? null : _reset,
        onApply: _apply,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(activeCount: _f.activeCount, onReset: _reset),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  if (_f.activeCount > 0) _ActiveSummary(filter: _f, onChange: _update),
                  _Section(
                    title: 'Sort by',
                    child: _SortList(
                      value: _f.sort,
                      onChanged: (v) => _update(_f.copyWith(sort: v)),
                    ),
                  ),
                  _Section(
                    title: 'Category',
                    trailing: _f.categories.isEmpty
                        ? null
                        : '${_f.categories.length} selected',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final c in _categoryOptions)
                          _SelectChip(
                            label: c.name,
                            icon: c.icon,
                            selected: _f.categories.contains(c.name),
                            onTap: () => _update(_f.copyWith(
                              categories: _toggle(_f.categories, c.name),
                            )),
                          ),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Price range',
                    child: _PriceRange(
                      value: _f.price,
                      onChanged: (v) => _update(_f.copyWith(price: v)),
                    ),
                  ),
                  _Section(
                    title: 'Brand',
                    trailing:
                        _f.brands.isEmpty ? null : '${_f.brands.length} selected',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final b in _brandOptions)
                          _SelectChip(
                            label: b,
                            selected: _f.brands.contains(b),
                            onTap: () => _update(
                              _f.copyWith(brands: _toggle(_f.brands, b)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Customer rating',
                    child: _RatingPicker(
                      value: _f.minRating,
                      onChanged: (v) => _update(_f.copyWith(minRating: v)),
                    ),
                  ),
                  _Section(
                    title: 'Colour',
                    child: Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        for (final s in _colorOptions)
                          _ColorDot(
                            swatch: s,
                            selected: _f.colors.contains(s.name),
                            onTap: () => _update(
                              _f.copyWith(colors: _toggle(_f.colors, s.name)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'More options',
                    child: Column(
                      children: [
                        _ToggleRow(
                          icon: Icons.inventory_2_outlined,
                          tint: _green,
                          title: 'In stock only',
                          subtitle: 'Hide out-of-stock products',
                          value: _f.inStockOnly,
                          onChanged: (v) => _update(_f.copyWith(inStockOnly: v)),
                        ),
                        const Divider(height: 24, color: _border),
                        _ToggleRow(
                          icon: Icons.local_offer_outlined,
                          tint: _amber,
                          title: 'On sale',
                          subtitle: 'Products with a discount',
                          value: _f.onSaleOnly,
                          onChanged: (v) => _update(_f.copyWith(onSaleOnly: v)),
                        ),
                        const Divider(height: 24, color: _border),
                        _ToggleRow(
                          icon: Icons.local_shipping_outlined,
                          tint: _blue,
                          title: 'Free delivery',
                          subtitle: 'No shipping charges',
                          value: _f.freeDelivery,
                          onChanged: (v) =>
                              _update(_f.copyWith(freeDelivery: v)),
                        ),
                      ],
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
}

// ───────────────────────── Header ─────────────────────────

class _Header extends StatelessWidget {
  final int activeCount;
  final VoidCallback onReset;
  const _Header({required this.activeCount, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(side: BorderSide(color: _border)),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.maybePop(context),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(Icons.close_rounded, size: 20, color: _ink),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: _ink,
            ),
          ),
          if (activeCount > 0) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: _crimson,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$activeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          const Spacer(),
          TextButton(
            onPressed: activeCount == 0 ? null : onReset,
            style: TextButton.styleFrom(
              foregroundColor: _crimson,
              disabledForegroundColor: _muted.withAlpha(120),
            ),
            child: const Text(
              'Reset all',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Active summary ─────────────────────────

class _ActiveSummary extends StatelessWidget {
  final ProductFilter filter;
  final ValueChanged<ProductFilter> onChange;
  const _ActiveSummary({required this.filter, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final f = filter;
    final chips = <Widget>[
      if (f.sort != SortOption.relevance)
        _RemovableChip(
          label: f.sort.label,
          onRemove: () => onChange(f.copyWith(sort: SortOption.relevance)),
        ),
      for (final c in f.categories)
        _RemovableChip(
          label: c,
          onRemove: () => onChange(
            f.copyWith(categories: {...f.categories}..remove(c)),
          ),
        ),
      for (final b in f.brands)
        _RemovableChip(
          label: b,
          onRemove: () =>
              onChange(f.copyWith(brands: {...f.brands}..remove(b))),
        ),
      for (final c in f.colors)
        _RemovableChip(
          label: c,
          onRemove: () =>
              onChange(f.copyWith(colors: {...f.colors}..remove(c))),
        ),
      if (f.priceChanged)
        _RemovableChip(
          label: '${_money(f.price.start)} – ${_money(f.price.end)}',
          onRemove: () => onChange(f.copyWith(
            price: const RangeValues(
              ProductFilter.minPrice,
              ProductFilter.maxPrice,
            ),
          )),
        ),
      if (f.minRating > 0)
        _RemovableChip(
          label: '${f.minRating.toStringAsFixed(0)}★ & up',
          onRemove: () => onChange(f.copyWith(minRating: 0)),
        ),
      if (f.inStockOnly)
        _RemovableChip(
          label: 'In stock',
          onRemove: () => onChange(f.copyWith(inStockOnly: false)),
        ),
      if (f.onSaleOnly)
        _RemovableChip(
          label: 'On sale',
          onRemove: () => onChange(f.copyWith(onSaleOnly: false)),
        ),
      if (f.freeDelivery)
        _RemovableChip(
          label: 'Free delivery',
          onRemove: () => onChange(f.copyWith(freeDelivery: false)),
        ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }
}

class _RemovableChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _RemovableChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
        decoration: BoxDecoration(
          color: _crimson.withAlpha(18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _crimson.withAlpha(60)),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: _crimson,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.close_rounded, size: 16, color: _crimson),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Section wrapper ─────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final String? trailing;
  final Widget child;
  const _Section({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
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
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                const Spacer(),
                if (trailing != null)
                  Text(
                    trailing!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _crimson,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Sort ─────────────────────────

class _SortList extends StatelessWidget {
  final SortOption value;
  final ValueChanged<SortOption> onChanged;
  const _SortList({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < SortOption.values.length; i++) ...[
          _SortRow(
            option: SortOption.values[i],
            selected: SortOption.values[i] == value,
            onTap: () => onChanged(SortOption.values[i]),
          ),
          if (i != SortOption.values.length - 1)
            const Divider(height: 1, color: _border),
        ],
      ],
    );
  }
}

class _SortRow extends StatelessWidget {
  final SortOption option;
  final bool selected;
  final VoidCallback onTap;
  const _SortRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              option.icon,
              size: 20,
              color: selected ? _crimson : _muted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? _ink : _muted,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _crimson : _border,
                  width: selected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Chips ─────────────────────────

class _SelectChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _ink : _bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _ink : _border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: selected ? Colors.white : _muted),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : _ink,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check_rounded, size: 15, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Price ─────────────────────────

class _PriceRange extends StatelessWidget {
  final RangeValues value;
  final ValueChanged<RangeValues> onChanged;
  const _PriceRange({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _PriceBox(label: 'MIN', amount: value.start)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('—', style: TextStyle(color: _muted, fontSize: 18)),
            ),
            Expanded(child: _PriceBox(label: 'MAX', amount: value.end)),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: _crimson,
            inactiveTrackColor: _border,
            thumbColor: Colors.white,
            overlayColor: _crimson.withAlpha(30),
            rangeThumbShape: const _RangeThumb(),
            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
          ),
          child: RangeSlider(
            values: value,
            min: ProductFilter.minPrice,
            max: ProductFilter.maxPrice,
            divisions: 100,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_money(ProductFilter.minPrice),
                style: const TextStyle(fontSize: 11.5, color: _muted)),
            Text('${_money(ProductFilter.maxPrice)}+',
                style: const TextStyle(fontSize: 11.5, color: _muted)),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in _pricePresets)
              GestureDetector(
                onTap: () => onChanged(p),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: (value == p) ? _crimson.withAlpha(18) : _bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (value == p) ? _crimson : _border,
                    ),
                  ),
                  child: Text(
                    '${_money(p.start)} – ${_money(p.end)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: (value == p) ? _crimson : _muted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PriceBox extends StatelessWidget {
  final String label;
  final double amount;
  const _PriceBox({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w800,
              color: _muted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _money(amount),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeThumb extends RangeSliderThumbShape {
  const _RangeThumb();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(13);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center.translate(0, 2),
      13,
      Paint()..color = Colors.black.withAlpha(30),
    );
    canvas.drawCircle(center, 12, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _crimson,
    );
  }
}

// ───────────────────────── Rating ─────────────────────────

class _RatingPicker extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _RatingPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [0.0, 4.0, 3.0, 2.0];
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(options[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: value == options[i] ? _ink : _bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: value == options[i] ? _ink : _border,
                  ),
                ),
                child: Column(
                  children: [
                    if (options[i] == 0)
                      Text(
                        'Any',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: value == options[i] ? Colors.white : _ink,
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            options[i].toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color:
                                  value == options[i] ? Colors.white : _ink,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFF59E0B),
                          ),
                        ],
                      ),
                    const SizedBox(height: 2),
                    Text(
                      options[i] == 0 ? 'rating' : '& up',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: value == options[i] ? Colors.white70 : _muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (i != options.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

// ───────────────────────── Colour ─────────────────────────

class _ColorDot extends StatelessWidget {
  final _Swatch swatch;
  final bool selected;
  final VoidCallback onTap;
  const _ColorDot({
    required this.swatch,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final light = swatch.color.computeLuminance() > 0.7;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 46,
            height: 46,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? _crimson : Colors.transparent,
                width: 2,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: swatch.color,
                shape: BoxShape.circle,
                border: Border.all(color: _border),
              ),
              child: selected
                  ? Icon(
                      Icons.check_rounded,
                      size: 20,
                      color: light ? _ink : Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            swatch.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? _ink : _muted,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Toggles ─────────────────────────

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
        const SizedBox(width: 12),
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
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12.5, color: _muted),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: _crimson,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: _border,
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ],
    );
  }
}

// ───────────────────────── Bottom bar ─────────────────────────

class _ApplyBar extends StatelessWidget {
  final int activeCount;
  final int? resultCount;
  final VoidCallback? onReset;
  final VoidCallback onApply;
  const _ApplyBar({
    required this.activeCount,
    required this.resultCount,
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final empty = resultCount == 0;
    final label = resultCount == null
        ? (activeCount == 0 ? 'Show products' : 'Apply $activeCount filters')
        : empty
            ? 'No products found'
            : 'Show $resultCount products';

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
            child: OutlinedButton(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                foregroundColor: _ink,
                disabledForegroundColor: _muted.withAlpha(120),
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
              child: const Text('Clear'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: FilledButton(
              onPressed: empty ? null : onApply,
              style: FilledButton.styleFrom(
                backgroundColor: _crimson,
                disabledBackgroundColor: _border,
                foregroundColor: Colors.white,
                disabledForegroundColor: _muted,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              child: Text(label),
            ),
          ),
        ],
      ),
    );
  }
}