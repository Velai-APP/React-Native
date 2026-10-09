import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'procurement_dashboard_screen.dart';
import 'sop_generator_screen.dart';

import 'domain_management_screen.dart';
import 'login_screen.dart';
import 'website_home_screen.dart';
import 'logo_brand_home_screen.dart';
import 'registrationcenter_screen.dart';
import 'admin_registration_applications_screen.dart';
import 'sop_home_screen.dart';
import 'competitor_home_screen.dart';
import 'business_email_screen.dart';
import '../services/auth_service.dart';
import 'auth_gate.dart';

class DashboardScreen extends StatelessWidget {
  final Map<String, dynamic> businessProfile;

  const DashboardScreen({super.key, required this.businessProfile});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    final List<ServiceItem> services = [
      ServiceItem(
        icon: Icons.language,
        title: 'Domain\nManagement',
        subtitle: 'Expiry & reminders',
        color: Colors.blue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DomainManagementScreen()),
          );
        },
      ),
      ServiceItem(
        icon: Icons.auto_awesome,
        title: 'AI Website\nBuilder',
        subtitle: 'Create & publish sites',
        color: Colors.teal,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WebsiteHomeScreen()),
          );
        },
      ),
      ServiceItem(
        icon: Icons.design_services_rounded,
        title: 'Logo &\nBrand Kit',
        subtitle: 'Create your brand identity',
        color: Colors.pink,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LogoBrandHomeScreen()),
          );
        },
      ),
      ServiceItem(
        icon: Icons.app_registration,
        title: 'Registration\nCenter',
        subtitle: 'Business registrations',
        color: Colors.indigo,
        onTap: () async {
          final user = FirebaseAuth.instance.currentUser;

          if (user == null) {
            return;
          }

          try {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

            final userRole =
                userDoc.data()?['userRole']?.toString().toLowerCase() ??
                'customer';

            if (!context.mounted) return;

            if (userRole == 'admin') {
              // ADMIN
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminRegistrationApplicationsScreen(),
                ),
              );
            } else {
              // NORMAL CUSTOMER
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegistrationCenterScreen(),
                ),
              );
            }
          } catch (e) {
            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unable to load user role: $e')),
            );
          }
        },
      ),

      ServiceItem(
        icon: Icons.auto_awesome_rounded,
        title: 'AI SOP\nGenerator',
        subtitle: 'Create smart procedures',
        color: Colors.deepPurple,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SopHomeScreen()),
          );
        },
      ),

      ServiceItem(
  icon: Icons.analytics_rounded,
  title: 'AI Competitor\nAnalysis',
  subtitle: 'Analyze market & rivals',
  color: Colors.blue,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CompetitorHomeScreen()),
    );
  },
),
ServiceItem(
  icon: Icons.alternate_email_rounded,
  title: 'Business\nEmail',
  subtitle: 'Create your professional email',
  color: Colors.deepPurple,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BusinessEmailScreen(),
      ),
    );
  },
),
ServiceItem(
  icon: Icons.shopping_cart_checkout_rounded,
  title: 'AI Procurement',
  subtitle: 'Supplier quotes & purchase orders',
  color: Colors.indigo,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProcurementDashboardScreen(
         
        ),
      ),
    );
  },
),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E3A8A),
        title: const Text(
          'Velai Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      drawer: _AppDrawer(user: user),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _welcomeCard(user),

              const SizedBox(height: 18),

              /// BUSINESS PROFILE
              _businessProfileCard(context),

              const SizedBox(height: 28),

              const Text(
                'Select a Service',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              const Text(
                'Manage your business, compliance and digital services',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),

              const SizedBox(height: 22),

              LayoutBuilder(
                builder: (context, constraints) {
                  final double cardWidth = (constraints.maxWidth - 14) / 2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: services.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: cardWidth * 1.18,
                    ),
                    itemBuilder: (context, index) {
                      final ServiceItem service = services[index];

                      return _serviceCard(
                        icon: service.icon,
                        title: service.title,
                        subtitle: service.subtitle,
                        color: service.color,
                        onTap: service.onTap,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BUSINESS PROFILE CARD
  // ==========================================================

  Widget _businessProfileCard(BuildContext context) {
    final String businessName =
        businessProfile['businessName']?.toString() ?? 'Your Business';

    final String category =
        businessProfile['businessCategory']?.toString() ??
        businessProfile['category']?.toString() ??
        'Business';

    final String matchScore = businessProfile['matchScore']?.toString() ?? '0';

    final String investment =
        businessProfile['investment']?.toString() ??
        businessProfile['requiredInvestment']?.toString() ??
        'Not specified';

    final String timeToLaunch =
        businessProfile['timeToLaunch']?.toString() ??
        businessProfile['launchTime']?.toString() ??
        'Not specified';

    final String difficulty =
        businessProfile['difficulty']?.toString() ?? 'Medium';

    final String description =
        businessProfile['description']?.toString() ??
        businessProfile['opportunitySummary']?.toString() ??
        '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(26),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 54,
                width: 54,

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
                  ),

                  borderRadius: BorderRadius.circular(17),
                ),

                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 29,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR BUSINESS PROFILE',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      businessName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 21,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, size: 17, color: Colors.green),

                    const SizedBox(width: 3),

                    Text(
                      '$matchScore%',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),

            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              category,
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          if (description.isNotEmpty) ...[
            const SizedBox(height: 15),

            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),
          ],

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _businessInfoBox(
                  icon: Icons.currency_rupee,
                  title: 'Investment',
                  value: investment,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _businessInfoBox(
                  icon: Icons.schedule,
                  title: 'Launch',
                  value: timeToLaunch,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _businessInfoBox(
                  icon: Icons.trending_up,
                  title: 'AI Match',
                  value: '$matchScore%',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _businessInfoBox(
                  icon: Icons.speed,
                  title: 'Difficulty',
                  value: difficulty,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,

            child: OutlinedButton.icon(
              onPressed: () {
                _showBusinessProfile(context, businessProfile);
              },

              icon: const Icon(Icons.visibility_outlined),

              label: const Text(
                'View Full Business Profile',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E3A8A),

                side: const BorderSide(color: Color(0xFF1E3A8A)),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUSINESS INFO BOX
  // ==========================================================

  Widget _businessInfoBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1E3A8A)),

          const SizedBox(height: 8),

          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),

          const SizedBox(height: 4),

          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FULL BUSINESS PROFILE BOTTOM SHEET
  // ==========================================================

  void _showBusinessProfile(
    BuildContext context,
    Map<String, dynamic> profile,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.55,
          maxChildSize: 0.95,

          builder: (context, controller) {
            return Container(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 25),

              decoration: const BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),

              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,

                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,

                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
                          ),

                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Text(
                          'Your Business Profile',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  _profileDetail(
                    'Business',
                    profile['businessName'],
                    Icons.business_center_outlined,
                  ),

                  _profileDetail(
                    'Category',
                    profile['businessCategory'] ?? profile['category'],
                    Icons.category_outlined,
                  ),

                  _profileDetail(
                    'Match Score',
                    profile['matchScore'] != null
                        ? '${profile['matchScore']}%'
                        : '-',
                    Icons.auto_awesome,
                  ),

                  _profileDetail(
                    'Investment Required',
                    profile['investment'] ?? profile['requiredInvestment'],
                    Icons.currency_rupee,
                  ),

                  _profileDetail(
                    'Expected Launch Time',
                    profile['timeToLaunch'] ?? profile['launchTime'],
                    Icons.schedule,
                  ),

                  _profileDetail(
                    'Difficulty',
                    profile['difficulty'],
                    Icons.speed,
                  ),

                  _profileDetail(
                    'Target Customers',
                    profile['targetCustomers'],
                    Icons.groups_outlined,
                  ),

                  _profileDetail(
                    'Revenue Model',
                    profile['revenueModel'],
                    Icons.payments_outlined,
                  ),

                  _profileDetail(
                    'Why This Business Fits You',
                    profile['whyItFits'],
                    Icons.psychology_outlined,
                  ),

                  _profileDetail(
                    'Business Description',
                    profile['description'] ?? profile['opportunitySummary'],
                    Icons.description_outlined,
                  ),

                  _profileDetail(
                    'Your Strengths',
                    profile['entrepreneurStrengths'] ?? profile['strengths'],
                    Icons.workspace_premium_outlined,
                  ),

                  _profileDetail(
                    'Skills Required',
                    profile['skillsRequired'] ?? profile['skills'],
                    Icons.school_outlined,
                  ),

                  _profileDetail(
                    'Possible Weaknesses',
                    profile['possibleWeaknesses'] ?? profile['weaknesses'],
                    Icons.warning_amber_rounded,
                  ),

                  _profileDetail(
                    'Major Risks',
                    profile['majorRisks'] ?? profile['risks'],
                    Icons.shield_outlined,
                  ),

                  _profileDetail(
                    'First Steps',
                    profile['firstSteps'],
                    Icons.format_list_numbered,
                  ),

                  _profileDetail(
                    'Alternative Businesses',
                    profile['alternativeBusinesses'] ?? profile['alternatives'],
                    Icons.lightbulb_outline,
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // PROFILE DETAIL
  // ==========================================================

  Widget _profileDetail(String title, dynamic value, IconData icon) {
    if (value == null) {
      return const SizedBox.shrink();
    }

    final String displayValue;

    if (value is List) {
      if (value.isEmpty) {
        return const SizedBox.shrink();
      }

      displayValue = value
          .asMap()
          .entries
          .map((entry) => '${entry.key + 1}. ${entry.value}')
          .join('\n');
    } else {
      displayValue = value.toString().trim();

      if (displayValue.isEmpty) {
        return const SizedBox.shrink();
      }
    }

    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,

            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, size: 20, color: const Color(0xFF1E3A8A)),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // WELCOME CARD
  // ==========================================================

  Widget _welcomeCard(User? user) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,

            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,

            child: user?.photoURL == null
                ? const Icon(Icons.person, size: 36, color: Color(0xFF1E3A8A))
                : null,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),

                const SizedBox(height: 4),

                Text(
                  user?.displayName ?? 'User',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  user?.email ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SERVICE MODEL
// ============================================================

class ServiceItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

// ============================================================
// APP DRAWER
// ============================================================

class _AppDrawer extends StatelessWidget {
  final User? user;

  const _AppDrawer({required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        top: false,

        child: Column(
          children: [
            Container(
              width: double.infinity,

              padding: const EdgeInsets.fromLTRB(20, 55, 20, 25),

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,

                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,

                    child: user?.photoURL == null
                        ? const Icon(
                            Icons.person,
                            size: 45,
                            color: Color(0xFF1E3A8A),
                          )
                        : null,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    user?.displayName ?? 'No Name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    user?.email ?? 'No Email',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            _drawerTile(
              icon: Icons.dashboard,
              title: 'Dashboard',
              onTap: () {
                Navigator.pop(context);
              },
            ),

            _drawerTile(
              icon: Icons.person,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),

            _drawerTile(
              icon: Icons.language,
              title: 'Domains',
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DomainManagementScreen(),
                  ),
                );
              },
            ),

            
            const Spacer(),

            const Divider(height: 1),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),

              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),

             
onTap: () async {
  try {
    // Sign out from Firebase and Google Sign-In.
    await AuthService.instance.signOut();

    if (!context.mounted) return;

    // Return to AuthGate.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthGate(),
      ),
      (route) => false,
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logout failed: $e'),
      ),
    );
  }
},

            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1E3A8A)),

      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

      onTap: onTap,
    );
  }
}

