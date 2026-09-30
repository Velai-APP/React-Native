import 'package:flutter/material.dart';

class ClientRequirementScreen extends StatefulWidget {
  const ClientRequirementScreen({super.key});

  @override
  State<ClientRequirementScreen> createState() =>
      _ClientRequirementScreenState();
}

class _ClientRequirementScreenState
    extends State<ClientRequirementScreen> {
  final _formKey = GlobalKey<FormState>();

  final _companyNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servicesController = TextEditingController();
  final _aboutController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _addressController = TextEditingController();
  final _referenceController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedStyle = 'Professional';
  String _selectedLanguage = 'English';
  String _selectedColor = '#1E3A8A';

  bool _hasLogo = false;
  bool _includeWhatsApp = true;
  bool _includeMap = false;
  bool _includeSeo = true;

  final List<String> _allSections = [
    'Hero',
    'About',
    'Services',
    'Products',
    'Team',
    'Gallery',
    'Testimonials',
    'FAQ',
    'Contact',
    'Footer',
  ];

  final Set<String> _selectedSections = {
    'Hero',
    'About',
    'Services',
    'Contact',
    'Footer',
  };

  final List<String> _styles = [
    'Professional',
    'Modern',
    'Minimal',
    'Corporate',
    'Creative',
    'Elegant',
  ];

  final List<String> _languages = [
    'English',
    'Tamil',
    'Hindi',
    'Malayalam',
    'Kannada',
    'Bilingual',
  ];

  final List<Map<String, String>> _colors = [
    {'name': 'Blue', 'value': '#1E3A8A'},
    {'name': 'Teal', 'value': '#0F766E'},
    {'name': 'Green', 'value': '#15803D'},
    {'name': 'Purple', 'value': '#6D28D9'},
    {'name': 'Orange', 'value': '#C2410C'},
    {'name': 'Black', 'value': '#111827'},
  ];

  @override
  void dispose() {
    _companyNameController.dispose();
    _businessTypeController.dispose();
    _descriptionController.dispose();
    _servicesController.dispose();
    _aboutController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _referenceController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedSections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one website section.'),
        ),
      );
      return;
    }

    final data = <String, dynamic>{
      'websiteType': 'static',
      'companyName': _companyNameController.text.trim(),
      'businessType': _businessTypeController.text.trim(),
      'description': _descriptionController.text.trim(),
      'services': _servicesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      'about': _aboutController.text.trim(),
      'sections': _selectedSections.toList(),
      'style': _selectedStyle,
      'language': _selectedLanguage,
      'primaryColor': _selectedColor,
      'hasLogo': _hasLogo,
      'contact': {
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'address': _addressController.text.trim(),
      },
      'features': {
        'whatsappButton': _includeWhatsApp,
        'googleMap': _includeMap,
        'seo': _includeSeo,
      },
      'referenceWebsite': _referenceController.text.trim(),
      'specialInstructions': _instructionsController.text.trim(),
    };

    Navigator.pop(context, data);
  }

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter $fieldName';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Client Requirements'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _header(),
            const SizedBox(height: 18),
            _sectionCard(
              title: 'Business Details',
              icon: Icons.business,
              children: [
                _field(
                  controller: _companyNameController,
                  label: 'Company / Brand Name',
                  validator: (value) =>
                      _required(value, 'company name'),
                ),
                _field(
                  controller: _businessTypeController,
                  label: 'Business Type',
                  validator: (value) =>
                      _required(value, 'business type'),
                ),
                _field(
                  controller: _descriptionController,
                  label: 'Business Description',
                  minLines: 4,
                  maxLines: 6,
                  validator: (value) =>
                      _required(value, 'business description'),
                ),
                _field(
                  controller: _servicesController,
                  label: 'Services / Products',
                  hint: 'Example: GST, Audit, Tax Filing',
                  minLines: 3,
                  maxLines: 5,
                  validator: (value) =>
                      _required(value, 'services or products'),
                ),
                _field(
                  controller: _aboutController,
                  label: 'About the Business',
                  minLines: 4,
                  maxLines: 6,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _sectionCard(
              title: 'Website Sections',
              icon: Icons.web,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allSections.map((section) {
                    final selected =
                        _selectedSections.contains(section);

                    return FilterChip(
                      label: Text(section),
                      selected: selected,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            _selectedSections.add(section);
                          } else {
                            _selectedSections.remove(section);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _sectionCard(
              title: 'Design Preferences',
              icon: Icons.palette,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedStyle,
                  decoration: _decoration('Website Style'),
                  items: _styles
                      .map(
                        (style) => DropdownMenuItem(
                          value: style,
                          child: Text(style),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStyle = value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  decoration: _decoration('Website Language'),
                  items: _languages
                      .map(
                        (language) => DropdownMenuItem(
                          value: language,
                          child: Text(language),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedLanguage = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Primary Colour',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _colors.map((item) {
                    final value = item['value']!;
                    return ChoiceChip(
                      selected: _selectedColor == value,
                      avatar: CircleAvatar(
                        backgroundColor: _hexColor(value),
                      ),
                      label: Text(item['name']!),
                      onSelected: (_) {
                        setState(() => _selectedColor = value);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Client has a logo'),
                  value: _hasLogo,
                  onChanged: (value) {
                    setState(() => _hasLogo = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            _sectionCard(
              title: 'Contact Details',
              icon: Icons.contact_phone,
              children: [
                _field(
                  controller: _emailController,
                  label: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                ),
                _field(
                  controller: _phoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                ),
                _field(
                  controller: _whatsappController,
                  label: 'WhatsApp Number',
                  keyboardType: TextInputType.phone,
                ),
                _field(
                  controller: _addressController,
                  label: 'Business Address',
                  minLines: 3,
                  maxLines: 5,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _sectionCard(
              title: 'Static Website Options',
              icon: Icons.settings,
              children: [
                _switchTile(
                  title: 'WhatsApp Button',
                  value: _includeWhatsApp,
                  onChanged: (value) {
                    setState(() => _includeWhatsApp = value);
                  },
                ),
                _switchTile(
                  title: 'Google Map',
                  value: _includeMap,
                  onChanged: (value) {
                    setState(() => _includeMap = value);
                  },
                ),
                _switchTile(
                  title: 'Basic SEO',
                  value: _includeSeo,
                  onChanged: (value) {
                    setState(() => _includeSeo = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            _sectionCard(
              title: 'Reference & Instructions',
              icon: Icons.description,
              children: [
                _field(
                  controller: _referenceController,
                  label: 'Reference Website URL',
                  keyboardType: TextInputType.url,
                ),
                _field(
                  controller: _instructionsController,
                  label: 'Special Instructions',
                  minLines: 4,
                  maxLines: 7,
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                'Continue',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF2563EB),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.web,
              color: Color(0xFF1E3A8A),
              size: 30,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Enter the client details required to create a static website.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1E3A8A)),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    int minLines = 1,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: _decoration(label, hint),
      ),
    );
  }

  InputDecoration _decoration(String label, [String? hint]) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFDCE2EA),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      value: value,
      activeColor: const Color(0xFF1E3A8A),
      onChanged: onChanged,
    );
  }

  Color _hexColor(String value) {
    final hex = value.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
