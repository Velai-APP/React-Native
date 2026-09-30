import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class AddDomainScreen extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existingData;

  const AddDomainScreen({
    super.key,
    this.docId,
    this.existingData,
  });

  @override
  State<AddDomainScreen> createState() => _AddDomainScreenState();
}

class _AddDomainScreenState extends State<AddDomainScreen> {
  static const Color primaryColor = Color(0xFF4F46E5);
  static const Color secondaryColor = Color(0xFF7C3AED);
  static const Color backgroundColor = Color(0xFFF6F7FB);
  static const Color textColor = Color(0xFF111827);
  static const Color secondaryTextColor = Color(0xFF6B7280);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController domainController =
      TextEditingController();

  final TextEditingController registrarController =
      TextEditingController();

  final TextEditingController renewalCostController =
      TextEditingController();

  final TextEditingController dnsProviderController =
      TextEditingController();

  final TextEditingController renewalUrlController =
      TextEditingController();

  final TextEditingController notesController =
      TextEditingController();

  DateTime? expiryDate;
  bool isLoading = false;

  bool get isEditing => widget.docId != null;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final data = widget.existingData;

    if (data == null) {
      return;
    }

    domainController.text =
        data['domainName']?.toString() ?? '';

    registrarController.text =
        data['registrar']?.toString() ?? '';

    renewalCostController.text =
        _formatExistingCost(data['renewalCost']);

    dnsProviderController.text =
        data['dnsProvider']?.toString() ?? '';

    renewalUrlController.text =
        data['renewalUrl']?.toString() ?? '';

    notesController.text =
        data['notes']?.toString() ?? '';

    final dynamic storedExpiryDate = data['expiryDate'];

