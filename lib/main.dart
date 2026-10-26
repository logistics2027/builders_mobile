import 'package:builders_mobile/dynamic-ui/auth/login_page_mail_password.dart';
import 'package:builders_mobile/dynamic-ui/auth/login_page_phone_number.dart';
import 'package:builders_mobile/dynamic-ui/cart/cart_page1.dart';
import 'package:builders_mobile/dynamic-ui/cart/cart_page2.dart';
import 'package:builders_mobile/dynamic-ui/cart/cart_page3.dart';
import 'package:builders_mobile/dynamic-ui/cart/cart_page4.dart';
import 'package:builders_mobile/dynamic-ui/category/category_explore_page.dart';
import 'package:builders_mobile/dynamic-ui/category/catgory_list_page.dart';
import 'package:builders_mobile/dynamic-ui/category/catgory_list_page2.dart';
import 'package:builders_mobile/dynamic-ui/category/catgory_list_page4.dart';
import 'package:builders_mobile/dynamic-ui/checkout/checkout_page1.dart';
import 'package:builders_mobile/dynamic-ui/checkout/checkout_page2.dart';
import 'package:builders_mobile/dynamic-ui/checkout/checkout_page3.dart';
import 'package:builders_mobile/dynamic-ui/checkout/checkout_page4.dart';
import 'package:builders_mobile/dynamic-ui/checkout/checkout_page5.dart';
import 'package:builders_mobile/dynamic-ui/filters/filters_page1.dart';
import 'package:builders_mobile/dynamic-ui/map/map_page1.dart';
import 'package:builders_mobile/dynamic-ui/orders/order_page1.dart';
import 'package:builders_mobile/dynamic-ui/orders/order_page2.dart';
import 'package:builders_mobile/dynamic-ui/product/product_detail_page.dart';
import 'package:builders_mobile/dynamic-ui/product/product_detail_page2.dart';
import 'package:builders_mobile/dynamic-ui/product/product_detail_page3.dart';
import 'package:builders_mobile/page/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: FilterPage1());
  }
}
