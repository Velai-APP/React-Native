import 'package:flutter/material.dart';
import 'email_setup_screen.dart';

class EmailProviderScreen extends StatefulWidget {
  final String businessName;
  final String domain;
  final List<String> selectedEmails;

  const EmailProviderScreen({
    super.key,
    required this.businessName,
    required this.domain,
    required this.selectedEmails,
  });

  @override
  State<EmailProviderScreen> createState() =>
      _EmailProviderScreenState();
}
class _EmailProviderScreenState extends State<EmailProviderScreen> {
  String? selectedProvider;

  final List<EmailProvider> providers = const [
    EmailProvider(
      id: 'google',
      name: 'Google Workspace',
      description: 'Professional Gmail for your business',
      icon: Icons.g_mobiledata_rounded,
      features: [
        'Business Gmail',
        'Google Drive',
        'Meet & Calendar',
      ],
    ),
    EmailProvider(
      id: 'microsoft',
      name: 'Microsoft 365',
      description: 'Professional Outlook for your business',
      icon: Icons.window_rounded,
      features: [
        'Business Outlook',
        'OneDrive',
        'Office apps',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 130),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(),

                    const SizedBox(height: 30),

                    const Text(
                      'Choose your email provider',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF171B2C),
                        letterSpacing: -0.4,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Your selected email will be created with the '
                      'provider you choose.',
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: Color(0xFF777D91),
                      ),
                    ),

                    const SizedBox(height: 20),

                    ...providers.map(_buildProviderCard),

                    const SizedBox(height: 16),

                    _buildExistingProviderCard(),

                    const SizedBox(height: 24),

                    _buildSecurityCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP BAR
  // ---------------------------------------------------------------------------

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
            ),
          ),
          const Expanded(
            child: Text(
              'Business Email',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171B2C),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HERO
  // ---------------------------------------------------------------------------

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5C55E7),
            Color(0xFF7C64F4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C55E7).withOpacity(.20),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
  children: [
    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        '${widget.selectedEmails.length} '
        '${widget.selectedEmails.length == 1 ? 'EMAIL' : 'EMAILS'} SELECTED',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: .8,
        ),
      ),
    ),

    const SizedBox(height: 18),

    ...widget.selectedEmails.map(
      (email) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(.10),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFFC8FFDB),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                email,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),

    const SizedBox(height: 8),

    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.language_rounded,
          size: 15,
          color: Colors.white70,
        ),
        const SizedBox(width: 6),
        Text(
          widget.domain,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    ),
  ],
)
    );
  }

  // ---------------------------------------------------------------------------
  // PROVIDER CARD
  // ---------------------------------------------------------------------------

  Widget _buildProviderCard(EmailProvider provider) {
    final bool selected = selectedProvider == provider.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedProvider = provider.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF2F1FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? const Color(0xFF625BE8)
                : const Color(0xFFE9EAF1),
            width: selected ? 1.7 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.035),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _providerLogo(provider),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              provider.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1E30),
                              ),
                            ),
                          ),

                          if (provider.id == 'google') ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9E7FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .4,
                                  color: Color(0xFF5C55E7),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        provider.description,
                        style: const TextStyle(
                          color: Color(0xFF7A8094),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? const Color(0xFF625BE8)
                        : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF625BE8)
                          : const Color(0xFFC8CBD6),
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(
              height: 1,
              color: Color(0xFFEEEFF5),
            ),

            const SizedBox(height: 14),

            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: provider.features.map((feature) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withOpacity(.75)
                        : const Color(0xFFF7F8FB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    feature,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF646A7C),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _providerLogo(EmailProvider provider) {
    if (provider.id == 'google') {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'G',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4285F4),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        provider.icon,
        size: 27,
        color: const Color(0xFF1473E6),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EXISTING PROVIDER
  // ---------------------------------------------------------------------------

  Widget _buildExistingProviderCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        // TODO:
        // Navigate to existing provider connection screen.
      },
      child: Ink(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE8EAF1),
          ),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 45,
              height: 45,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFF2F3F8),
                  borderRadius: BorderRadius.all(
                    Radius.circular(14),
                  ),
                ),
                child: Icon(
                  Icons.link_rounded,
                  color: Color(0xFF60677A),
                ),
              ),
            ),

            SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Already have an email provider?',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF222638),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Connect your existing business email',
                    style: TextStyle(
                      color: Color(0xFF858A9A),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF9A9EAD),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECURITY
  // ---------------------------------------------------------------------------

  Widget _buildSecurityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF8F3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: Color(0xFF25885D),
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your email will be hosted securely by the provider '
              'you select. Provider subscription charges may apply.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: Color(0xFF497060),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM CTA
  // ---------------------------------------------------------------------------

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 25,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: ElevatedButton(
            onPressed: selectedProvider == null
                ? null
                : _continueSetup,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF625BE8),
              disabledBackgroundColor: const Color(0xFFE3E4EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedProvider == null
                      ? 'Select a provider'
                      : 'Continue setup',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (selectedProvider != null) ...[
                  const SizedBox(width: 9),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _continueSetup() {
    if (selectedProvider == null) return;

   
    debugPrint('Domain: ${widget.domain}');
    debugPrint('Provider: $selectedProvider');

    
 Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => EmailSetupScreen(
      businessName: widget.businessName,
      domain: widget.domain,
      selectedEmails: widget.selectedEmails,
      provider: selectedProvider!,
    ),
  ),
);
    
  }
}

// =============================================================================
// MODEL
// =============================================================================

class EmailProvider {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<String> features;

  const EmailProvider({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.features,
  });
}