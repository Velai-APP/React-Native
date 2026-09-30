import 'package:flutter/material.dart';

// Import these from email_setup_screen.dart if already defined there.
import 'email_setup_screen.dart';
import 'email_provider_connect_screen.dart';

class EmailSetupReviewScreen extends StatelessWidget {
 final String businessName;
  final String domain;
  final String provider;
  final List<EmailSetupItem> emailItems;

  const EmailSetupReviewScreen({
    super.key,
    required this.businessName,
    required this.domain,
    required this.provider,
    required this.emailItems,
  });

  bool get isGoogle => provider.toLowerCase() == 'google';

  List<EmailSetupItem> get mailboxes => emailItems
      .where((e) => e.type == BusinessEmailType.mailbox)
      .toList();

  List<EmailSetupItem> get aliases => emailItems
      .where((e) => e.type == BusinessEmailType.alias)
      .toList();

  List<EmailSetupItem> get groups => emailItems
      .where((e) => e.type == BusinessEmailType.group)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  140,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroCard(),

                    const SizedBox(height: 28),

                    const Text(
                      'Review your setup',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.5,
                        color: Color(0xFF171B2C),
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Check everything before we continue '
                      'with your email provider.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF7A8092),
                      ),
                    ),

                    const SizedBox(height: 22),

                    if (mailboxes.isNotEmpty) ...[
                      _sectionTitle(
                        icon: Icons.inbox_rounded,
                        title: 'INBOXES',
                        count: mailboxes.length,
                      ),
                      const SizedBox(height: 10),
                      ...mailboxes.map(_mailboxCard),
                      const SizedBox(height: 20),
                    ],

                    if (aliases.isNotEmpty) ...[
                      _sectionTitle(
                        icon: Icons.call_split_rounded,
                        title: 'ALIASES',
                        count: aliases.length,
                      ),
                      const SizedBox(height: 10),
                      ...aliases.map(_aliasCard),
                      const SizedBox(height: 20),
                    ],

                    if (groups.isNotEmpty) ...[
                      _sectionTitle(
                        icon: Icons.groups_rounded,
                        title: 'GROUPS',
                        count: groups.length,
                      ),
                      const SizedBox(height: 10),
                      ...groups.map(_groupCard),
                      const SizedBox(height: 20),
                    ],

                    _setupSummary(),

                    const SizedBox(height: 18),

                    _providerNotice(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _bottomBar(context),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP BAR
  // ---------------------------------------------------------------------------

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 18, 5),
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
              'Review Setup',
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

  Widget _heroCard() {
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
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF625BE8).withOpacity(.20),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Center(
                  child: isGoogle
                      ? const Text(
                          'G',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : const Icon(
                          Icons.window_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGoogle
                          ? 'Google Workspace'
                          : 'Microsoft 365',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      businessName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.11),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.language_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    domain,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFFC9FFDB),
                  size: 19,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION TITLE
  // ---------------------------------------------------------------------------

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required int count,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: const Color(0xFF625BE8),
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: .8,
            color: Color(0xFF6C7182),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEDEBFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF625BE8),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // MAILBOX
  // ---------------------------------------------------------------------------

  Widget _mailboxCard(EmailSetupItem item) {
    return _emailCard(
      icon: Icons.inbox_rounded,
      iconBackground: const Color(0xFFEDEBFF),
      iconColor: const Color(0xFF625BE8),
      email: item.email,
      subtitle: 'Separate inbox & login',
      badge: 'INBOX',
    );
  }

  // ---------------------------------------------------------------------------
  // ALIAS
  // ---------------------------------------------------------------------------

  Widget _aliasCard(EmailSetupItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              _iconBox(
                Icons.call_split_rounded,
                const Color(0xFFE9F7F1),
                const Color(0xFF269267),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.email,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF202436),
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Email alias',
                      style: TextStyle(
                        color: Color(0xFF84899A),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              _badge(
                'ALIAS',
                const Color(0xFFE9F7F1),
                const Color(0xFF24865F),
              ),
            ],
          ),

          if (item.deliverTo != null) ...[
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FB),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.subdirectory_arrow_right_rounded,
                    size: 19,
                    color: Color(0xFF8B90A0),
                  ),
                  const SizedBox(width: 9),
                  const Text(
                    'Delivers to',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF8A8F9F),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      item.deliverTo!,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF34394B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // GROUP
  // ---------------------------------------------------------------------------

  Widget _groupCard(EmailSetupItem item) {
    return _emailCard(
      icon: Icons.groups_rounded,
      iconBackground: const Color(0xFFFFF3DF),
      iconColor: const Color(0xFFCA7B16),
      email: item.email,
      subtitle: 'Multiple recipients',
      badge: 'GROUP',
    );
  }

  // ---------------------------------------------------------------------------
  // GENERIC CARD
  // ---------------------------------------------------------------------------

  Widget _emailCard({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String email,
    required String subtitle,
    required String badge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _iconBox(
            icon,
            iconBackground,
            iconColor,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF202436),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF858A9A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          _badge(
            badge,
            iconBackground,
            iconColor,
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(
        color: const Color(0xFFE9EAF0),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.025),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _iconBox(
    IconData icon,
    Color background,
    Color color,
  ) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        icon,
        color: color,
        size: 21,
      ),
    );
  }

  Widget _badge(
    String text,
    Color background,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: .4,
          color: color,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY
  // ---------------------------------------------------------------------------

  Widget _setupSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F34),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Setup summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _summaryNumber(
                  mailboxes.length,
                  'Inboxes',
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _summaryNumber(
                  aliases.length,
                  'Aliases',
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _summaryNumber(
                  groups.length,
                  'Groups',
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  color: Color(0xFFBDB9FF),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${mailboxes.length} separate '
                    '${mailboxes.length == 1 ? 'inbox' : 'inboxes'} '
                    'may require provider licensing.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryNumber(
    int count,
    String title,
  ) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 38,
      width: 1,
      color: Colors.white.withOpacity(.10),
    );
  }

  // ---------------------------------------------------------------------------
  // PROVIDER NOTICE
  // ---------------------------------------------------------------------------

  Widget _providerNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF5FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF3775CA),
            size: 21,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'Next, you\'ll connect with '
              '${isGoogle ? 'Google Workspace' : 'Microsoft 365'} '
              'to continue account, subscription and domain setup. '
              'No provider password should be stored by Velai.',
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

  // ---------------------------------------------------------------------------
  // BOTTOM CTA
  // ---------------------------------------------------------------------------

  Widget _bottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20,
      ),
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
            onPressed: () {
              _continueProviderSetup(context);
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF625BE8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  isGoogle
                      ? 'Continue with Google'
                      : 'Continue with Microsoft',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 9),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

 void _continueProviderSetup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmailProviderConnectScreen(
          businessName: businessName,
          domain: domain,
          provider: provider,
          emailItems: emailItems,
        ),
      ),
    );
  }
}