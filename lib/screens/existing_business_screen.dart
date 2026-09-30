import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dashboard_screen.dart';

class ExistingBusinessScreen extends StatefulWidget {
  const ExistingBusinessScreen({
    super.key,
  });

  @override
  State<ExistingBusinessScreen> createState() =>
      _ExistingBusinessScreenState();
}

class _ExistingBusinessScreenState
    extends State<ExistingBusinessScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController
      businessNameController =
      TextEditingController();

  final TextEditingController
      businessDescriptionController =
      TextEditingController();

  final TextEditingController
      targetCustomersController =
      TextEditingController();

  final TextEditingController
      investmentController =
      TextEditingController();

  String? selectedCategory;
  String? selectedStage;
  String? selectedRevenueModel;

  bool isSaving = false;

  final List<String> categories = [
    'Technology',
    'Professional Services',
    'Retail / E-commerce',
    'Food & Beverage',
    'Manufacturing',
    'Education',
    'Healthcare',
    'Agriculture',
    'Finance',
    'Real Estate',
    'Media / Creative',
    'Other',
  ];

  final List<String> stages = [
    'Just an idea',
    'Planning stage',
    'Already started',
    'Generating revenue',
  ];

  final List<String> revenueModels = [
    'Product Sales',
    'Service Fees',
    'Subscription',
    'Commission',
    'Advertising',
    'Marketplace',
    'Not decided yet',
  ];

  Future<void> saveBusinessProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please login again.'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final Map<String, dynamic>
          businessProfile = {
        'businessName':
            businessNameController.text.trim(),

        'businessCategory':
            selectedCategory ??
                'Not specified',

        'matchScore': 100,

        'investment':
            investmentController.text
                    .trim()
                    .isEmpty
                ? 'Not specified'
                : investmentController.text
                    .trim(),

        'timeToLaunch':
            selectedStage ==
                    'Already started'
                ? 'Already Started'
                : selectedStage ==
                        'Generating revenue'
                    ? 'Operational'
                    : 'To be planned',

        'difficulty':
            'Self-defined Business',

        'description':
            businessDescriptionController
                .text
                .trim(),

        'opportunitySummary':
            businessDescriptionController
                .text
                .trim(),

        'whyItFits':
            'Business idea provided directly by the user.',

        'targetCustomers':
            targetCustomersController.text
                    .trim()
                    .isEmpty
                ? 'Not specified'
                : targetCustomersController.text
                    .trim(),

        'revenueModel':
            selectedRevenueModel ??
                'Not decided yet',

        'businessStage':
            selectedStage ??
                'Just an idea',

        'source':
            'existing_business',

        'createdBy':
            'user',

        'status':
            'active',

        'createdAt':
            FieldValue.serverTimestamp(),

        'updatedAt':
            FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('businessProfile')
          .doc('profile')
          .set(
        businessProfile,
        SetOptions(
          merge: true,
        ),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'hasBusinessProfile': true,
          'businessName':
              businessNameController.text
                  .trim(),
          'businessCategory':
              selectedCategory,
          'businessProfileUpdatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      if (!mounted) return;

      final dashboardProfile =
          Map<String, dynamic>.from(
        businessProfile,
      );

      // Remove FieldValue objects before sending
      // this local map to Dashboard.
      dashboardProfile.remove(
        'createdAt',
      );
      dashboardProfile.remove(
        'updatedAt',
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DashboardScreen(
            businessProfile:
                dashboardProfile,
          ),
        ),
        (route) => false,
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          content: Text(
            e.message ??
                'Unable to save business profile.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          content: Text(
            'Unable to save business: $e',
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
    businessNameController.dispose();
    businessDescriptionController.dispose();
    targetCustomersController.dispose();
    investmentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF8EE),
      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        foregroundColor:
            Colors.black87,
        title: const Text(
          'Your Business Idea',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _headerCard(),

                const SizedBox(height: 24),

                _sectionTitle(
                  'Business basics',
                  'Tell us what you want to build.',
                ),

                const SizedBox(height: 15),

                _textField(
                  controller:
                      businessNameController,
                  label:
                      'Business / Idea Name',
                  hint:
                      'Example: AI Accounting Assistant',
                  icon:
                      Icons.business_center_outlined,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter your business idea';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                _dropdown(
                  value: selectedCategory,
                  label:
                      'Business Category',
                  icon:
                      Icons.category_outlined,
                  items: categories,
                  onChanged: (value) {
                    setState(() {
                      selectedCategory =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                _textField(
                  controller:
                      businessDescriptionController,
                  label:
                      'Describe Your Business',
                  hint:
                      'What will you sell or provide?',
                  icon:
                      Icons.description_outlined,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null ||
                        value.trim().length < 10) {
                      return 'Give a short description of your business';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                _sectionTitle(
                  'Business readiness',
                  'A few details will help build your profile.',
                ),

                const SizedBox(height: 15),

                _dropdown(
                  value: selectedStage,
                  label:
                      'Current Stage',
                  icon:
                      Icons.timeline,
                  items: stages,
                  onChanged: (value) {
                    setState(() {
                      selectedStage =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                _textField(
                  controller:
                      targetCustomersController,
                  label:
                      'Target Customers',
                  hint:
                      'Example: Small businesses, students...',
                  icon:
                      Icons.groups_outlined,
                ),

                const SizedBox(height: 14),

                _textField(
                  controller:
                      investmentController,
                  label:
                      'Planned Investment',
                  hint:
                      'Example: ₹2 lakh',
                  icon:
                      Icons.currency_rupee,
                ),

                const SizedBox(height: 14),

                _dropdown(
                  value:
                      selectedRevenueModel,
                  label:
                      'Revenue Model',
                  icon:
                      Icons.payments_outlined,
                  items: revenueModels,
                  onChanged: (value) {
                    setState(() {
                      selectedRevenueModel =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed:
                        isSaving
                            ? null
                            : saveBusinessProfile,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.black87,
                      disabledBackgroundColor:
                          Colors.grey.shade400,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                    ),
                    child: isSaving
                        ? const Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Colors.white,
                                ),
                              ),
                              SizedBox(
                                width: 14,
                              ),
                              Text(
                                'Creating your business profile...',
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Create Business Profile  →',
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
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

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF9800),
            Color(0xFFFFB300),
          ],
        ),
        borderRadius:
            BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.orange
                .withOpacity(.25),
            blurRadius: 25,
            offset:
                const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                Colors.white24,
            child: Icon(
              Icons.lightbulb_outline,
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
                  'Already have an idea?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tell us a few things about it and we’ll set up your business workspace.',
                  style: TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 14,
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

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color:
                Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController
        controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)?
        validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint:
            maxLines > 1,
        prefixIcon:
            maxLines == 1
                ? Icon(
                    icon,
                    color:
                        Colors.orange,
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
            color: Colors.orange,
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
          color: Colors.orange,
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
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          borderSide:
              const BorderSide(
            color: Colors.orange,
            width: 1.5,
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