    if (storedExpiryDate is Timestamp) {
      expiryDate = storedExpiryDate.toDate();
    } else if (storedExpiryDate is DateTime) {
      expiryDate = storedExpiryDate;
    } else if (storedExpiryDate is String) {
      expiryDate = DateTime.tryParse(storedExpiryDate);
    }
  }

  String _formatExistingCost(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is num) {
      if (value % 1 == 0) {
        return value.toInt().toString();
      }

      return value.toString();
    }

    return value.toString();
  }

  @override
  void dispose() {
    domainController.dispose();
    registrarController.dispose();
    renewalCostController.dispose();
    dnsProviderController.dispose();
    renewalUrlController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> pickExpiryDate() async {
    FocusScope.of(context).unfocus();

    final DateTime now = DateTime.now();

    final DateTime initialDate =
        expiryDate ?? now.add(const Duration(days: 365));

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 20),
      helpText: 'SELECT DOMAIN EXPIRY DATE',
      cancelText: 'CANCEL',
      confirmText: 'SELECT',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textColor,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && mounted) {
      setState(() {
        expiryDate = selectedDate;
      });
    }
  }

  Future<void> saveDomain() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (expiryDate == null) {
      _showSnackBar(
        message: 'Please select the domain expiry date.',
        isError: true,
      );
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showSnackBar(
        message: 'Please sign in before saving a domain.',
        isError: true,
      );
      return;
    }

    final double? renewalCost = double.tryParse(
      renewalCostController.text
          .trim()
          .replaceAll(',', ''),
    );

    if (renewalCost == null || renewalCost < 0) {
      _showSnackBar(
        message: 'Please enter a valid renewal cost.',
        isError: true,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final String cleanedDomain =
          _cleanDomainName(domainController.text);

      final Map<String, dynamic> domainData = {
        'domainName': cleanedDomain,
        'registrar': registrarController.text.trim(),
        'renewalCost': renewalCost,
        'dnsProvider': dnsProviderController.text.trim(),
        'renewalUrl': renewalUrlController.text.trim(),
        'notes': notesController.text.trim(),
        'expiryDate': Timestamp.fromDate(expiryDate!),
        'userId': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isEditing) {
        await FirebaseFirestore.instance
            .collection('domains')
            .doc(widget.docId)
            .update(domainData);
      } else {
        domainData['createdAt'] =
            FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection('domains')
            .add(domainData);
      }

      if (!mounted) {
        return;
      }

      Fluttertoast.showToast(
        msg: isEditing
            ? 'Domain updated successfully'
            : 'Domain added successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFF16A34A),
        textColor: Colors.white,
        fontSize: 15,
      );

      Navigator.pop(context, true);
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      _showSnackBar(
        message:
            error.message ?? 'Unable to save the domain.',
        isError: true,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showSnackBar(
        message: 'Something went wrong. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _cleanDomainName(String value) {
    String domain = value.trim().toLowerCase();

    domain = domain.replaceFirst(
      RegExp(r'^https?://'),
      '',
    );

    domain = domain.replaceFirst(
      RegExp(r'^www\.'),
      '',
    );

    domain = domain.split('/').first;

    return domain;
  }

  void _showSnackBar({
    required String message,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
          backgroundColor: isError
              ? const Color(0xFFDC2626)
              : const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isLoading,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          title: Text(
            isEditing ? 'Edit Domain' : 'Add Domain',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                children: [
                  _buildHeader(),
                  Transform.translate(
                    offset: const Offset(0, -18),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildSectionCard(
                              title: 'Domain Information',
                              subtitle:
                                  'Enter the main details of your domain.',
                              icon: Icons.language_rounded,
                              children: [
                                _inputField(
                                  controller: domainController,
                                  label: 'Domain Name',
                                  hintText: 'example.com',
                                  icon: Icons.public_rounded,
                                  keyboardType:
                                      TextInputType.url,
                                  textInputAction:
                                      TextInputAction.next,
                                  validator: _validateDomainName,
                                  autoValidateMode:
                                      AutovalidateMode
                                          .onUserInteraction,
                                ),
                                _inputField(
                                  controller:
                                      registrarController,
                                  label: 'Domain Registrar',
                                  hintText:
                                      'GoDaddy, Namecheap, Hostinger',
                                  icon:
                                      Icons.business_rounded,
                                  textCapitalization:
                                      TextCapitalization.words,
                                  textInputAction:
                                      TextInputAction.next,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Enter the registrar name';
                                    }

                                    return null;
                                  },
                                ),
                                _inputField(
                                  controller:
                                      renewalCostController,
                                  label: 'Renewal Cost',
                                  hintText: '999',
                                  icon:
                                      Icons.currency_rupee_rounded,
                                  keyboardType:
                                      const TextInputType
                                          .numberWithOptions(
                                    decimal: true,
                                  ),
                                  textInputAction:
                                      TextInputAction.next,
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .allow(
                                      RegExp(r'^\d*\.?\d{0,2}'),
                                    ),
                                  ],
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Enter the renewal cost';
                                    }

                                    final cost = double.tryParse(
                                      value
                                          .trim()
                                          .replaceAll(',', ''),
                                    );

                                    if (cost == null ||
                                        cost < 0) {
                                      return 'Enter a valid renewal cost';
                                    }

                                    return null;
                                  },
                                ),
                                _expiryDateField(),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSectionCard(
                              title: 'Technical Details',
                              subtitle:
                                  'Optional DNS and renewal information.',
                              icon: Icons.dns_rounded,
                              children: [
                                _inputField(
                                  controller:
                                      dnsProviderController,
                                  label: 'DNS Provider',
                                  hintText:
                                      'Cloudflare, GoDaddy, AWS',
                                  icon: Icons.dns_rounded,
                                  textCapitalization:
                                      TextCapitalization.words,
                                  textInputAction:
                                      TextInputAction.next,
                                ),
                                _inputField(
                                  controller:
                                      renewalUrlController,
                                  label: 'Renewal URL',
                                  hintText:
                                      'https://registrar.com/renew',
                                  icon: Icons.link_rounded,
                                  keyboardType:
                                      TextInputType.url,
                                  textInputAction:
                                      TextInputAction.next,
                                  validator: _validateOptionalUrl,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSectionCard(
                              title: 'Additional Notes',
                              subtitle:
                                  'Add login hints, account details or reminders.',
                              icon: Icons.notes_rounded,
                              children: [
                _inputField(
  controller: notesController,
  label: 'Notes',
  hintText: 'Add any important information...',
  icon: Icons.edit_note_rounded,
  maxLines: 5,
  minLines: 3,
  keyboardType: TextInputType.multiline,
  textCapitalization: TextCapitalization.sentences,
  textInputAction: TextInputAction.newline,
),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final String domainPreview =
        domainController.text.trim().isEmpty
            ? 'Your domain'
            : _cleanDomainName(domainController.text);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 42),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.language_rounded,
              size: 37,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            isEditing ? 'Update Your Domain' : 'Add a New Domain',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            isEditing
                ? 'Update the expiry and renewal information for $domainPreview.'
                : 'Track domain expiry dates and avoid accidental expiration.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: textColor.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _expiryDateField() {
    final bool hasDate = expiryDate != null;

    final String formattedDate = hasDate
        ? DateFormat('dd MMMM yyyy').format(expiryDate!)
        : 'Select expiry date';

    final int? daysLeft = hasDate
        ? _daysRemaining(expiryDate!)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLoading ? null : pickExpiryDate,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: hasDate
                ? primaryColor.withValues(alpha: 0.04)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasDate
                  ? primaryColor.withValues(alpha: 0.45)
                  : const Color(0xFFE5E7EB),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: hasDate
                      ? primaryColor.withValues(alpha: 0.1)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: hasDate
                      ? primaryColor
                      : secondaryTextColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expiry Date',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: hasDate
                            ? textColor
                            : secondaryTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (daysLeft != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        _getExpiryDescription(daysLeft),
                        style: TextStyle(
                          color: _getExpiryColor(daysLeft),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: textColor.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: isLoading ? null : saveDomain,
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                disabledBackgroundColor:
                    primaryColor.withValues(alpha: 0.55),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
                elevation: 0,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isLoading
                    ? const Row(
                        key: ValueKey('loading'),
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.3,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Saving Domain...',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        key: const ValueKey('save'),
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            isEditing
                                ? Icons.check_circle_outline_rounded
                                : Icons.add_circle_outline_rounded,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isEditing
                                ? 'Update Domain'
                                : 'Save Domain',
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
    int? minLines,
    TextInputType keyboardType = TextInputType.multiline,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization =
        TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    AutovalidateMode? autoValidateMode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: !isLoading,
        maxLines: maxLines,
        minLines: minLines,
keyboardType: maxLines > 1
    ? TextInputType.multiline
    : keyboardType,

textInputAction: maxLines > 1
    ? TextInputAction.newline
    : textInputAction,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        validator: validator,
        autovalidateMode: autoValidateMode,
        cursorColor: primaryColor,
        style: const TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          alignLabelWithHint: maxLines > 1,
          labelStyle: const TextStyle(
            color: secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color:
                secondaryTextColor.withValues(alpha: 0.65),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(11),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 21,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 64,
            minHeight: 62,
          ),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: primaryColor,
              width: 1.6,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFDC2626),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFDC2626),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  String? _validateDomainName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a domain name';
    }

    final String domain = _cleanDomainName(value);

    final RegExp domainPattern = RegExp(
      r'^(?!-)(?:[a-zA-Z0-9-]{1,63}\.)+[a-zA-Z]{2,63}$',
    );

    if (!domainPattern.hasMatch(domain)) {
      return 'Enter a valid domain, such as example.com';
    }

    return null;
  }

  String? _validateOptionalUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    String url = value.trim();

    if (!url.startsWith('http://') &&
        !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri? uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty) {
      return 'Enter a valid renewal URL';
    }

    return null;
  }

  int _daysRemaining(DateTime expiry) {
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final DateTime expiryDay = DateTime(
      expiry.year,
      expiry.month,
      expiry.day,
    );

    return expiryDay.difference(today).inDays;
  }

  String _getExpiryDescription(int daysLeft) {
    if (daysLeft < 0) {
      final int expiredDays = daysLeft.abs();

      return expiredDays == 1
          ? 'Expired 1 day ago'
          : 'Expired $expiredDays days ago';
    }

    if (daysLeft == 0) {
      return 'Expires today';
    }

    if (daysLeft == 1) {
      return 'Expires tomorrow';
    }

    return 'Expires in $daysLeft days';
  }

  Color _getExpiryColor(int daysLeft) {
    if (daysLeft < 0) {
      return const Color(0xFFDC2626);
    }

    if (daysLeft <= 30) {
      return const Color(0xFFF59E0B);
    }

    return const Color(0xFF16A34A);
  }
}