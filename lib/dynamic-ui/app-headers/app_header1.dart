import 'package:flutter/material.dart';

class AppHeader1 extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final int notificationCount;
  final String userInitials;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationsTap;
  final ValueChanged<String>? onMenuSelected;

  const AppHeader1({
    super.key,
    this.title = 'Dashboard',
    this.subtitle,
    this.notificationCount = 0,
    this.userInitials = 'JD',
    this.onSearchTap,
    this.onNotificationsTap,
    this.onMenuSelected,
  });

  // Palette (same as the login pages)
  static const _crimson = Color(0xFF9E1B32);
  static const _ink = Color(0xFF14161A);
  static const _muted = Color(0xFF6B7280);
  static const _border = Color(0xFFE2E4E9);

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _border)),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: preferredSize.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Logo
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: _crimson,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Replace with your logo: Image.asset('assets/logo.png')
                    child: const Icon(Icons.hexagon_outlined,
                        color: Colors.white, size: 21),
                  ),
                  const SizedBox(width: 14),

                  // Title + optional subtitle
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                            letterSpacing: -0.4,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12.5, color: _muted),
                          ),
                      ],
                    ),
                  ),

                  // Actions
                  _HeaderIconButton(
                    icon: Icons.search_rounded,
                    tooltip: 'Search',
                    onTap: onSearchTap,
                  ),
                  const SizedBox(width: 8),
                  _HeaderIconButton(
                    icon: Icons.notifications_none_rounded,
                    tooltip: 'Notifications',
                    badgeCount: notificationCount,
                    onTap: onNotificationsTap,
                  ),
                  const SizedBox(width: 14),
                  Container(width: 1, height: 26, color: _border),
                  const SizedBox(width: 14),
                  _ProfileMenu(
                    initials: userInitials,
                    onSelected: onMenuSelected,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final int badgeCount;
  final VoidCallback? onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    this.badgeCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppHeader1._border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 21, color: AppHeader1._ink),
              if (badgeCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: BoxDecoration(
                      color: AppHeader1._crimson,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  final String initials;
  final ValueChanged<String>? onSelected;

  const _ProfileMenu({required this.initials, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 52),
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppHeader1._border),
      ),
      onSelected: onSelected,
      itemBuilder: (_) => [
        _item('profile', Icons.person_outline_rounded, 'My profile'),
        _item('settings', Icons.settings_outlined, 'Settings'),
        _item('help', Icons.help_outline_rounded, 'Help & support'),
        const PopupMenuDivider(height: 8),
        _item('logout', Icons.logout_rounded, 'Sign out',
            color: AppHeader1._crimson),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 38,
            width: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFB8243D), Color(0xFF7A1226)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded,
              size: 20, color: AppHeader1._muted),
        ],
      ),
    );
  }

  PopupMenuItem<String> _item(String value, IconData icon, String label,
      {Color color = AppHeader1._ink}) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }
}