import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../gst_dashboard_screen.dart';

class GstProfileScreen extends StatefulWidget {
  const GstProfileScreen({super.key});

  @override
  State<GstProfileScreen> createState() =>
      _GstProfileScreenState();
}

class _GstProfileScreenState extends State<GstProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController gstinController =
      TextEditingController();

  final TextEditingController legalNameController =
      TextEditingController();

  final TextEditingController tradeNameController =
      TextEditingController();

  final TextEditingController addressController =
      TextEditingController();

  String? selectedState;
  String? registrationType;
  String? filingFrequency;

  bool isSaving = false;

  final List<String> states = [
    'Tamil Nadu',
    'Karnataka',
    'Kerala',
    'Andhra Pradesh',
    'Telangana',
    'Maharashtra',
    'Delhi',
    'Gujarat',
    'Rajasthan',
    'Uttar Pradesh',
    'West Bengal',
    'Other',
  ];

  final List<String> registrationTypes = [
    'Regular',
    'Composition',
    'SEZ',
    'Casual Taxable Person',
    'Input Service Distributor',
    'TDS',
    'TCS',
  ];

  final List<String> filingFrequencies = [
    'Monthly',
    'Quarterly',
  ];

Future<void> saveProfile() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please login again.'),
      ),
    );
    return;
  }

  setState(() {
    isSaving = true;
  });

  try {
    final String gstin =
        gstinController.text.trim().toUpperCase();

    final Map<String, dynamic> profile = {
      'gstin': gstin,
      'legalName': legalNameController.text.trim(),
      'tradeName': tradeNameController.text.trim(),
      'state': selectedState ?? '',
      'registrationType': registrationType ?? 'Regular',
      'filingFrequency': filingFrequency ?? 'Monthly',
      'address': addressController.text.trim(),
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final FirebaseFirestore firestore =
        FirebaseFirestore.instance;

    // -------------------------------------------------------
    // 1. SAVE GST PROFILE
    // -------------------------------------------------------

    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('gstProfiles')
        .doc(gstin)
        .set(
      profile,
      SetOptions(merge: true),
    );

    // -------------------------------------------------------
    // 2. SAVE DEFAULT GSTIN ON USER DOCUMENT
    // -------------------------------------------------------

    await firestore
        .collection('users')
        .doc(user.uid)
        .set(
      {
        'defaultGstin': gstin,
        'hasGstProfile': true,
        'gstProfileUpdatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // -------------------------------------------------------
    // 3. READ IT BACK FROM FIRESTORE
    // -------------------------------------------------------

    final DocumentSnapshot<Map<String, dynamic>> savedDoc =
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('gstProfiles')
            .doc(gstin)
            .get(
      const GetOptions(
        source: Source.server,
      ),
    );

    if (!savedDoc.exists || savedDoc.data() == null) {
      throw Exception(
        'GST profile was saved but could not be read back.',
      );
    }

    final Map<String, dynamic> dashboardProfile =
        Map<String, dynamic>.from(
      savedDoc.data()!,
    );

    debugPrint(
      'GST PROFILE SAVED SUCCESSFULLY',
    );

    debugPrint(
      'UID: ${user.uid}',
    );

    debugPrint(
      'GSTIN: $gstin',
    );

    debugPrint(
      'DATA: $dashboardProfile',
    );

    if (!mounted) return;

    // -------------------------------------------------------
    // 4. DIRECTLY OPEN DASHBOARD
    // -------------------------------------------------------

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => GstDashboardScreen(
          gstProfile: dashboardProfile,
        ),
      ),
      (route) => false,
    );
  } on FirebaseException catch (e, stackTrace) {
    debugPrint(
      'GST FIREBASE ERROR: ${e.code}',
    );

    debugPrint(
      'GST FIREBASE MESSAGE: ${e.message}',
    );

    debugPrint(
      '$stackTrace',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${e.code}: ${e.message}',
        ),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint(
      'GST SAVE ERROR: $e',
    );

    debugPrint(
      '$stackTrace',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Unable to save GST profile: $e',
        ),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }
}

  @override
  void dispose() {
    gstinController.dispose();
    legalNameController.dispose();
    tradeNameController.dispose();
    addressController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        foregroundColor:
            Colors.black87,
        title: const Text(
          'GST Setup',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.fromLTRB(
              18,
              5,
              18,
              30,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _hero(),

                const SizedBox(height: 26),

                const Text(
                  'GST Registration',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Add the GST registration you want to manage in Velai.',
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 22),

                _textField(
                  controller:
                      gstinController,
                  label: 'GSTIN',
                  hint:
                      '33ABCDE1234F1Z5',
                  icon:
                      Icons.badge_outlined,
                  textCapitalization:
                      TextCapitalization
                          .characters,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter GSTIN';
                    }

                    if (value.trim().length !=
                        15) {
                      return 'GSTIN must contain 15 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                _textField(
                  controller:
                      legalNameController,
                  label: 'Legal Name',
                  hint:
                      'ABC Enterprises Private Limited',
                  icon:
                      Icons.business_outlined,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter legal name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                _textField(
                  controller:
                      tradeNameController,
                  label: 'Trade Name',
                  hint: 'ABC Enterprises',
                  icon:
                      Icons.storefront_outlined,
                ),

                const SizedBox(height: 14),

                _dropdown(
                  value: selectedState,
                  label: 'State',
                  icon:
                      Icons.location_on_outlined,
                  items: states,
                  onChanged: (value) {
                    setState(() {
                      selectedState = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                _dropdown(
                  value:
                      registrationType,
                  label:
                      'Registration Type',
                  icon:
                      Icons.assignment_outlined,
                  items:
                      registrationTypes,
                  onChanged: (value) {
                    setState(() {
                      registrationType =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                _dropdown(
                  value:
                      filingFrequency,
                  label:
                      'Filing Frequency',
                  icon:
                      Icons.repeat_rounded,
                  items:
                      filingFrequencies,
                  onChanged: (value) {
                    setState(() {
                      filingFrequency =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                _textField(
                  controller:
                      addressController,
                  label:
                      'Principal Place of Business',
                  hint:
                      'Enter registered business address',
                  icon:
                      Icons.location_city_outlined,
                  maxLines: 3,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed:
                        isSaving
                            ? null
                            : saveProfile,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF166534,
                      ),
                      foregroundColor:
                          Colors.white,
                      disabledBackgroundColor:
                          Colors.grey.shade400,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),
                    child:
                        isSaving
                            ? const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                children: [
                                  SizedBox(
                                    height: 21,
                                    width: 21,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                      color:
                                          Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Text(
                                    'Creating GST workspace...',
                                    style:
                                        TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Create GST Workspace  →',
                                style:
                                    TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
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

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF14532D),
            Color(0xFF16A34A),
          ],
        ),
        borderRadius:
            BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.green
                .withOpacity(.22),
            blurRadius: 24,
            offset:
                const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor:
                Colors.white24,
            child: Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),

          SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Set up GST Compliance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Create your GST workspace for returns, ITC, reconciliation and notices.',
                  style: TextStyle(
                    color:
                        Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController
        controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextCapitalization
        textCapitalization =
        TextCapitalization.none,
    String? Function(String?)?
        validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      textCapitalization:
          textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            maxLines == 1
                ? Icon(
                    icon,
                    color:
                        const Color(
                      0xFF166534,
                    ),
                  )
                : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          borderSide:
              BorderSide.none,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          borderSide:
              BorderSide(
            color:
                Colors.grey.shade200,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          borderSide:
              const BorderSide(
            color:
                Color(0xFF16A34A),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?>
        onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color:
              const Color(
            0xFF166534,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          borderSide:
              BorderSide.none,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          borderSide:
              BorderSide(
            color:
                Colors.grey.shade200,
          ),
        ),
      ),
      items: items
          .map(
            (item) =>
                DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}