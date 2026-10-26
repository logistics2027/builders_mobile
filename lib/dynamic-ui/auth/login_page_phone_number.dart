import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPagePhoneNumber extends StatefulWidget {
  const LoginPagePhoneNumber({super.key});

  @override
  State<LoginPagePhoneNumber> createState() => _LoginPagePhoneNumberState();
}

class _Country {
  final String flag;
  final String name;
  final String dial;
  const _Country(this.flag, this.name, this.dial);
}

class _LoginPagePhoneNumberState extends State<LoginPagePhoneNumber> {
  // Palette (same as the email login page)
  static const _crimson = Color(0xFF9E1B32);
  static const _ink = Color(0xFF14161A);
  static const _muted = Color(0xFF6B7280);
  static const _border = Color(0xFFE2E4E9);
  static const _bg = Color(0xFFFAFAFB);

  static const _countries = [
    _Country('🇮🇳', 'India', '+91'),
    _Country('🇺🇸', 'United States', '+1'),
    _Country('🇬🇧', 'United Kingdom', '+44'),
    _Country('🇦🇪', 'United Arab Emirates', '+971'),
    _Country('🇨🇦', 'Canada', '+1'),
    _Country('🇦🇺', 'Australia', '+61'),
    _Country('🇸🇬', 'Singapore', '+65'),
    _Country('🇩🇪', 'Germany', '+49'),
    _Country('🇫🇷', 'France', '+33'),
  ];

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  _Country _country = _countries.first;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // TODO: send OTP to '${_country.dial}${_phoneController.text}'
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
  }

  void _pickCountry() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          itemCount: _countries.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: _border, indent: 16, endIndent: 16),
          itemBuilder: (_, i) {
            final c = _countries[i];
            final selected = c.name == _country.name;
            return ListTile(
              leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
              title: Text(c.name,
                  style: const TextStyle(
                      fontSize: 15, color: _ink, fontWeight: FontWeight.w500)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.dial,
                      style: const TextStyle(fontSize: 14, color: _muted)),
                  if (selected) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.check, size: 18, color: _crimson),
                  ],
                ],
              ),
              onTap: () {
                setState(() => _country = c);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return Row(
            children: [
              if (wide) const Expanded(flex: 5, child: _BrandPanel()),
              Expanded(
                flex: 4,
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 32),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _buildForm(showLogo: !wide),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForm({required bool showLogo}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLogo) ...[
            const _LogoMark(color: _crimson, textColor: _ink),
            const SizedBox(height: 48),
          ],
          const Text(
            'Sign in with phone',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: _ink,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "We'll text you a verification code to confirm it's you.",
            style: TextStyle(fontSize: 14.5, color: _muted, height: 1.4),
          ),
          const SizedBox(height: 36),

          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Phone number',
                style: TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600, color: _ink)),
          ),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            onFieldSubmitted: (_) => _submit(),
            style: const TextStyle(
                fontSize: 15, color: _ink, letterSpacing: 0.4),
            decoration: _decoration(hint: 'Enter phone number').copyWith(
              prefixIcon: _countryButton(),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Phone number is required';
              }
              if (v.length < 6 || v.length > 15) {
                return 'Enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: _crimson,
                disabledBackgroundColor: _crimson.withOpacity(0.7),
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
                  : const Text('Continue',
                      style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2)),
            ),
          ),
          const SizedBox(height: 28),

          Row(
            children: const [
              Expanded(child: Divider(color: _border)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text('OR',
                    style: TextStyle(
                        fontSize: 11.5,
                        color: _muted,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600)),
              ),
              Expanded(child: Divider(color: _border)),
            ],
          ),
          const SizedBox(height: 28),

          // Google
          _SocialButton(
            label: 'Continue with Google',
            icon: const Text(
              'G',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF4285F4), // swap for the official Google logo asset
              ),
            ),
            background: Colors.white,
            foreground: _ink,
            borderColor: _border,
            onPressed: () {
              // TODO: Google sign-in
            },
          ),
          const SizedBox(height: 14),

          // Apple
          _SocialButton(
            label: 'Continue with Apple',
            icon: const Icon(Icons.apple, size: 23, color: Colors.white),
            background: _ink,
            foreground: Colors.white,
            borderColor: _ink,
            onPressed: () {
              // TODO: Apple sign-in
            },
          ),
          const SizedBox(height: 36),

          Center(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                    fontSize: 12.5, color: _muted, height: 1.5),
                children: const [
                  TextSpan(text: 'By continuing, you agree to our '),
                  TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                          color: _ink, fontWeight: FontWeight.w600)),
                  TextSpan(text: ' and '),
                  TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                          color: _ink, fontWeight: FontWeight.w600)),
                  TextSpan(text: '.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _countryButton() {
    return InkWell(
      onTap: _pickCountry,
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
      child: Container(
        padding: const EdgeInsets.only(left: 14, right: 10),
        margin: const EdgeInsets.only(right: 4),
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: _border)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_country.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(_country.dial,
                style: const TextStyle(
                    fontSize: 15, color: _ink, fontWeight: FontWeight.w500)),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 20, color: _muted),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration({required String hint}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c, width: w),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border(_border),
      enabledBorder: border(_border),
      focusedBorder: border(_crimson, 1.6),
      errorBorder: border(const Color(0xFFD92D20)),
      focusedErrorBorder: border(const Color(0xFFD92D20), 1.6),
      errorStyle: const TextStyle(fontSize: 12.5),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final Color background;
  final Color foreground;
  final Color borderColor;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          side: BorderSide(color: borderColor),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 24, child: Center(child: icon)),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: foreground)),
          ],
        ),
      ),
    );
  }
}

/// Left brand panel shown on wide screens.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF16090C), Color(0xFF3A0D18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(right: -140, bottom: -140, child: _ring(420, 0.06)),
          Positioned(right: -60, bottom: -60, child: _ring(260, 0.08)),
          Padding(
            padding: const EdgeInsets.all(56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _LogoMark(color: Color(0xFFC8243F), textColor: Colors.white),
                Spacer(),
                Text(
                  'Secure access to\neverything you manage.',
                  style: TextStyle(
                    fontSize: 38,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  'Enterprise-grade security and a workspace\nbuilt for focus.',
                  style: TextStyle(
                      fontSize: 15.5, height: 1.5, color: Colors.white60),
                ),
                SizedBox(height: 40),
                Text(
                  '© 2026 Your Company',
                  style: TextStyle(fontSize: 12.5, color: Colors.white38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ring(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.all(color: Colors.white.withOpacity(opacity), width: 1),
        ),
      );
}

class _LogoMark extends StatelessWidget {
  final Color color;
  final Color textColor;
  const _LogoMark({required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.hexagon_outlined,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          'Brand',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}