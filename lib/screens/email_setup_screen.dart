import 'package:flutter/material.dart';
import 'email_setup_review_screen.dart';
enum BusinessEmailType {
  mailbox,
  alias,
  group,
}

class EmailSetupItem {
  final String email;
  final BusinessEmailType type;
  final String? deliverTo;

  const EmailSetupItem({
    required this.email,
    required this.type,
    this.deliverTo,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim(),
      'type': type.name,
      if (deliverTo != null && deliverTo!.trim().isNotEmpty)
        'deliverTo': deliverTo!.trim(),
    };
  }

  factory EmailSetupItem.fromJson(Map<String, dynamic> json) {
    return EmailSetupItem(
      email: (json['email'] ?? '').toString(),
      type: BusinessEmailType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => BusinessEmailType.mailbox,
      ),
      deliverTo: json['deliverTo']?.toString(),
    );
  }

  EmailSetupItem copyWith({
    String? email,
    BusinessEmailType? type,
    String? deliverTo,
  }) {
    return EmailSetupItem(
      email: email ?? this.email,
      type: type ?? this.type,
      deliverTo: deliverTo ?? this.deliverTo,
    );
  }
}



class EmailSetupScreen extends StatefulWidget {
  final String businessName;
  final String domain;
  final List<String> selectedEmails;
  final String provider;

  
  


  const EmailSetupScreen({
    super.key,
    required this.businessName,
    required this.domain,
    required this.selectedEmails,
    required this.provider,
  });

  @override
  State<EmailSetupScreen> createState() => _EmailSetupScreenState();
}

class _EmailSetupScreenState extends State<EmailSetupScreen> {
  late List<EmailSetupItem> emailItems;

  @override
  void initState() {
    super.initState();

    emailItems = widget.selectedEmails
        .map(
          (email) => EmailSetupItem(
            email: email,
            type: BusinessEmailType.mailbox,
          ),
        )
        .toList();
  }

  

  int get mailboxCount =>
      emailItems.where((e) => e.type == BusinessEmailType.mailbox).length;

  int get aliasCount =>
      emailItems.where((e) => e.type == BusinessEmailType.alias).length;

  int get groupCount =>
      emailItems.where((e) => e.type == BusinessEmailType.group).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroCard(),

                    const SizedBox(height: 28),

