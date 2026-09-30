import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'brand_details_screen.dart';
import 'brand_kit_screen.dart';
import 'logo_generation_screen.dart';
import 'saved_brand_kits_screen.dart';

class LogoBrandHomeScreen extends StatelessWidget {
  const LogoBrandHomeScreen({super.key});

  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color brightBlue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF172033);
  static const Color borderColor = Color(0xFFE3E8F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Logo & Brand Kit',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 900;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 50 : 18,
                vertical: 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroSection(context, isDesktop),

                      const SizedBox(height: 34),

                      // Saved brand kit section
                      _buildSavedBrandKitsSection(context, isDesktop),

                      const SizedBox(height: 34),

                      const Text(
                        'Everything your brand needs',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Create a complete visual identity for your business.',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      const SizedBox(height: 22),

                      _buildFeaturesGrid(isDesktop),

                      const SizedBox(height: 34),

                      _buildHowItWorks(),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // SAVED BRAND KITS
  // ============================================================

  Widget _buildSavedBrandKitsSection(BuildContext context, bool isDesktop) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildSignedOutBrandKitCard();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('brandProjects')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildBrandKitsError(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildBrandKitsLoading();
        }

        final List<QueryDocumentSnapshot<Map<String, dynamic>>> projects =
            List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
              snapshot.data?.docs ?? [],
            );

        projects.sort((first, second) {
          final DateTime? firstDate = _projectDate(first.data());

          final DateTime? secondDate = _projectDate(second.data());

          return (secondDate?.millisecondsSinceEpoch ?? 0).compareTo(
            firstDate?.millisecondsSinceEpoch ?? 0,
          );
        });

        if (projects.isEmpty) {
          return _buildEmptyBrandKits(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Brand Kits',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'View and manage all your generated brand identities.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: brightBlue.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '${projects.length} '
                    '${projects.length == 1 ? 'Kit' : 'Kits'}',
                    style: const TextStyle(
                      color: primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            SizedBox(
              height: 320,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: projects.length,
                separatorBuilder: (_, __) {
                  return const SizedBox(width: 16);
                },
                itemBuilder: (context, index) {
                  final document = projects[index];

                  return SizedBox(
                    width: isDesktop ? 330 : 285,
                    child: _buildSavedBrandKitCard(
                      context: context,
                      projectId: document.id,
                      data: document.data(),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSavedBrandKitCard({
    required BuildContext context,
    required String projectId,
    required Map<String, dynamic> data,
  }) {
    final String businessName = _stringValue(
      data['businessName'],
      fallback: 'Untitled Brand',
    );

    final String industry = _stringValue(
      data['industry'],
      fallback: 'Business',
    );

    final String tagline = _stringValue(data['tagline'], fallback: '');

    final String status = _stringValue(data['status'], fallback: 'saved');

    final Map<String, dynamic> logoData = _getSavedLogo(data);

    final String imageUrl = _stringValue(logoData['imageUrl'], fallback: '');

    final DateTime? updatedDate = _projectDate(data);

    final bool canOpen = imageUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(17),
                  color: const Color(0xFFF8FAFC),
                  child: imageUrl.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                            size: 54,
                          ),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) {
                              return child;
                            }

                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey,
                                size: 54,
                              ),
                            );
                          },
                        ),
                ),

                Positioned(top: 12, left: 12, child: _buildStatusBadge(status)),

                Positioned(
                  top: 8,
                  right: 8,
                  child: PopupMenuButton<String>(
                    tooltip: 'Brand kit options',
                    color: Colors.white,
                    icon: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.94),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.more_vert_rounded,
                        color: primaryBlue,
                        size: 20,
                      ),
                    ),
                    onSelected: (value) {
                      if (value == 'open') {
                        _openSavedBrandKit(context, projectId, data);
                      }

                      if (value == 'delete') {
                        _confirmDeleteBrandKit(
                          context,
                          projectId,
                          businessName,
                        );
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'open',
                          enabled: canOpen,
                          child: const Row(
                            children: [
                              Icon(Icons.visibility_outlined, size: 20),
                              SizedBox(width: 10),
                              Text('View brand kit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  businessName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  industry,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (tagline.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    tagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 11.5),
                  ),
                ],

                const SizedBox(height: 12),

                Row(
                  children: [
                    if (updatedDate != null) ...[
                      const Icon(
                        Icons.schedule_outlined,
                        color: Colors.grey,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _formatDate(updatedDate),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ] else
                      const Spacer(),

                    const SizedBox(width: 8),

                    SizedBox(
                      height: 37,
                      child: FilledButton.icon(
                        onPressed: canOpen
                            ? () {
                                _openSavedBrandKit(context, projectId, data);
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: brightBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: const Text(
                          'Open',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  Widget _buildStatusBadge(String status) {
    final String lowerStatus = status.toLowerCase();

    Color color;

    if (lowerStatus == 'completed') {
      color = const Color(0xFF059669);
    } else if (lowerStatus.contains('generating')) {
      color = const Color(0xFFD97706);
    } else {
      color = brightBlue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8),
        ],
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyBrandKits(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: brightBlue.withOpacity(0.09),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.palette_outlined,
              color: brightBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: 17),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No saved brand kits yet',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Create and save your first brand identity. It will appear here automatically.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filled(
            tooltip: 'Create brand kit',
            style: IconButton.styleFrom(
              backgroundColor: brightBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrandDetailsScreen()),
              );
            },
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildSignedOutBrandKitCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: borderColor),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: primaryBlue, size: 30),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Sign in to view your saved brand kits.',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandKitsLoading() {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: borderColor),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 13),
            Text(
              'Loading your brand kits...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandKitsError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Unable to load brand kits',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(color: Colors.red, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openSavedBrandKit(
    BuildContext context,
    String projectId,
    Map<String, dynamic> data,
  ) {
    final Map<String, dynamic> strategy = _mapValue(data['brandStrategy']);

    final Map<String, dynamic> logoData = _getSavedLogo(data);

    final String imageUrl = _stringValue(logoData['imageUrl'], fallback: '');

    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No selected logo was found in this project.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final LogoConcept logo = LogoConcept.fromMap(logoData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrandKitScreen(
          projectId: projectId,
          businessName: _stringValue(
            data['businessName'],
            fallback: 'Untitled Brand',
          ),
          industry: _stringValue(data['industry'], fallback: 'Business'),
          businessDescription: _stringValue(
            data['businessDescription'],
            fallback: '',
          ),
          targetAudience: _stringValue(data['targetAudience'], fallback: ''),
          tagline: _stringValue(
            data['tagline'],
            fallback: _stringValue(strategy['tagline'], fallback: ''),
          ),
          personalities: _stringList(data['personalities']),
          brandValues: _stringList(data['brandValues']),
          brandVoice: _stringValue(
            data['brandVoice'],
            fallback: _stringValue(strategy['toneOfVoice'], fallback: ''),
          ),
          audienceFeeling: _stringValue(data['audienceFeeling'], fallback: ''),
          logoStyle: _stringValue(data['logoStyle'], fallback: logo.style),
          logoType: _stringValue(data['logoType'], fallback: logo.logoType),
          colorDirection: _stringValue(data['colorDirection'], fallback: ''),
          symbolPreference: _stringValue(
            data['symbolPreference'],
            fallback: '',
          ),
          fontStyle: _stringValue(
            data['fontStyle'],
            fallback: _stringValue(strategy['headingFont'], fallback: ''),
          ),
          selectedLogo: logo,
          brandStrategy: strategy,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteBrandKit(
    BuildContext context,
    String projectId,
    String businessName,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete brand kit?'),
          content: Text(
            'Are you sure you want to delete the saved brand kit for $businessName?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('brandProjects')
          .doc(projectId)
          .delete();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Brand kit deleted successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseException catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Unable to delete the brand kit.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Map<String, dynamic> _getSavedLogo(Map<String, dynamic> data) {
    final Map<String, dynamic> selectedLogo = _mapValue(data['selectedLogo']);

    if (selectedLogo.isNotEmpty) {
      return selectedLogo;
    }

    final dynamic logoConcepts = data['logoConcepts'];

    if (logoConcepts is List &&
        logoConcepts.isNotEmpty &&
        logoConcepts.first is Map) {
      return Map<String, dynamic>.from(logoConcepts.first as Map);
    }

    return {};
  }

  DateTime? _projectDate(Map<String, dynamic> data) {
    final dynamic updatedAt = data['updatedAt'];
    final dynamic completedAt = data['completedAt'];
    final dynamic createdAt = data['createdAt'];

    if (updatedAt is Timestamp) {
      return updatedAt.toDate();
    }

    if (completedAt is Timestamp) {
      return completedAt.toDate();
    }

    if (createdAt is Timestamp) {
      return createdAt.toDate();
    }

    return null;
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');

    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _stringValue(dynamic value, {required String fallback}) {
    final String text = value?.toString().trim() ?? '';

    return text.isEmpty ? fallback : text;
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _mapValue(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  // ============================================================
  // EXISTING HOME DESIGN
  // ============================================================

  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber, size: 17),
              SizedBox(width: 7),
              Text(
                'AI-POWERED BRAND DESIGN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Turn your business\ninto a powerful brand.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 37,
            height: 1.12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Generate professional logo concepts, colour palettes, typography and brand guidelines in a few simple steps.',
          style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.55),
        ),
        const SizedBox(height: 26),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 17),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BrandDetailsScreen()),
            );
          },
          icon: const Icon(Icons.auto_awesome),
          label: const Text(
            'Create My Brand',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ],
    );

    final Widget preview = Container(
      height: 265,
      constraints: const BoxConstraints(maxWidth: 430),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.08,
            child: Container(
              width: 280,
              height: 195,
              decoration: BoxDecoration(
                color: const Color(0xFFFFCC70),
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
          Transform.rotate(
            angle: 0.05,
            child: Container(
              width: 280,
              height: 195,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 28,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.change_circle_outlined,
                    size: 65,
                    color: brightBlue,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'NEXORA',
                    style: TextStyle(
                      fontSize: 27,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'DIGITAL SOLUTIONS',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 2,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 42 : 25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryBlue, brightBlue, Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: brightBlue.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 30),
                Expanded(child: preview),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 24),
                Center(child: preview),
              ],
            ),
    );
  }

  Widget _buildMyBrandKitsCard(BuildContext context, bool isDesktop) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SavedBrandKitsScreen()),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isDesktop ? 26 : 19),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF5F3FF), Color(0xFFEFF6FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFC4B5FD)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: isDesktop ? 70 : 58,
                height: isDesktop ? 70 : 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.collections_bookmark_outlined,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              SizedBox(width: isDesktop ? 20 : 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Brand Kits',
                      style: TextStyle(
                        color: Color(0xFF172033),
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'View all logos and brand identities you created earlier.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid(bool isDesktop) {
    final List<_FeatureItem> features = [
      const _FeatureItem(
        icon: Icons.auto_awesome,
        title: 'AI Logo Concepts',
        subtitle: 'Generate four unique logo concepts based on your business.',
        color: Color(0xFF2563EB),
      ),
      const _FeatureItem(
        icon: Icons.palette_outlined,
        title: 'Colour Palette',
        subtitle: 'Get professional primary, secondary and accent colours.',
        color: Color(0xFFE11D48),
      ),
      const _FeatureItem(
        icon: Icons.text_fields_rounded,
        title: 'Typography',
        subtitle: 'Discover matching heading and body font combinations.',
        color: Color(0xFF059669),
      ),
      const _FeatureItem(
        icon: Icons.picture_as_pdf_outlined,
        title: 'Brand Guidelines',
        subtitle: 'Create downloadable brand identity and usage guidelines.',
        color: Color(0xFF9333EA),
      ),
    ];

    return GridView.builder(
      itemCount: features.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: isDesktop ? 235 : 245,
      ),
      itemBuilder: (context, index) {
        return _featureCard(features[index]);
      },
    );
  }

  Widget _featureCard(_FeatureItem item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: item.color, size: 28),
          ),
          const Spacer(),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.subtitle,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How it works',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 20),
          _StepTile(
            number: '1',
            title: 'Tell us about your business',
            subtitle:
                'Enter your business name, industry, audience and brand personality.',
          ),
          _StepTile(
            number: '2',
            title: 'Choose a visual direction',
            subtitle:
                'Select your preferred logo type, style and colour direction.',
          ),
          _StepTile(
            number: '3',
            title: 'Generate your concepts',
            subtitle: 'Our AI creates four distinct logo concepts for review.',
          ),
          _StepTile(
            number: '4',
            title: 'Download your brand kit',
            subtitle:
                'Select a logo and download your complete brand identity.',
            showLine: false,
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class _StepTile extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final bool showLine;

  const _StepTile({
    required this.number,
    required this.title,
    required this.subtitle,
    this.showLine = true,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: LogoBrandHomeScreen.primaryBlue,
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: const Color(0xFFDCE3F2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 23),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, height: 1.4),
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
