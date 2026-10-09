
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SupplierRegistrationScreen extends StatefulWidget {
  const SupplierRegistrationScreen({super.key});

  @override
  State<SupplierRegistrationScreen> createState() =>
      _SupplierRegistrationScreenState();
}

class _SupplierRegistrationScreenState
    extends State<SupplierRegistrationScreen> {
  static const Color navy = Color(0xFF151D43);
  static const Color purple = Color(0xFF6264E8);
  static const Color background = Color(0xFFF6F8FC);

  final _formKey = GlobalKey<FormState>();

  final _company = TextEditingController();
  final _contactPerson = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _description = TextEditingController();
  final _gstin = TextEditingController();
  final _categories = TextEditingController();
  final _serviceAreas = TextEditingController();

  String _supplierType = 'Product';
  String _verificationStatus = 'not_registered';
  bool _loading = true;
  bool _saving = false;
  bool _existing = false;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _supplierRef {
    final userId = _uid;
    if (userId == null) return null;

    return FirebaseFirestore.instance
        .collection('suppliers')
        .doc(userId);
  }

  @override
  void initState() {
    super.initState();
    _loadSupplier();
  }

  @override
  void dispose() {
    _company.dispose();
    _contactPerson.dispose();
    _phone.dispose();
    _email.dispose();
    _description.dispose();
    _gstin.dispose();
    _categories.dispose();
    _serviceAreas.dispose();
    super.dispose();
  }

  List<String> _splitValues(String value) {
    return value
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<void> _loadSupplier() async {
    try {
      final ref = _supplierRef;

      if (ref == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final snap = await ref.get();

      if (!mounted) return;

      if (snap.exists) {
        final data = snap.data()!;

        _company.text = '${data['displayName'] ?? ''}';
        _contactPerson.text =
            '${data['contactPerson'] ?? ''}';
        _phone.text = '${data['phone'] ?? ''}';
        _email.text = '${data['email'] ?? ''}';
        _description.text = '${data['description'] ?? ''}';
        _gstin.text = '${data['gstin'] ?? ''}';

        final categories = data['categoryIds'];
        final areas = data['serviceAreas'];

        _categories.text = categories is List
            ? categories.join(', ')
            : '';

        _serviceAreas.text = areas is List
            ? areas.join(', ')
            : '';

        final type = '${data['supplierType'] ?? 'Product'}';
        _supplierType = ['Product', 'Service', 'Both']
                .contains(type)
            ? type
            : 'Product';

        _verificationStatus =
            '${data['verificationStatus'] ?? 'pending'}';

        _existing = true;
      } else {
        _email.text =
            FirebaseAuth.instance.currentUser?.email ?? '';
      }

      setState(() => _loading = false);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);
      _message('Unable to load supplier: ${e.message ?? e.code}');
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);
      _message('Unable to load supplier: $e');
    }
  }

  void _message(String value) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveSupplier() async {
    if (_saving ||
        !_formKey.currentState!.validate()) {
      return;
    }

    final ref = _supplierRef;
    final userId = _uid;

    if (ref == null || userId == null) {
      _message('Please sign in first.');
      return;
    }

    final categories = _splitValues(_categories.text);
    final areas = _splitValues(_serviceAreas.text);

    if (categories.isEmpty || areas.isEmpty) {
      _message('Enter at least one category and service area.');
      return;
    }

    setState(() => _saving = true);

    try {
      final data = <String, dynamic>{
        'ownerUid': userId,
        'displayName': _company.text.trim(),
        'contactPerson': _contactPerson.text.trim(),
        'phone': _phone.text.trim(),
        'email': _email.text.trim(),
        'description': _description.text.trim(),
        'supplierType': _supplierType,
        'categoryIds': categories,
        'serviceAreas': areas,
        'gstin': _gstin.text.trim().toUpperCase(),
        'verificationStatus': 'pending',
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_existing) {
        // Editing resubmits the supplier for approval.
        await ref.update(data);
      } else {
        await ref.set({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      setState(() {
        _existing = true;
        _verificationStatus = 'pending';
      });

  Navigator.of(context).pop(
  _existing
      ? 'Supplier profile updated successfully. Awaiting approval.'
      : 'Supplier registration submitted successfully. Awaiting approval.',
);
    } on FirebaseException catch (e) {
      _message(
        'Unable to save supplier (${e.code}): '
        '${e.message ?? ''}',
      );
    } catch (e) {
      _message('Unable to save supplier: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    int maxLength = 150,
    TextInputType? keyboard,
    bool requiredField = true,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: purple),
          filled: true,
          fillColor: background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
        ),
        validator: (value) {
          if (requiredField &&
              (value == null || value.trim().isEmpty)) {
            return 'Please enter $label';
          }

          if (label == 'Email' &&
              value != null &&
              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                  .hasMatch(value.trim())) {
            return 'Enter a valid email address';
          }

          if (label == 'GSTIN' &&
              value != null &&
              value.trim().isNotEmpty &&
              !RegExp(
                r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][A-Z0-9]Z[A-Z0-9]$',
              ).hasMatch(value.trim().toUpperCase())) {
            return 'Enter a valid GSTIN format';
          }

          return null;
        },
      ),
    );
  }

  Widget _statusBanner() {
    if (!_existing) return const SizedBox.shrink();

    final approved = _verificationStatus == 'approved';
    final rejected = _verificationStatus == 'rejected';

    final color = approved
        ? Colors.green
        : rejected
            ? Colors.red
            : Colors.orange;

    final label = approved
        ? 'Approved'
        : rejected
            ? 'Registration rejected'
            : 'Approval pending';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            approved
                ? Icons.verified_rounded
                : Icons.hourglass_top_rounded,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(
        body: Center(
          child: Text('Sign in to register as a supplier.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Supplier Registration',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: background,
        foregroundColor: navy,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 820),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    18, 12, 18, 40,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              navy,
                              Color(0xFF514DC0),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(25),
                        ),
                        child: const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.storefront_rounded,
                              color: Colors.white,
                              size: 35,
                            ),
                            SizedBox(height: 17),
                            Text(
                              'Grow your business with VEL AI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Register your business to receive '
                              'matching buyer requests and '
                              'submit competitive quotations.',
                              style: TextStyle(
                                color: Color(0xFFE1E4FC),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      _statusBanner(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(22),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Business Information',
                                style: TextStyle(
                                  color: navy,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 22),
                              _field(
                                controller: _company,
                                label: 'Business / Supplier Name',
                                icon: Icons.business_rounded,
                              ),
                              _field(
                                controller: _contactPerson,
                                label: 'Contact Person',
                                icon: Icons.person_outline,
                              ),
                              _field(
                                controller: _phone,
                                label: 'Mobile Number',
                                icon: Icons.phone_outlined,
                                keyboard: TextInputType.phone,
                              ),
                              _field(
                                controller: _email,
                                label: 'Email',
                                icon: Icons.email_outlined,
                                keyboard:
                                    TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 2),
                              DropdownButtonFormField<String>(
                                value: _supplierType,
                                decoration: InputDecoration(
                                  labelText: 'Supplier Type',
                                  prefixIcon: const Icon(
                                    Icons.category_outlined,
                                    color: purple,
                                  ),
                                  filled: true,
                                  fillColor: background,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Product',
                                    child: Text('Products'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Service',
                                    child: Text('Services'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Both',
                                    child: Text(
                                      'Products and Services',
                                    ),
                                  ),
                                ],
                                onChanged: _saving
                                    ? null
                                    : (value) {
                                        if (value != null) {
                                          setState(() {
                                            _supplierType = value;
                                          });
                                        }
                                      },
                              ),
                              const SizedBox(height: 19),
                              _field(
                                controller: _categories,
                                label: 'Categories',
                                icon: Icons.sell_outlined,
                                hint: 'furniture, office supplies',
                                maxLength: 350,
                              ),
                              _field(
                                controller: _serviceAreas,
                                label: 'Service Areas',
                                icon: Icons.location_on_outlined,
                                hint: 'chennai, erode, coimbatore',
                                maxLength: 350,
                              ),
                              _field(
                                controller: _gstin,
                                label: 'GSTIN',
                                icon: Icons.receipt_long_outlined,
                                requiredField: false,
                                maxLength: 15,
                              ),
                              _field(
                                controller: _description,
                                label: 'Business Description',
                                icon: Icons.description_outlined,
                                maxLines: 4,
                                maxLength: 1000,
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: FilledButton.icon(
                                  onPressed: _saving
                                      ? null
                                      : _saveSupplier,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: purple,
                                    foregroundColor:
                                        Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15),
                                    ),
                                  ),
                                  icon: _saving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.save_outlined,
                                        ),
                                  label: Text(
                                    _saving
                                        ? 'Saving...'
                                        : _existing
                                            ? 'Update Supplier Profile'
                                            : 'Register as Supplier',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Registration requires review. '
                                'Submitting changes to an '
                                'approved profile will require '
                                'approval again.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
