import 'package:ecommerce_app/features/admin/controllers/admin_auth_controller.dart';
import 'package:ecommerce_app/features/admin/controllers/admin_navigation_controller.dart';
import 'package:ecommerce_app/features/admin/screens/alerts/admin_alerts_page.dart';
import 'package:ecommerce_app/features/admin/screens/analytics/admin_analytics_page.dart';
import 'package:ecommerce_app/features/admin/screens/audit/admin_audit_page.dart';
import 'package:ecommerce_app/features/admin/screens/dashboard/admin_dashboard_page.dart';
import 'package:ecommerce_app/features/admin/screens/brands/admin_brands_page.dart';
import 'package:ecommerce_app/features/admin/screens/coupons/admin_coupons_page.dart';
import 'package:ecommerce_app/features/admin/screens/exports/admin_exports_page.dart';
import 'package:ecommerce_app/features/admin/screens/merchandising/admin_merchandising_page.dart';
import 'package:ecommerce_app/features/admin/screens/notifications/admin_notifications_page.dart';
import 'package:ecommerce_app/features/admin/screens/orders/admin_orders_page.dart';
import 'package:ecommerce_app/features/admin/screens/payments/admin_payment_issues_page.dart';
import 'package:ecommerce_app/features/admin/screens/products/admin_products_page.dart';
import 'package:ecommerce_app/features/admin/screens/risk/admin_risk_flags_page.dart';
import 'package:ecommerce_app/features/admin/screens/users/admin_users_page.dart';
import 'package:ecommerce_app/features/admin/screens/wallet/admin_wallet_page.dart';
import 'package:ecommerce_app/features/admin/screens/withdrawals/admin_withdrawals_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.put(AdminNavigationController());
    final auth = Get.find<AdminAuthController>();

    final pages = const [
      AdminDashboardPage(),
      AdminOrdersPage(),
      AdminProductsPage(),
      AdminUsersPage(),
      AdminNotificationsPage(),
      AdminWalletPage(),
      AdminWithdrawalsPage(),
      AdminPaymentIssuesPage(),
      AdminRiskFlagsPage(),
      AdminCouponsPage(),
      AdminBrandsPage(),
      AdminMerchandisingPage(),
      AdminAnalyticsPage(),
      AdminExportsPage(),
      AdminAuditPage(),
      AdminAlertsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce Admin'),
        actions: [
          IconButton(
            onPressed: auth.signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 240,
            child: Obx(() {
              final selectedIndex = nav.selectedIndex.value;
              return ListView.builder(
                itemCount: nav.items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    selected: selectedIndex == index,
                    title: Text(nav.items[index]),
                    onTap: () => nav.select(index),
                  );
                },
              );
            }),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: Obx(() => pages[nav.selectedIndex.value])),
        ],
      ),
    );
  }
}