// ============================================================
// SERVICE CARD
// ============================================================

Widget _serviceCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,

    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),

      child: Ink(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 27,

              backgroundColor: color.withOpacity(0.14),

              child: Icon(icon, color: color, size: 29),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,

              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
                height: 1.12,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,

              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const Spacer(),

            Align(
              alignment: Alignment.bottomRight,

              child: Icon(Icons.arrow_forward_rounded, color: color, size: 22),
            ),
          ],
        ),
      ),
    ),
  );
}



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSigningOut = false;

  User? get user => FirebaseAuth.instance.currentUser;

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Color(0xFFDC2626),
              ),
              SizedBox(width: 12),
              Text('Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from your account?',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _signOutAndGoToLogin();
  }

  // ============================================================
  // SWITCH GOOGLE ACCOUNT
  // ============================================================

  Future<void> _switchAccount() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.switch_account_rounded,
                color: Color(0xFF2563EB),
              ),
              SizedBox(width: 12),
              Text('Switch Account'),
            ],
          ),
          content: const Text(
            'You will return to the login screen where you can select another Google account.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _signOutAndGoToLogin();
  }

  Future<void> _signOutAndGoToLogin() async {
    if (_isSigningOut) return;

    setState(() {
      _isSigningOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFDC2626),
          content: Text(
            'Unable to sign out: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
      }
    }
  }

  // ============================================================
  // PROVIDER NAME
  // ============================================================

  String _providerName(User user) {
    if (user.providerData.isEmpty) {
      return 'Firebase';
    }

    final String provider =
        user.providerData.first.providerId.toLowerCase();

    switch (provider) {
      case 'google.com':
        return 'Google';
      case 'password':
        return 'Email & Password';
      case 'phone':
        return 'Phone';
      case 'facebook.com':
        return 'Facebook';
      case 'apple.com':
        return 'Apple';
      default:
        return provider;
    }
  }

  // ============================================================
  // INITIALS
  // ============================================================

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'U';
    }

    final parts = name
        .trim()
        .split(' ')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final User? currentUser = user;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: Center(
          child: FilledButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const AuthGate(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.login),
            label: const Text('Go to Login'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          final Map<String, dynamic> firestoreData =
              snapshot.data?.data() ?? {};

          final String role =
              firestoreData['userRole']?.toString() ?? 'customer';

          final String status =
              firestoreData['status']?.toString() ?? 'active';

          final String name =
              currentUser.displayName?.trim().isNotEmpty == true
                  ? currentUser.displayName!
                  : firestoreData['name']?.toString() ?? 'User';

          final String email =
              currentUser.email?.trim().isNotEmpty == true
                  ? currentUser.email!
                  : firestoreData['email']?.toString() ??
                      'Email not available';

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // =================================================
              // APP BAR
              // =================================================

              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                stretch: true,
                elevation: 0,
                backgroundColor: const Color(0xFF172554),
                foregroundColor: Colors.white,
                title: const Text(
                  'My Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                centerTitle: true,

                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle,
                  ],
                  background: _buildProfileHeader(
                    user: currentUser,
                    name: name,
                    email: email,
                    role: role,
                    status: status,
                  ),
                ),
              ),

              // =================================================
              // BODY
              // =================================================

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  40,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // ==========================================
                      // ACCOUNT OVERVIEW
                      // ==========================================

                      _sectionTitle(
                        icon: Icons.person_outline_rounded,
                        title: 'Account Overview',
                        subtitle:
                            'Your personal and login information',
                      ),

                      const SizedBox(height: 12),

                      _buildCard(
                        child: Column(
                          children: [
                            _infoTile(
                              icon: Icons.person_outline,
                              title: 'Full Name',
                              value: name,
                            ),
                            _divider(),
                            _infoTile(
                              icon: Icons.email_outlined,
                              title: 'Email Address',
                              value: email,
                              trailing: currentUser.emailVerified
                                  ? _verifiedBadge()
                                  : null,
                            ),
                            _divider(),
                            _infoTile(
                              icon: Icons.phone_outlined,
                              title: 'Phone Number',
                              value:
                                  currentUser.phoneNumber ??
                                      'Not added',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==========================================
                      // ACCOUNT STATUS
                      // ==========================================

                      _sectionTitle(
                        icon: Icons.shield_outlined,
                        title: 'Account Status',
                        subtitle:
                            'Role, access and authentication details',
                      ),

                      const SizedBox(height: 12),

                      _buildCard(
                        child: Column(
                          children: [
                            _infoTile(
                              icon:
                                  Icons.admin_panel_settings_outlined,
                              title: 'Account Role',
                              value: _formatRole(role),
                              trailing: _roleBadge(role),
                            ),
                            _divider(),
                            _infoTile(
                              icon: Icons.check_circle_outline,
                              title: 'Account Status',
                              value: _capitalize(status),
                              trailing: _statusBadge(status),
                            ),
                            _divider(),
                            _infoTile(
                              icon: Icons.login_rounded,
                              title: 'Login Provider',
                              value:
                                  _providerName(currentUser),
                              trailing:
                                  _providerIcon(currentUser),
                            ),
                            _divider(),
                            _infoTile(
                              icon:
                                  Icons.verified_user_outlined,
                              title: 'Email Verification',
                              value:
                                  currentUser.emailVerified
                                      ? 'Verified'
                                      : 'Not verified',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==========================================
                      // FIREBASE ID
                      // ==========================================

                 

                      
                      // ==========================================
                      // ACCOUNT ACTIONS
                      // ==========================================

                      _sectionTitle(
                        icon: Icons.settings_outlined,
                        title: 'Account Actions',
                        subtitle:
                            'Manage your login and account session',
                      ),

                      const SizedBox(height: 12),

                      _buildCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _actionTile(
                              icon:
                                  Icons.switch_account_rounded,
                              iconBackground:
                                  const Color(0xFFEFF6FF),
                              iconColor:
                                  const Color(0xFF2563EB),
                              title:
                                  'Switch Google Account',
                              subtitle:
                                  'Sign in using another Google account',
                              onTap: _switchAccount,
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: _divider(),
                            ),

                            _actionTile(
                              icon: Icons.logout_rounded,
                              iconBackground:
                                  const Color(0xFFFEF2F2),
                              iconColor:
                                  const Color(0xFFDC2626),
                              title: 'Logout',
                              subtitle:
                                  'Sign out from this device',
                              titleColor:
                                  const Color(0xFFDC2626),
                              onTap: _logout,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==========================================
                      // SECURITY NOTE
                      // ==========================================

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF172554),
                              Color(0xFF312E81),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(22),
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(.12),
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.lock_outline_rounded,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Your account is protected',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    'Authentication is securely managed using Firebase Authentication.',
                                    style: TextStyle(
                                      color: Colors.white
                                          .withOpacity(.72),
                                      height: 1.5,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Center(
                        child: Text(
                          'Velai • Your Business Companion',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      // =========================================================
      // LOADING OVERLAY
      // =========================================================

      bottomNavigationBar: _isSigningOut
          ? const LinearProgressIndicator(
              minHeight: 3,
            )
          : null,
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader({
  required User user,
  required String name,
  required String email,
  required String role,
  required String status,
}) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF0F172A),
          Color(0xFF1E3A8A),
          Color(0xFF4F46E5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Stack(
      children: [
        // =====================================================
        // DECORATION
        // =====================================================

        Positioned(
          right: -45,
          top: 20,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.05),
            ),
          ),
        ),

        Positioned(
          left: -60,
          bottom: -30,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.04),
            ),
          ),
        ),

        // =====================================================
        // RESPONSIVE HEADER
        // =====================================================

        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double height = constraints.maxHeight;

              // When SliverAppBar starts collapsing,
              // gradually reduce the profile content.
              final bool compact = height < 260;

              final double avatarRadius =
                  compact ? 38 : 52;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  compact ? 12 : 50,
                  20,
                  compact ? 8 : 18,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // =========================================
                      // PROFILE IMAGE
                      // =========================================

                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(.18),
                                  blurRadius: 22,
                                  offset:
                                      const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: avatarRadius,
                              backgroundColor:
                                  const Color(0xFFE0E7FF),

                              backgroundImage:
                                  user.photoURL != null &&
                                          user.photoURL!
                                              .isNotEmpty
                                      ? NetworkImage(
                                          user.photoURL!,
                                        )
                                      : null,

                              child: user.photoURL == null ||
                                      user.photoURL!.isEmpty
                                  ? Text(
                                      _initials(name),
                                      style: TextStyle(
                                        color:
                                            const Color(
                                          0xFF1E3A8A,
                                        ),
                                        fontSize:
                                            compact ? 25 : 32,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),

                          if (user.emailVerified)
                            Positioned(
                              bottom: 1,
                              right: 1,
                              child: Container(
                                width:
                                    compact ? 25 : 31,
                                height:
                                    compact ? 25 : 31,
                                decoration:
                                    const BoxDecoration(
                                  color:
                                      Color(0xFF16A34A),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size:
                                      compact ? 15 : 19,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(
                        height: compact ? 8 : 14,
                      ),

                      // =========================================
                      // NAME
                      // =========================================

                      Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 19 : 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      SizedBox(
                        height: compact ? 2 : 5,
                      ),

                      // =========================================
                      // EMAIL
                      // =========================================

                      Text(
                        email,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              Colors.white.withOpacity(.72),
                          fontSize: compact ? 11 : 14,
                        ),
                      ),

                      // =========================================
                      // HIDE CHIPS WHILE COLLAPSING
                      // =========================================

                      if (!compact) ...[
                        const SizedBox(height: 13),

                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _headerChip(
                              icon: Icons
                                  .workspace_premium_outlined,
                              text: _formatRole(role),
                            ),

                            _headerChip(
                              icon: Icons.circle,
                              text: _capitalize(status),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEFF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            size: 21,
            color: const Color(0xFF1E3A8A),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF172033),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF8490A4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _buildCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 5,
    ),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEDF0F5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // INFO TILE
  // ============================================================

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF475569),
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          if (trailing != null) ...[
            const SizedBox(width: 10),
            trailing,
          ],
        ],
      ),
    );
  }

  // ============================================================
  // ACTION TILE
  // ============================================================

  Widget _actionTile({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color titleColor = const Color(0xFF1E293B),
  }) {
    return InkWell(
      onTap: _isSigningOut ? null : onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: iconColor,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BADGES
  // ============================================================

  Widget _verifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: 14,
            color: Color(0xFF16A34A),
          ),
          SizedBox(width: 4),
          Text(
            'Verified',
            style: TextStyle(
              color: Color(0xFF15803D),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        _formatRole(role),
        style: const TextStyle(
          color: Color(0xFF4338CA),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final bool active = status.toLowerCase() == 'active';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: active
                ? const Color(0xFF16A34A)
                : const Color(0xFFDC2626),
          ),
          const SizedBox(width: 6),
          Text(
            _capitalize(status),
            style: TextStyle(
              color: active
                  ? const Color(0xFF15803D)
                  : const Color(0xFFB91C1C),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _providerIcon(User user) {
    final String provider = _providerName(user);

    if (provider == 'Google') {
      return Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: const Center(
          child: Text(
            'G',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4285F4),
            ),
          ),
        ),
      );
    }

    return const Icon(
      Icons.security_rounded,
      color: Color(0xFF64748B),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF1F5F9),
    );
  }

  // ============================================================
  // TEXT HELPERS
  // ============================================================

  String _capitalize(String value) {
    if (value.trim().isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1).toLowerCase();
  }

  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';

      case 'staff':
        return 'Staff';

      case 'seller':
        return 'Seller';

      case 'customer':
        return 'Customer';

      default:
        return _capitalize(role);
    }
  }
}