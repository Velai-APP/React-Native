import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'brand_kit_screen.dart';
import 'logo_generation_screen.dart';

class SavedBrandKitsScreen extends StatelessWidget {
  const SavedBrandKitsScreen({super.key});

  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color brightBlue = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF172033);
  static const Color borderColor = Color(0xFFE3E8F2);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'My Brand Kits',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: user == null
          ? const _NotSignedInView()
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('brandProjects')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _ErrorView(message: snapshot.error.toString());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                documents = List.from(snapshot.data?.docs ?? []);

                // Sort locally to avoid requiring a composite
                // Firestore index for where + orderBy.
                documents.sort((first, second) {
                  final Timestamp? firstTime = _documentDate(first.data());

                  final Timestamp? secondTime = _documentDate(second.data());

                  return (secondTime?.millisecondsSinceEpoch ?? 0).compareTo(
                    firstTime?.millisecondsSinceEpoch ?? 0,
                  );
                });

                if (documents.isEmpty) {
                  return const _EmptyBrandKitsView();
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isDesktop = constraints.maxWidth >= 900;

                    return GridView.builder(
                      padding: EdgeInsets.all(isDesktop ? 30 : 16),
                      itemCount: documents.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : 1,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        mainAxisExtent: 390,
                      ),
                      itemBuilder: (context, index) {
                        final document = documents[index];

                        return _SavedBrandKitCard(
                          projectId: document.id,
                          data: document.data(),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  static Timestamp? _documentDate(Map<String, dynamic> data) {
    final dynamic updatedAt = data['updatedAt'];
    final dynamic completedAt = data['completedAt'];
    final dynamic createdAt = data['createdAt'];

    if (updatedAt is Timestamp) {
      return updatedAt;
    }

    if (completedAt is Timestamp) {
      return completedAt;
    }

    if (createdAt is Timestamp) {
      return createdAt;
    }

    return null;
  }
}

class _SavedBrandKitCard extends StatelessWidget {
  final String projectId;
  final Map<String, dynamic> data;

  const _SavedBrandKitCard({required this.projectId, required this.data});

  @override
  Widget build(BuildContext context) {
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

    final Map<String, dynamic> logoData = _mapValue(data['selectedLogo']);

    final String imageUrl = _stringValue(logoData['imageUrl'], fallback: '');

    final DateTime? updatedDate =
        _timestampValue(data['updatedAt'])?.toDate() ??
        _timestampValue(data['completedAt'])?.toDate() ??
        _timestampValue(data['createdAt'])?.toDate();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: SavedBrandKitsScreen.borderColor),
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
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.all(18),
              child: imageUrl.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: 55,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) {
                          return child;
                        }

                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey,
                            size: 55,
                          ),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        businessName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SavedBrandKitsScreen.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  industry,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SavedBrandKitsScreen.primaryBlue,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (tagline.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    tagline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (updatedDate != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        color: Colors.grey,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _formatDate(updatedDate),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _confirmDelete(context, projectId, businessName);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Color(0xFFFECACA)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          icon: const Icon(Icons.delete_outline, size: 19),
                          label: const Text('Delete'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 45,
                        child: FilledButton.icon(
                          onPressed: () {
                            _openBrandKit(context, projectId, data);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: SavedBrandKitsScreen.brightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          icon: const Icon(Icons.visibility_outlined, size: 19),
                          label: const Text('View Brand Kit', maxLines: 1),
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

  static void _openBrandKit(
    BuildContext context,
    String projectId,
    Map<String, dynamic> data,
  ) {
    final Map<String, dynamic> strategy = _mapValue(data['brandStrategy']);

    final Map<String, dynamic> selectedLogoData = _mapValue(
      data['selectedLogo'],
    );

    if (selectedLogoData.isEmpty ||
        _stringValue(selectedLogoData['imageUrl'], fallback: '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This saved project does not contain a selected logo.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final LogoConcept selectedLogo = LogoConcept.fromMap(selectedLogoData);

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
          tagline: _stringValue(data['tagline'], fallback: ''),
          personalities: _stringList(data['personalities']),
          brandValues: _stringList(data['brandValues']),
          brandVoice: _stringValue(
            data['brandVoice'],
            fallback: _stringValue(strategy['toneOfVoice'], fallback: ''),
          ),
          audienceFeeling: _stringValue(data['audienceFeeling'], fallback: ''),
          logoStyle: _stringValue(
            data['logoStyle'],
            fallback: selectedLogo.style,
          ),
          logoType: _stringValue(
            data['logoType'],
            fallback: selectedLogo.logoType,
          ),
          colorDirection: _stringValue(data['colorDirection'], fallback: ''),
          symbolPreference: _stringValue(
            data['symbolPreference'],
            fallback: '',
          ),
          fontStyle: _stringValue(
            data['fontStyle'],
            fallback: _stringValue(strategy['headingFont'], fallback: ''),
          ),
          selectedLogo: selectedLogo,
          brandStrategy: strategy,
        ),
      ),
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    String projectId,
    String businessName,
  ) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete brand kit?'),
          content: Text(
            'This will remove the saved brand kit for '
            '$businessName.',
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

    if (shouldDelete != true) {
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
          content: Text('Brand kit deleted.'),
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

  static String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');

    final String month = date.month.toString().padLeft(2, '0');

    return 'Updated $day/$month/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final bool completed = status.toLowerCase() == 'completed';

    final Color color = completed
        ? const Color(0xFF059669)
        : const Color(0xFFD97706);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EmptyBrandKitsView extends StatelessWidget {
  const _EmptyBrandKitsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 115,
              height: 115,
              decoration: BoxDecoration(
                color: SavedBrandKitsScreen.brightBlue.withOpacity(0.09),
                borderRadius: BorderRadius.circular(35),
              ),
              child: const Icon(
                Icons.palette_outlined,
                color: SavedBrandKitsScreen.brightBlue,
                size: 56,
              ),
            ),
            const SizedBox(height: 23),
            const Text(
              'No saved brand kits',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SavedBrandKitsScreen.textColor,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Create a logo and save the brand kit. '
              'It will appear here automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Brand Kit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotSignedInView extends StatelessWidget {
  const _NotSignedInView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Please sign in to view your saved brand kits.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 14),
            const Text(
              'Unable to load brand kits',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 9),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
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

Timestamp? _timestampValue(dynamic value) {
  return value is Timestamp ? value : null;
}