                    const Text(
                      'How should each email work?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.4,
                        color: Color(0xFF171B2C),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Choose whether each address needs its own inbox '
                      'or should route messages to another address.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF777D91),
                      ),
                    ),

                    const SizedBox(height: 22),

                    ...List.generate(
                      emailItems.length,
                      (index) => _emailConfigurationCard(
                        emailItems[index],
                        index,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _summaryCard(),

                    const SizedBox(height: 18),

                    _infoCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP BAR
  // ---------------------------------------------------------------------------

  Widget _topBar() {
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
              'Email Setup',
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
    final bool google = widget.provider.toLowerCase() == 'google';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5953E7),
            Color(0xFF826AF5),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: google
                      ? const Text(
                          'G',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : const Icon(
                          Icons.window_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      google
                          ? 'Google Workspace'
                          : 'Microsoft 365',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      widget.businessName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${emailItems.length} emails',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(
                Icons.language_rounded,
                color: Colors.white70,
                size: 17,
              ),
              const SizedBox(width: 7),
              Text(
                widget.domain,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMAIL CARD
  // ---------------------------------------------------------------------------

  Widget _emailConfigurationCard(
    EmailSetupItem item,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8EAF1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EFFF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.alternate_email_rounded,
                  color: Color(0xFF625BE8),
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  item.email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B1F31),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _typeButton(
                  item,
                  BusinessEmailType.mailbox,
                  Icons.inbox_rounded,
                  'Inbox',
                  index,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _typeButton(
                  item,
                  BusinessEmailType.alias,
                  Icons.call_split_rounded,
                  'Alias',
                  index,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _typeButton(
                  item,
                  BusinessEmailType.group,
                  Icons.groups_rounded,
                  'Group',
                  index,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _configurationDetails(item, index),
          ),
        ],
      ),
    );
  }

Widget _typeButton(
  EmailSetupItem item,
  BusinessEmailType type,
  IconData icon,
  String label,
  int index,
) {
  final selected = item.type == type;

  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: () {
      setState(() {
        emailItems[index] = emailItems[index].copyWith(
          type: type,
          deliverTo: null,
        );
      });
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFEFEEFF)
            : const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? const Color(0xFF625BE8)
              : const Color(0xFFEAEBF1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: selected
                ? const Color(0xFF625BE8)
                : const Color(0xFF8A8FA1),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: selected
                  ? const Color(0xFF625BE8)
                  : const Color(0xFF74798A),
            ),
          ),
        ],
      ),
    ),
  );
}

  // ---------------------------------------------------------------------------
  // CONFIGURATION
  // ---------------------------------------------------------------------------

  Widget _configurationDetails(
    EmailSetupItem item,
    int index,
  ) {
    if (item.type == BusinessEmailType.mailbox) {
      return Container(
        key: const ValueKey('mailbox'),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.inbox_outlined,
              color: Color(0xFF625BE8),
              size: 19,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'This address will have its own inbox and login.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: Color(0xFF656B7E),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (item.type == BusinessEmailType.alias) {
      return _destinationDropdown(
        key: const ValueKey('alias'),
        item: item,
        index: index,
        title: 'Deliver emails to',
        icon: Icons.forward_to_inbox_rounded,
      );
    }

    return Container(
      key: const ValueKey('group'),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.groups_2_outlined,
            color: Color(0xFF625BE8),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You can select multiple recipients for this '
              'group in the next step.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: Color(0xFF656B7E),
              ),
            ),
          ),
        ],
      ),
    );
  }

 Widget _destinationDropdown({
  required Key key,
  required EmailSetupItem item,
  required int index,
  required String title,
  required IconData icon,
}) {
  final availableMailboxes = emailItems
      .where(
        (e) =>
            e.type == BusinessEmailType.mailbox &&
            e.email != item.email,
      )
      .map((e) => e.email)
      .toList();

  return Container(
    key: key,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F8FC),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF625BE8),
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF656B7E),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        DropdownButtonFormField<String>(
          value: availableMailboxes.contains(item.deliverTo)
              ? item.deliverTo
              : null,

          isExpanded: true,

          hint: Text(
            availableMailboxes.isEmpty
                ? 'Create an inbox first'
                : 'Select destination inbox',
          ),

          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),

          items: availableMailboxes
              .map(
                (email) => DropdownMenuItem<String>(
                  value: email,
                  child: Text(
                    email,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),

          onChanged: availableMailboxes.isEmpty
              ? null
              : (value) {
                  setState(() {
                    emailItems[index] =
                        emailItems[index].copyWith(
                      deliverTo: value,
                    );
                  });
                },
        ),
      ],
    ),
  );
}
  // ---------------------------------------------------------------------------
  // SUMMARY
  // ---------------------------------------------------------------------------

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF191D32),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Setup summary',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  mailboxCount.toString(),
                  'Inboxes',
                  Icons.inbox_rounded,
                ),
              ),
              Expanded(
                child: _summaryItem(
                  aliasCount.toString(),
                  'Aliases',
                  Icons.call_split_rounded,
                ),
              ),
              Expanded(
                child: _summaryItem(
                  groupCount.toString(),
                  'Groups',
                  Icons.groups_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
    String number,
    String title,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFFB8B4FF),
          size: 21,
        ),
        const SizedBox(height: 7),
        Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E9),
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFFB87917),
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Separate inboxes may require additional provider '
              'licenses. Aliases can route messages to an existing '
              'inbox without creating another login, subject to '
              'your provider\'s plan.',
              style: TextStyle(
                color: Color(0xFF80662E),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM
  // ---------------------------------------------------------------------------

  Widget _bottomBar() {
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
            onPressed: _continue,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF625BE8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Review setup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 9),
                Icon(
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

  void _continue() {
    // Make sure aliases have a destination.
    for (final item in emailItems) {
      if (item.type == BusinessEmailType.alias &&
          item.deliverTo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Select where ${item.email} should deliver messages.',
            ),
          ),
        );
        return;
      }
    }

    debugPrint('Provider: ${widget.provider}');

    for (final item in emailItems) {
      debugPrint(
        '${item.email} | ${item.type.name} | ${item.deliverTo}',
      );
    }

    // NEXT:
    //
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmailSetupReviewScreen(
          businessName: widget.businessName,
          domain: widget.domain,
          provider: widget.provider,
          emailItems: emailItems,
        ),
      ),
    );
  }
}