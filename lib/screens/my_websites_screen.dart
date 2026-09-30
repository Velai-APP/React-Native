import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MyWebsitesScreen extends StatefulWidget {
  const MyWebsitesScreen({super.key, this.highlightedWebsiteId});

  /// Pass the newly-created Firestore website document ID here.
  /// The matching card will be highlighted.
  final String? highlightedWebsiteId;

  @override
  State<MyWebsitesScreen> createState() => _MyWebsitesScreenState();
}

class _MyWebsitesScreenState extends State<MyWebsitesScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>> _websiteStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('websites')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _openWebsite(String? url) async {
    final cleanUrl = url?.trim() ?? '';

    if (cleanUrl.isEmpty) {
      _showMessage('Website link is not available yet.');
      return;
    }

    final uri = Uri.tryParse(cleanUrl);

    if (uri == null) {
      _showMessage('Invalid website link.');
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      _showMessage('Unable to open the website.');
    }
  }

  Future<void> _copyWebsiteLink(String? url) async {
    final cleanUrl = url?.trim() ?? '';

    if (cleanUrl.isEmpty) {
      _showMessage('Website link is not available yet.');
      return;
    }

    await Clipboard.setData(ClipboardData(text: cleanUrl));

    if (!mounted) return;
    _showMessage('Website link copied.');
  }

  Future<void> _deleteWebsite({
    required String websiteId,
    required String businessName,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Delete website?'),
          content: Text(
            'Are you sure you want to remove $businessName from your website list?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE34D59),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('websites')
          .doc(websiteId)
          .delete();

      if (!mounted) return;
      _showMessage('Website removed.');
    } on FirebaseException catch (error) {
      if (!mounted) return;
      _showMessage(error.message ?? 'Unable to delete the website.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
  }

  void _showWebsiteDetails({
    required String websiteId,
    required Map<String, dynamic> data,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _WebsiteDetailsSheet(
          websiteId: websiteId,
          data: data,
          onOpenWebsite: () {
            Navigator.pop(sheetContext);
            _openWebsite(data['netlifyUrl']?.toString());
          },
          onCopyWebsite: () {
            Navigator.pop(sheetContext);
            _copyWebsiteLink(data['netlifyUrl']?.toString());
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        backgroundColor: const Color(0xFF6C4DFF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Create website',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _PageBackground()),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: currentUser == null
                      ? const _SignedOutState()
                      : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _websiteStream(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return _ErrorState(
                                message:
                                    'Unable to load websites.\n${snapshot.error}',
                              );
                            }

                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF6C4DFF),
                                ),
                              );
                            }

                            final documents = snapshot.data!.docs;

                            final liveCount = documents.where((document) {
                              final data = document.data();
                              final status =
                                  data['status']?.toString().trim() ?? '';
                              final url =
                                  data['netlifyUrl']?.toString().trim() ?? '';

                              return status == 'completed' || url.isNotEmpty;
                            }).length;

                            final buildingCount = documents.where((document) {
                              final data = document.data();
                              final url =
                                  data['netlifyUrl']?.toString().trim() ?? '';

                              if (url.isNotEmpty) {
                                return false;
                              }

                              final status =
                                  data['status']?.toString().trim() ?? 'queued';

                              return status == 'queued' ||
                                  status == 'generating' ||
                                  status == 'designing' ||
                                  status == 'deploying';
                            }).length;

                            return ListView(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                10,
                                20,
                                120,
                              ),
                              children: [
                                _buildSummaryCard(
                                  totalCount: documents.length,
                                  liveCount: liveCount,
                                  generatingCount: buildingCount,
                                ),
                                const SizedBox(height: 22),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'All websites',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF252332),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFE7E6EE),
                                        ),
                                      ),
                                      child: Text(
                                        '${documents.length} websites',
                                        style: const TextStyle(
                                          color: Color(0xFF6F6D7E),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                if (documents.isEmpty)
                                  const _EmptyWebsitesState()
                                else
                                  ...documents.map((document) {
                                    final data = document.data();

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: WebsiteFirestoreCard(
                                        websiteId: document.id,
                                        data: data,
                                        highlighted:
                                            document.id ==
                                            widget.highlightedWebsiteId,
                                        onOpen: () => _openWebsite(
                                          data['netlifyUrl']?.toString(),
                                        ),
                                        onCopy: () => _copyWebsiteLink(
                                          data['netlifyUrl']?.toString(),
                                        ),
                                        onDelete: () => _deleteWebsite(
                                          websiteId: document.id,
                                          businessName:
                                              data['businessName']
                                                  ?.toString() ??
                                              'this website',
                                        ),
                                        onViewDetails: () =>
                                            _showWebsiteDetails(
                                              websiteId: document.id,
                                              data: data,
                                            ),
                                      ),
                                    );
                                  }),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE8E7EF)),
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Websites',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: Color(0xFF201E2E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'View live progress and published links',
                  style: TextStyle(fontSize: 13, color: Color(0xFF77758A)),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF0ECFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.cloud_done_outlined,
              color: Color(0xFF6C4DFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required int totalCount,
    required int liveCount,
    required int generatingCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF18152E), Color(0xFF3E2B79), Color(0xFF6C4DFF)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x306C4DFF),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.language_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Website Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _SummaryValue(
                  label: 'Total',
                  value: '$totalCount',
                  icon: Icons.web_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryValue(
                  label: 'Live',
                  value: '$liveCount',
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryValue(
                  label: 'Building',
                  value: '$generatingCount',
                  icon: Icons.auto_awesome_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WebsiteFirestoreCard extends StatelessWidget {
  const WebsiteFirestoreCard({
    super.key,
    required this.websiteId,
    required this.data,
    required this.highlighted,
    required this.onOpen,
    required this.onCopy,
    required this.onDelete,
    required this.onViewDetails,
  });

  final String websiteId;
  final Map<String, dynamic> data;
  final bool highlighted;
  final VoidCallback onOpen;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final businessName = data['businessName']?.toString() ?? 'Untitled website';

    final businessType = data['businessType']?.toString() ?? '';

    final template = data['template']?.toString() ?? 'Modern';

    final url = data['netlifyUrl']?.toString().trim();

    final storedStatus = data['status']?.toString().trim();

    final status = storedStatus?.isNotEmpty == true
        ? storedStatus!
        : (url?.isNotEmpty == true ? 'completed' : 'queued');

    final progress =
        (data['progress'] as num?)?.toDouble() ??
        (status == 'completed' ? 100 : 5);

    final rawMessage = data['statusMessage']?.toString().trim() ?? '';

    final statusMessage = rawMessage.isNotEmpty
        ? rawMessage
        : status == 'completed'
        ? 'Your website is ready'
        : 'Waiting in queue';

    final errorMessage = data['errorMessage']?.toString();

    final createdAt = _timestampToDate(data['createdAt']);

    final completed = status == 'completed' && url != null && url.isNotEmpty;

    final failed = status == 'failed';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: highlighted
                  ? const Color(0xFF6C4DFF)
                  : const Color(0xFFE9E8F0),
              width: highlighted ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: highlighted
                    ? const Color(0x226C4DFF)
                    : const Color(0x0D000000),
                blurRadius: 24,
                offset: const Offset(0, 10),
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
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: completed
                            ? const [Color(0xFF3ED6A5), Color(0xFF009D78)]
                            : failed
                            ? const [Color(0xFFFF7878), Color(0xFFD93F4B)]
                            : const [Color(0xFF8B62FF), Color(0xFF5B42E8)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      completed
                          ? Icons.language_rounded
                          : failed
                          ? Icons.error_outline_rounded
                          : Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          businessName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF292736),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          businessType,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF7C798A),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FirestoreStatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _WebsiteInformationChip(
                    icon: Icons.dashboard_customize_outlined,
                    text: template,
                  ),
                  _WebsiteInformationChip(
                    icon: Icons.schedule_rounded,
                    text: _formatCreatedAt(createdAt),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                statusMessage,
                style: TextStyle(
                  color: completed
                      ? const Color(0xFF008B69)
                      : failed
                      ? const Color(0xFFC83E49)
                      : const Color(0xFF6042DD),
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!completed && !failed) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: (progress / 100).clamp(0.0, 1.0),
                    minHeight: 9,
                    backgroundColor: const Color(0xFFECE9FA),
                    color: const Color(0xFF6C4DFF),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${progress.toInt()}% completed',
                  style: const TextStyle(
                    color: Color(0xFF858293),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (completed) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2DCF9)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link_rounded, color: Color(0xFF6C4DFF)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF423C61),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: onCopy,
                        icon: const Icon(Icons.copy_rounded, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onOpen,
                        icon: const Icon(Icons.open_in_new_rounded, size: 19),
                        label: const Text('Open website'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF6C4DFF),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PopupMenuButton<String>(
                      tooltip: 'More options',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onSelected: (value) {
                        if (value == 'details') {
                          onViewDetails();
                        } else if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded),
                              SizedBox(width: 10),
                              Text('View details'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: Color(0xFFE34D59),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Delete',
                                style: TextStyle(color: Color(0xFFE34D59)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              if (failed) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD2D6)),
                  ),
                  child: Text(
                    errorMessage ?? 'Website generation failed.',
                    style: const TextStyle(
                      color: Color(0xFFB93844),
                      height: 1.45,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFE34D59),
                    ),
                    label: const Text('Remove'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static DateTime? _timestampToDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  static String _formatCreatedAt(DateTime? date) {
    if (date == null) {
      return 'Just now';
    }

    final difference = DateTime.now().difference(date);

    if (difference.isNegative || difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    return '${difference.inDays}d ago';
  }
}

class _WebsiteDetailsSheet extends StatelessWidget {
  const _WebsiteDetailsSheet({
    required this.websiteId,
    required this.data,
    required this.onOpenWebsite,
    required this.onCopyWebsite,
  });

  final String websiteId;
  final Map<String, dynamic> data;
  final VoidCallback onOpenWebsite;
  final VoidCallback onCopyWebsite;

  @override
  Widget build(BuildContext context) {
    final url = data['netlifyUrl']?.toString().trim();

    final storedStatus = data['status']?.toString().trim();

    final status = storedStatus?.isNotEmpty == true
        ? storedStatus!
        : (url?.isNotEmpty == true ? 'completed' : 'queued');

    final completed = status == 'completed' && url != null && url.isNotEmpty;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 80, 12, 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDAD8E2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                data['businessName']?.toString() ?? 'Untitled website',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF252332),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data['businessType']?.toString() ?? '',
                style: const TextStyle(color: Color(0xFF77758A), fontSize: 14),
              ),
              const SizedBox(height: 24),
              _DetailsRow(label: 'Status', value: _statusLabel(status)),
              _DetailsRow(
                label: 'Progress',
                value: '${(data['progress'] as num?)?.toInt() ?? 0}%',
              ),
              _DetailsRow(
                label: 'Template',
                value: data['template']?.toString() ?? 'Modern',
              ),
              _DetailsRow(label: 'Phone', value: _displayValue(data['phone'])),
              _DetailsRow(label: 'Email', value: _displayValue(data['email'])),
              _DetailsRow(
                label: 'Address',
                value: _displayValue(data['address']),
              ),
              _DetailsRow(label: 'Website ID', value: websiteId),
              _DetailsRow(
                label: 'Website URL',
                value: _displayValue(url, fallback: 'Not available'),
              ),
              _DetailsRow(
                label: 'Custom domain',
                value: _displayValue(
                  data['customDomain'],
                  fallback: 'Not connected',
                ),
              ),
              if (completed && url?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onOpenWebsite,
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Open live website'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: const Color(0xFF6C4DFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onCopyWebsite,
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy website link'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _displayValue(
    dynamic value, {
    String fallback = 'Not provided',
  }) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Live';
      case 'failed':
        return 'Failed';
      case 'queued':
        return 'Queued';
      case 'generating':
        return 'Generating';
      case 'designing':
        return 'Designing';
      case 'deploying':
        return 'Deploying';
      default:
        return status;
    }
  }
}

class _FirestoreStatusBadge extends StatelessWidget {
  const _FirestoreStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    String label;
    Color background;
    Color foreground;

    switch (status) {
      case 'completed':
        label = 'Live';
        background = const Color(0xFFE6FAF4);
        foreground = const Color(0xFF008B69);
        break;
      case 'failed':
        label = 'Failed';
        background = const Color(0xFFFFEAEC);
        foreground = const Color(0xFFC83E49);
        break;
      case 'queued':
        label = 'Queued';
        background = const Color(0xFFFFF3D6);
        foreground = const Color(0xFFA26B00);
        break;
      case 'deploying':
        label = 'Deploying';
        background = const Color(0xFFEAF2FF);
        foreground = const Color(0xFF2459B5);
        break;
      case 'designing':
        label = 'Designing';
        background = const Color(0xFFF0ECFF);
        foreground = const Color(0xFF6042DD);
        break;
      case 'generating':
        label = 'Building';
        background = const Color(0xFFF0ECFF);
        foreground = const Color(0xFF6042DD);
        break;
      default:
        label = 'Building';
        background = const Color(0xFFF0ECFF);
        foreground = const Color(0xFF6042DD);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 21, color: Colors.white.withValues(alpha: 0.85)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WebsiteInformationChip extends StatelessWidget {
  const _WebsiteInformationChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6FA),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF77758A)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF666475),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7C798A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF333143),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWebsitesState extends StatelessWidget {
  const _EmptyWebsitesState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE9E8F0)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.web_asset_off_outlined,
            size: 58,
            color: Color(0xFF9C98AE),
          ),
          SizedBox(height: 18),
          Text(
            'No websites available',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first AI-generated website.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF77758A)),
          ),
        ],
      ),
    );
  }
}

class _SignedOutState extends StatelessWidget {
  const _SignedOutState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Please sign in to view your websites.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _PageBackground extends StatelessWidget {
  const _PageBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5FA),
      child: Stack(
        children: [
          Positioned(
            top: -130,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x176C4DFF),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1200A67E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
