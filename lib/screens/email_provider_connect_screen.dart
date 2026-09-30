import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'email_setup_screen.dart';

class EmailProviderConnectScreen extends StatefulWidget {
  final String businessName;
  final String domain;
  final String provider;
  final List<EmailSetupItem> emailItems;

  const EmailProviderConnectScreen({
    super.key,
    required this.businessName,
    required this.domain,
    required this.provider,
    required this.emailItems,
  });

  @override
  State<EmailProviderConnectScreen> createState() =>
      _EmailProviderConnectScreenState();
}

class _EmailProviderConnectScreenState
    extends State<EmailProviderConnectScreen> {
  bool _loading = false;
  String? _error;

  bool get isGoogle =>
      widget.provider.toLowerCase().contains('google');

  Future<void> _continueSetup() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final emails = widget.emailItems
          .map((item) => item.toJson())
          .toList();

final functionName = isGoogle
    ? 'startGoogleWorkspaceSetup'
    : 'startMicrosoft365Setup';

final callable = FirebaseFunctions.instanceFor(
  region: 'asia-south1',
).httpsCallable(functionName);

      final result = await callable.call({
        'businessName': widget.businessName.trim(),
        'domain': widget.domain.trim().toLowerCase(),
        'provider': widget.provider,
        'emails': emails,
      });

      final rawData = result.data;

      if (rawData == null) {
        throw Exception(
          'The server returned an empty response.',
        );
      }

      final data = Map<String, dynamic>.from(
        rawData as Map,
      );

      final String? authorizationUrl =
          data['authorizationUrl']?.toString() ??
          data['authUrl']?.toString() ??
          data['signupUrl']?.toString() ??
          data['url']?.toString();

      if (authorizationUrl == null ||
          authorizationUrl.trim().isEmpty) {
        throw Exception(
          'No authorization URL was returned by the server.',
        );
      }

      final uri = Uri.tryParse(authorizationUrl);

      if (uri == null) {
        throw Exception(
          'The server returned an invalid authorization URL.',
        );
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception(
          'Unable to open the provider authorization page.',
        );
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
        'Firebase Functions error: '
        '${e.code} ${e.message} ${e.details}',
      );

      if (!mounted) return;

      setState(() {
        _error = e.message ??
            'Unable to start the email setup.';
      });
    } catch (e, stackTrace) {
      debugPrint(
        'Email provider setup error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerName =
        isGoogle ? 'Google Workspace' : 'Microsoft 365';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
          onPressed: _loading
              ? null
              : () => Navigator.pop(context),
        ),
        title: Text(
          'Connect $providerName',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF171B2C),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            40,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _providerCard(providerName),

              const SizedBox(height: 28),

              const Text(
                'Ready to connect',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF171B2C),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Velai will securely redirect you to '
                '$providerName to continue your business '
                'email setup.',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF7A8092),
                ),
              ),

              const SizedBox(height: 25),

              _infoCard(
                icon: Icons.business_rounded,
                title: 'Business',
                value: widget.businessName,
              ),

              const SizedBox(height: 12),

              _infoCard(
                icon: Icons.language_rounded,
                title: 'Domain',
                value: widget.domain,
              ),

              const SizedBox(height: 12),

              _infoCard(
                icon: Icons.email_rounded,
                title: 'Email addresses',
                value:
                    '${widget.emailItems.length} configured',
              ),

              const SizedBox(height: 24),

              _securityCard(providerName),

              if (_error != null) ...[
                const SizedBox(height: 18),
                _errorCard(),
              ],

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed:
                      _loading ? null : _continueSetup,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                        const Color(0xFF625BE8),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFAAA7E8),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue with $providerName',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 9),
                            const Icon(
                              Icons
                                  .arrow_forward_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 14),

              const Center(
                child: Text(
                  'Velai never stores your provider password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF8B90A0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _providerCard(String providerName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5751E6),
            Color(0xFF8067F4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF625BE8).withOpacity(.20),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: isGoogle
                  ? const Text(
                      'G',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : const Icon(
                      Icons.window_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  providerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.domain,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.security_rounded,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE9EAF0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBFF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF625BE8),
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF858A9A),
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF202436),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _securityCard(String providerName) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF5FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: Color(0xFF3775CA),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You will sign in directly with '
              '$providerName. Velai only receives '
              'the authorization required to continue '
              'your email setup.',
              style: const TextStyle(
                color: Color(0xFF526B8D),
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFD94C4C),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFF9B3535),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}