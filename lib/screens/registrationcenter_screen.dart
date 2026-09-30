import 'package:flutter/material.dart';
import 'msme_registeration_screen.dart';
import 'my_applications_screen.dart';
import 'gst_registration_screen.dart';
import 'iec_registration_screen.dart';
import 'proprietorship_registration_screen.dart';
import 'partnership_registration_screen.dart';
import 'llp_registration_screen.dart';
import 'private_limited_registration_screen.dart';

class RegistrationCenterScreen extends StatefulWidget {
  const RegistrationCenterScreen({super.key});

  @override
  State<RegistrationCenterScreen> createState() =>
      _RegistrationCenterScreenState();
}

class _RegistrationCenterScreenState extends State<RegistrationCenterScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _search = '';

  final List<RegistrationService> services = const [
    RegistrationService(
      title: 'MSME',
      subtitle: 'Udyam Registration',
      description:
          'Register your business as a Micro, Small or Medium Enterprise.',
      icon: Icons.factory_outlined,
      accent: Color(0xFF0F766E),
      softColor: Color(0xFFCCFBF1),
      tag: 'Quick',
    ),
    RegistrationService(
      title: 'GST',
      subtitle: 'GST Registration',
      description: 'Apply for GST registration and obtain your GSTIN.',
      icon: Icons.receipt_long_outlined,
      accent: Color(0xFF2563EB),
      softColor: Color(0xFFDBEAFE),
      tag: 'Popular',
    ),
    RegistrationService(
      title: 'IEC',
      subtitle: 'Import Export Code',
      description:
          'Get your IEC to start importing or exporting goods and services.',
      icon: Icons.public_outlined,
      accent: Color(0xFF7C3AED),
      softColor: Color(0xFFEDE9FE),
      tag: 'Global',
    ),
    RegistrationService(
      title: 'Proprietorship',
      subtitle: 'Sole Proprietor',
      description:
          'Start a simple business structure owned by a single person.',
      icon: Icons.person_outline_rounded,
      accent: Color(0xFFEA580C),
      softColor: Color(0xFFFFEDD5),
      tag: 'Simple',
    ),
    RegistrationService(
      title: 'Partnership',
      subtitle: 'Partnership Firm',
      description:
          'Set up a traditional partnership firm with two or more partners.',
      icon: Icons.handshake_outlined,
      accent: Color(0xFF0891B2),
      softColor: Color(0xFFCFFAFE),
      tag: 'Partners',
    ),
    RegistrationService(
      title: 'LLP',
      subtitle: 'Limited Liability Partnership',
      description:
          'Combine partnership flexibility with limited liability protection.',
      icon: Icons.groups_2_outlined,
      accent: Color(0xFF4F46E5),
      softColor: Color(0xFFE0E7FF),
      tag: 'Flexible',
    ),
    RegistrationService(
      title: 'Private Limited',
      subtitle: 'Company Incorporation',
      description:
          'Incorporate a private limited company for scalable business growth.',
      icon: Icons.apartment_rounded,
      accent: Color(0xFFBE123C),
      softColor: Color(0xFFFFE4E6),
      tag: 'Scalable',
    ),
  ];

  Widget _buildTrackStatusCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyApplicationsScreen()),
            );
          },
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEEF2FF), Color(0xFFEFF6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFDDE5FF)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(.06),
                  blurRadius: 20,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Row(
              children: [
                // ICON
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(.20),
                        blurRadius: 15,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 15),

                // TEXT
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Track My Applications',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        'View registration status and progress',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // BUTTON
                Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      SizedBox(width: 5),

                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredServices = services.where((service) {
      final text = '${service.title} ${service.subtitle} ${service.description}'
          .toLowerCase();

      return text.contains(_search.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildSearch()),
            SliverToBoxAdapter(child: _buildTrackStatusCard()),
            SliverToBoxAdapter(child: _buildSectionHeading()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final service = filteredServices[index];

                  return _ServiceCard(
                    service: service,
                    onTap: () {
                      _openService(context, service);
                    },
                  );
                }, childCount: filteredServices.length),

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildHelpCard()),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF312E81), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(.18),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -35,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.06),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -50,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyanAccent.withOpacity(.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Business Services',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.13),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Registration Center',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.6,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Everything you need to start and register your business, all in one place.',
                style: TextStyle(
                  color: Colors.white.withOpacity(.75),
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _miniStat('7', 'Services'),
                  const SizedBox(width: 10),
                  _miniStat('100%', 'Digital'),
                  const SizedBox(width: 10),
                  _miniStat('Easy', 'Guided'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.09),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(.10)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(.60),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _search = value;
            });
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search GST, LLP, MSME...',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF4F46E5),
            ),
            suffixIcon: _search.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();

                      setState(() {
                        _search = '';
                      });
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
            contentPadding: const EdgeInsets.symmetric(vertical: 19),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeading() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 26, 20, 15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose a Service',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Select what you want to register',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.grid_view_rounded, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }

  Widget _buildHelpCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.10),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(Icons.support_agent_rounded, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Not sure what to choose?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We can help you identify the right business structure.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.62),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        ],
      ),
    );
  }

  void _openService(BuildContext context, RegistrationService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: service.softColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(service.icon, color: service.accent, size: 28),
              ),

              const SizedBox(height: 18),

              Text(
                service.title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                service.subtitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: service.accent,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                service.description,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  height: 1.6,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: service.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),

                  onPressed: () {
                    // Only MSME is active for now
                    if (service.title == 'MSME') {
                      // Close bottom sheet first
                      Navigator.pop(sheetContext);

                      // Then open MSME registration screen
                      Future.microtask(() {
                        if (!mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MsmeRegistrationScreen(),
                          ),
                        );
                      });

                      return;
                    }

                    if (service.title == 'GST') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GstRegistrationScreen(),
                        ),
                      );

                      return;
                    }
                    if (service.title == 'IEC') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const IecRegistrationScreen(),
                        ),
                      );

                      return;
                    }

                    if (service.title == 'Proprietorship') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ProprietorshipRegistrationScreen(),
                        ),
                      );

                      return;
                    }

                    if (service.title == 'Partnership') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PartnershipRegistrationScreen(),
                        ),
                      );

                      return;
                    }
                    if (service.title == 'LLP') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LlpRegistrationScreen(),
                        ),
                      );

                      return;
                    }

                    if (service.title == 'Private Limited') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const PrivateLimitedRegistrationScreen(),
                        ),
                      );

                      return;
                    }

                    // Other registrations not developed yet
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${service.title} registration is coming soon.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },

                  child: const Text(
                    'Start Registration',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final RegistrationService service;
  final VoidCallback onTap;

  const _ServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.025),
                blurRadius: 18,
                offset: const Offset(0, 7),
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
                    height: 49,
                    width: 49,
                    decoration: BoxDecoration(
                      color: service.softColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(service.icon, color: service.accent, size: 25),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: service.softColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      service.tag,
                      style: TextStyle(
                        color: service.accent,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                service.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                service.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: service.accent,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                service.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Get started',
                    style: TextStyle(
                      color: service.accent,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 31,
                    width: 31,
                    decoration: BoxDecoration(
                      color: service.softColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 17,
                      color: service.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegistrationService {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accent;
  final Color softColor;
  final String tag;

  const RegistrationService({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accent,
    required this.softColor,
    required this.tag,
  });
}
