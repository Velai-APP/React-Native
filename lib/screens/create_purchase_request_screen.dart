import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';



/// Personal procurement request. No business profile is required.

class CreatePurchaseRequestScreen extends StatefulWidget {

  const CreatePurchaseRequestScreen({super.key});



  @override

  State<CreatePurchaseRequestScreen> createState() =>

      _CreatePurchaseRequestScreenState();

}



class _RequestItem {

  final description = TextEditingController();

  final quantity = TextEditingController(text: '1');

  final unit = TextEditingController(text: 'Nos');

  final price = TextEditingController();

  final specifications = TextEditingController();

  String type = 'Product';



  void dispose() {

    description.dispose();

    quantity.dispose();

    unit.dispose();

    price.dispose();

    specifications.dispose();

  }

}



class _CreatePurchaseRequestScreenState

    extends State<CreatePurchaseRequestScreen> {

  static const navy = Color(0xFF151D43);

  static const violet = Color(0xFF6264E8);

  static const bg = Color(0xFFF6F7FB);

  static const muted = Color(0xFF8690A6);



  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();

  final _notes = TextEditingController();

  final _deliveryLocation = TextEditingController();

  final _budget = TextEditingController();

  final List<_RequestItem> _items = [_RequestItem()];

  final Set<String> _supplierIds = {};

  DateTime? _requiredBy;

  bool _saving = false;



  String? get _uid => FirebaseAuth.instance.currentUser?.uid;



  @override

  void dispose() {

    _title.dispose();

    _notes.dispose();

    _deliveryLocation.dispose();

    _budget.dispose();

    for (final item in _items) {

      item.dispose();

    }

    super.dispose();

  }



  InputDecoration _decoration(String label, {String? hint, IconData? icon}) {

    return InputDecoration(

      labelText: label,

      hintText: hint,

      prefixIcon: icon == null ? null : Icon(icon, color: muted, size: 20),

      filled: true,

      fillColor: bg,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

      border: OutlineInputBorder(

        borderRadius: BorderRadius.circular(14),

        borderSide: BorderSide.none,

      ),

      enabledBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(color: Color(0xFFEEF0F7)),

      ),

    );

  }



  Widget _section(String title, String subtitle, IconData icon, Widget body) {

    return Container(

      margin: const EdgeInsets.only(bottom: 18),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: const Color(0xFFEDEFF6)),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Container(

                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(

                  color: const Color(0xFFEFEEFF),

                  borderRadius: BorderRadius.circular(12),

                ),

                child: Icon(icon, color: violet, size: 21),

              ),

              const SizedBox(width: 12),

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: navy)),

                    const SizedBox(height: 3),

                    Text(subtitle, style: const TextStyle(fontSize: 12, color: muted)),

                  ],

                ),

              ),

            ],

          ),

          const SizedBox(height: 18),

          body,

        ],

      ),

    );

  }



  Widget _itemEditor(_RequestItem item, int index) {

    return Container(

      key: ObjectKey(item),

      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(

        color: bg,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: const Color(0xFFE7E9F5)),

      ),

      child: Column(

        children: [

          Row(

            children: [

              Expanded(child: Text('ITEM ${index + 1}', style: const TextStyle(color: violet, fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 12))),

              if (_items.length > 1)

                IconButton(

                  tooltip: 'Remove item',

                  onPressed: () {

                    setState(() => _items.remove(item));

                    // Dispose after this frame so removed text fields have unmounted.

                    WidgetsBinding.instance.addPostFrameCallback((_) => item.dispose());

                  },

                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),

                ),

            ],

          ),

          DropdownButtonFormField<String>(

            value: item.type,

            decoration: _decoration('Purchase type'),

            items: const [

              DropdownMenuItem(value: 'Product', child: Text('Product')),

              DropdownMenuItem(value: 'Service', child: Text('Service')),

            ],

            onChanged: (v) => setState(() => item.type = v ?? 'Product'),

          ),

          const SizedBox(height: 12),

          TextFormField(

            controller: item.description,

            maxLength: 160,

            decoration: _decoration('Item / service name *', hint: 'e.g. Ergonomic office chair'),

            validator: (v) => v == null || v.trim().isEmpty ? 'Enter an item name' : null,

          ),

          const SizedBox(height: 9),

          Row(

            children: [

              Expanded(

                child: TextFormField(

                  controller: item.quantity,

                  keyboardType: const TextInputType.numberWithOptions(decimal: true),

                  decoration: _decoration('Quantity *'),

                  validator: (v) {

                    final n = double.tryParse(v?.trim() ?? '');

                    return n == null || !n.isFinite || n <= 0 ? 'Enter > 0' : null;

                  },

                ),

              ),

              const SizedBox(width: 10),

              Expanded(child: TextFormField(controller: item.unit, decoration: _decoration('Unit'))),

            ],

          ),

          const SizedBox(height: 12),

          TextFormField(

            controller: item.price,

            keyboardType: const TextInputType.numberWithOptions(decimal: true),

            decoration: _decoration('Target unit price (optional)', hint: 'INR'),

            validator: (v) {

              if (v == null || v.trim().isEmpty) return null;

              final n = double.tryParse(v.trim());

              return n == null || !n.isFinite || n < 0 ? 'Enter a valid price' : null;

            },

          ),

          const SizedBox(height: 12),

          TextFormField(

            controller: item.specifications,

            minLines: 2,

            maxLines: 3,

            decoration: _decoration('Specifications', hint: 'Brand, size, warranty, technical details...'),

          ),

        ],

      ),

    );

  }



  Future<void> _pickDate() async {

    final now = DateTime.now();

    final result = await showDatePicker(

      context: context,

      initialDate: _requiredBy ?? now,

      firstDate: DateTime(now.year, now.month, now.day),

      lastDate: DateTime(now.year + 5),

    );

    if (result != null && mounted) setState(() => _requiredBy = result);

  }





