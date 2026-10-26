import 'package:builders_mobile/dynamic-ui/app-headers/app_header1.dart';
import 'package:builders_mobile/dynamic-ui/app-headers/app_header2.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      body: Column(
        children: [
          AppHeader2(
            userName: 'John Doe',
            location: 'Bengaluru, Karnataka',
            notificationCount: 3,
            onProfileTap: () {},
            onNotificationsTap: () {},
            onFilterTap: () {},
            onSearchChanged: (q) {},
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const [Text('Your content here')],
            ),
          ),
        ],
      ),
    );
  }
}
