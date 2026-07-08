import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  final _formKey = GlobalKey<FormState>();

  final domainController = TextEditingController();
  final registrarController = TextEditingController();
  final renewalCostController = TextEditingController();
  final dnsProviderController = TextEditingController();
  final renewalUrlController = TextEditingController();
  final notesController = TextEditingController();

  DateTime? expiryDate;
  bool isLoading = false;

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

  @override
void initState() {
  super.initState();

  if (widget.existingData != null) {
    domainController.text =
        widget.existingData!["domainName"];

    registrarController.text =
        widget.existingData!["registrar"];


    renewalCostController.text =
        widget.existingData!["renewalCost"]?.toString() ?? "";

    dnsProviderController.text =
        widget.existingData!["dnsProvider"] ?? "";

    renewalUrlController.text =
        widget.existingData!["renewalUrl"] ?? "";

    notesController.text =
        widget.existingData!["notes"] ?? "";

    expiryDate =
        (widget.existingData!["expiryDate"] as Timestamp)
            .toDate();
  }
}

  Future<void> pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() {
        expiryDate = picked;
      });
    }
  }

 Future<void> saveDomain() async {
  if (!_formKey.currentState!.validate()) return;

  if (expiryDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select expiry date")),
    );
    return;
  }

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User not logged in")),
    );
    return;
  }

  setState(() => isLoading = true);

  try {
 Map<String, dynamic> data = {
  "domainName": domainController.text.trim(),
  "registrar": registrarController.text.trim(),
  "renewalCost": renewalCostController.text.trim(),
  "dnsProvider": dnsProviderController.text.trim(),
  "renewalUrl": renewalUrlController.text.trim(),
  "notes": notesController.text.trim(),
  "expiryDate": Timestamp.fromDate(expiryDate!),
  "userId": FirebaseAuth.instance.currentUser!.uid,
};

if (widget.docId == null) {
  // Add new domain
  await FirebaseFirestore.instance
      .collection("domains")
      .add(data);
} else {
  // Update existing domain
  await FirebaseFirestore.instance
      .collection("domains")
      .doc(widget.docId)
      .update(data);
}

    if (mounted) {
Fluttertoast.showToast(
  msg: "Domain added successfully",
  toastLength: Toast.LENGTH_SHORT,
  gravity: ToastGravity.BOTTOM,
  backgroundColor: Colors.green,
  textColor: Colors.white,
  fontSize: 16,
);

      Navigator.pop(context);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  } finally {
    if (mounted) {
      setState(() => isLoading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Domain"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _inputField(
                controller: domainController,
                label: "Domain Name",
                icon: Icons.language,
                validator: "Enter domain name",
              ),

              _inputField(
                controller: registrarController,
                label: "Registrar",
                icon: Icons.business,
                validator: "Enter registrar name",
              ),

              _inputField(
                controller: renewalCostController,
                label: "Renewal Cost",
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator: "Enter renewal cost",
              ),

              _inputField(
                controller: dnsProviderController,
                label: "DNS Provider",
                icon: Icons.dns,
              ),

              _inputField(
                controller: renewalUrlController,
                label: "Renewal URL",
                icon: Icons.link,
              ),

              _inputField(
                controller: notesController,
                label: "Notes",
                icon: Icons.note,
                maxLines: 3,
              ),

              const SizedBox(height: 10),

              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                leading: const Icon(Icons.calendar_month),
                title: Text(
                  expiryDate == null
                      ? "Select Expiry Date"
                      : "Expiry Date: ${expiryDate!.day}-${expiryDate!.month}-${expiryDate!.year}",
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: pickExpiryDate,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : saveDomain,
                  icon: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(isLoading ? "Saving..." : "Save Domain"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator == null
            ? null
            : (value) {
                if (value == null || value.trim().isEmpty) {
                  return validator;
                }
                return null;
              },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}