Widget _supplierSelector() {

  final currentUid = FirebaseAuth.instance.currentUser?.uid;



  if (currentUid == null) {

    return const Text('Please sign in to load suppliers.');

  }



  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(

    stream: FirebaseFirestore.instance

        .collection('suppliers')

        .where('isActive', isEqualTo: true)

        .where('verificationStatus', isEqualTo: 'approved')

        .snapshots(),

    builder: (context, snapshot) {

      if (snapshot.hasError) {

        return Container(

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(

            color: const Color(0xFFFFF1F1),

            borderRadius: BorderRadius.circular(12),

          ),

          child: SelectableText(

            'Unable to load suppliers.\n'

            '${snapshot.error}',

            style: const TextStyle(color: Colors.red),

          ),

        );

      }



      if (snapshot.connectionState == ConnectionState.waiting) {

        return const Center(

          child: Padding(

            padding: EdgeInsets.all(20),

            child: CircularProgressIndicator(),

          ),

        );

      }



      final allSuppliers = snapshot.data?.docs ?? [];



      // Exclude the buyer's own supplier account.

      final suppliers = allSuppliers.where((doc) {

        return doc.id != currentUid;

      }).toList();



      suppliers.sort((a, b) {

        final nameA =

            (a.data()['displayName'] ?? '').toString();

        final nameB =

            (b.data()['displayName'] ?? '').toString();



        return nameA.toLowerCase().compareTo(nameB.toLowerCase());

      });



      if (suppliers.isEmpty) {

        return Container(

          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(

            color: const Color(0xFFF4F3FF),

            borderRadius: BorderRadius.circular(14),

          ),

          child: const Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Icon(

                Icons.storefront_outlined,

                color: Color(0xFF6264E8),

                size: 30,

              ),

              SizedBox(height: 12),

              Text(

                'No approved suppliers available',

                style: TextStyle(

                  fontWeight: FontWeight.w800,

                  fontSize: 15,

                ),

              ),

              SizedBox(height: 8),

              Text(

                'Suppliers must be approved and active '

                'before they appear here. Your own '

                'supplier account is also excluded.',

                style: TextStyle(

                  color: Colors.blueGrey,

                  height: 1.5,

                ),

              ),

            ],

          ),

        );

      }



      return Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            '${suppliers.length} approved supplier(s) available',

            style: const TextStyle(

              fontWeight: FontWeight.w700,

              color: Color(0xFF151D43),

            ),

          ),

          const SizedBox(height: 12),



          ...suppliers.map((doc) {

            final data = doc.data();



            final selected = _supplierIds.contains(doc.id);



            final name =

                (data['displayName'] ?? 'Supplier').toString();



            final type =

                (data['supplierType'] ?? 'Product').toString();



            final categories =

                (data['categoryIds'] is List)

                    ? (data['categoryIds'] as List).join(', ')

                    : '';



            final areas =

                (data['serviceAreas'] is List)

                    ? (data['serviceAreas'] as List).join(', ')

                    : '';



            return Container(

              margin: const EdgeInsets.only(bottom: 10),

              decoration: BoxDecoration(

                color: selected

                    ? const Color(0xFFF0EEFF)

                    : Colors.white,

                borderRadius: BorderRadius.circular(14),

                border: Border.all(

                  color: selected

                      ? const Color(0xFF6264E8)

                      : const Color(0xFFE5E7F0),

                ),

              ),

              child: CheckboxListTile(

                value: selected,

                activeColor: const Color(0xFF6264E8),

                title: Text(

                  name,

                  style: const TextStyle(

                    fontWeight: FontWeight.w800,

                  ),

                ),

                subtitle: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    const SizedBox(height: 5),

                    Text('Type: $type'),

                    if (categories.isNotEmpty)

                      Text('Categories: $categories'),

                    if (areas.isNotEmpty)

                      Text('Areas: $areas'),

                  ],

                ),

                isThreeLine: true,

                onChanged: _saving

                    ? null

                    : (checked) {

                        setState(() {

                          if (checked == true) {

                            _supplierIds.add(doc.id);

                          } else {

                            _supplierIds.remove(doc.id);

                          }

                        });

                      },

              ),

            );

          }),

        ],

      );

    },

  );

}



  Future<void> _save() async {

    if (_saving || !_formKey.currentState!.validate()) return;

    final uid = _uid;

    if (uid == null) {

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in again.')));

      return;

    }

    setState(() => _saving = true);

    try {

      final ref = FirebaseFirestore.instance
          .collection('purchaseRequests')
          .doc();

      final budgetText = _budget.text.trim();

      await ref.set({

        'title': _title.text.trim(),

        'description': _notes.text.trim(),

        'status': 'draft',

        'currency': 'INR',

        'budget': budgetText.isEmpty ? null : double.parse(budgetText),

        'deliveryLocation': _deliveryLocation.text.trim(),

        'requiredDate': _requiredBy == null ? null : Timestamp.fromDate(_requiredBy!),

        'preferredSupplierIds': _supplierIds.toList(),
        'invitedSupplierIds': <String>[],

        'items': _items.map((item) => {

          'type': item.type,

          'description': item.description.text.trim(),

          'quantity': double.parse(item.quantity.text.trim()),

          'unit': item.unit.text.trim().isEmpty ? 'Nos' : item.unit.text.trim(),

          'targetUnitPrice': item.price.text.trim().isEmpty

              ? null : double.parse(item.price.text.trim()),

          'specifications': item.specifications.text.trim(),

        }).toList(),

        'buyerUid': uid,
        'createdBy': uid,

        'createdAt': FieldValue.serverTimestamp(),

        'updatedAt': FieldValue.serverTimestamp(),

      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text('Purchase request saved as draft.')),

      );

      Navigator.of(context).pop(true);

    } on FirebaseException catch (e) {

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('Could not save: ${e.message ?? e.code}')),

      );

    } catch (e) {

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('Could not save request: $e')),

      );

    } finally {

      if (mounted) setState(() => _saving = false);

    }

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: bg,

      appBar: AppBar(

        backgroundColor: bg,

        surfaceTintColor: Colors.transparent,

        foregroundColor: navy,

        title: const Text('New Purchase Request',

            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),

      ),

      bottomNavigationBar: SafeArea(

        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 14),

        child: SizedBox(

          height: 54,

          child: FilledButton.icon(

            onPressed: _saving ? null : _save,

            style: FilledButton.styleFrom(

              backgroundColor: violet,

              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

            ),

            icon: _saving

                ? const SizedBox(width: 18, height: 18,

                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))

                : const Icon(Icons.check_circle_outline_rounded),

            label: Text(_saving ? 'Saving...' : 'Save Purchase Request',

                style: const TextStyle(fontWeight: FontWeight.w700)),

          ),

        ),

      ),

      body: _uid == null

          ? const Center(child: Text('Please sign in to continue'))

          : Center(

              child: ConstrainedBox(

                constraints: const BoxConstraints(maxWidth: 850),

                child: Form(

                  key: _formKey,

                  child: ListView(

                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),

                    children: [

                      Container(

                        padding: const EdgeInsets.all(23),

                        decoration: BoxDecoration(

                          gradient: const LinearGradient(

                            colors: [navy, Color(0xFF484EB3)],

                            begin: Alignment.topLeft,

                            end: Alignment.bottomRight,

                          ),

                          borderRadius: BorderRadius.circular(25),

                        ),

                        child: const Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Icon(Icons.auto_awesome_rounded, color: Color(0xFFCACBFF), size: 28),

                            SizedBox(height: 14),

                            Text('What would you like to buy?',

                                style: TextStyle(color: Colors.white, fontSize: 25,

                                    height: 1.2, fontWeight: FontWeight.w800)),

                            SizedBox(height: 9),

                            Text('Add products or services, set your preferences, and prepare a request for quotations.',

                                style: TextStyle(color: Color(0xFFD4D7F5), height: 1.5)),

                          ],

                        ),

                      ),

                      const SizedBox(height: 20),

                      _section('Request details', 'Give your purchase a name',

                        Icons.edit_note_rounded,

                        Column(children: [

                          TextFormField(

                            controller: _title,

                            maxLength: 120,

                            decoration: _decoration('Request title *', hint: 'e.g. Office furniture purchase'),

                            validator: (v) => v == null || v.trim().isEmpty

                                ? 'Enter a request title' : null,

                          ),

                          const SizedBox(height: 10),

                          TextFormField(

                            controller: _notes,

                            maxLines: 3,

                            decoration: _decoration('Additional notes', hint: 'Anything suppliers should know...'),

                          ),

                        ]),

                      ),

                      _section('Products & services', 'Add one or more purchase items',

                        Icons.inventory_2_outlined,

                        Column(children: [

                          for (var i = 0; i < _items.length; i++) _itemEditor(_items[i], i),

                          OutlinedButton.icon(

                            onPressed: () => setState(() => _items.add(_RequestItem())),

                            icon: const Icon(Icons.add_rounded),

                            label: const Text('Add another item'),

                            style: OutlinedButton.styleFrom(

                              foregroundColor: violet,

                              minimumSize: const Size(double.infinity, 48),

                              side: const BorderSide(color: Color(0xFFCCCEFA)),

                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),

                            ),

                          ),

                        ]),

                      ),

                      _section('Budget & delivery', 'Optional purchase preferences',

                        Icons.local_shipping_outlined,

                        Column(children: [

                          TextFormField(

                            controller: _budget,

                            keyboardType: const TextInputType.numberWithOptions(decimal: true),

                            decoration: _decoration('Total budget (INR)', icon: Icons.currency_rupee_rounded),

                            validator: (v) {

                              if (v == null || v.trim().isEmpty) return null;

                              final n = double.tryParse(v.trim());

                              return n == null || !n.isFinite || n < 0 ? 'Enter a valid budget' : null;

                            },

                          ),

                          const SizedBox(height: 14),

                          TextFormField(

                            controller: _deliveryLocation,

                            decoration: _decoration('Delivery location',

                                hint: 'City / delivery address', icon: Icons.place_outlined),

                          ),

                          const SizedBox(height: 14),

                          OutlinedButton.icon(

                            onPressed: _pickDate,

                            icon: const Icon(Icons.calendar_today_outlined),

                            label: Text(_requiredBy == null

                                ? 'Select required delivery date (optional)'

                                : 'Required by ${_requiredBy!.day}/${_requiredBy!.month}/${_requiredBy!.year}'),

                            style: OutlinedButton.styleFrom(

                              foregroundColor: navy,

                              minimumSize: const Size(double.infinity, 49),

                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

                            ),

                          ),

                        ]),

                      ),

                      _section('Preferred suppliers', 'Optional — select existing contacts',

                        Icons.groups_outlined, _supplierSelector()),

                    ],

                  ),

                ),

              ),

            ),

    );

  }

}
