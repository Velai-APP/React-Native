import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_gst_registration_screen.dart';

class AdminRegistrationApplicationsScreen
    extends StatefulWidget {
  const AdminRegistrationApplicationsScreen({
    super.key,
  });

  @override
  State<AdminRegistrationApplicationsScreen>
      createState() =>
          _AdminRegistrationApplicationsScreenState();
}

class _AdminRegistrationApplicationsScreenState
    extends State<AdminRegistrationApplicationsScreen> {

  String selectedFilter = 'All';

  final filters = [
    'All',
    'Submitted',
    'Under Review',
    'Documents Pending',
    'Ready for Filing',
    'Filed',
    'Completed',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F6FA),

      body: SafeArea(
        child: StreamBuilder<
            QuerySnapshot<
                Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection(
                'registrationApplications',
              )
              .snapshots(),

          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Unable to load applications\n'
                  '${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                ),
              );
            }

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            final docs =
                snapshot.data?.docs ?? [];

            docs.sort(
              (a, b) {
                final aTime =
                    a.data()['createdAt']
                        as Timestamp?;

                final bTime =
                    b.data()['createdAt']
                        as Timestamp?;

                if (aTime == null ||
                    bTime == null) {
                  return 0;
                }

                return bTime.compareTo(
                  aTime,
                );
              },
            );

            final applications =
                docs.where((doc) {
              final status =
                  doc.data()['status']
                      ?.toString() ??
                  '';

              if (selectedFilter ==
                  'All') {
                return true;
              }

              return _statusTitle(status) ==
                  selectedFilter;
            }).toList();

            return CustomScrollView(
              physics:
                  const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child:
                      _buildHeader(docs),
                ),

                SliverToBoxAdapter(
                  child:
                      _buildSummary(docs),
                ),

                SliverToBoxAdapter(
                  child:
                      _buildFilters(),
                ),

                if (applications.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No applications found',
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      16,
                      2,
                      16,
                      30,
                    ),
                    sliver:
                        SliverList.separated(
                      itemCount:
                          applications.length,

                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(
                        height: 13,
                      ),

                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        final doc =
                            applications[
                                index];

                        return _applicationCard(
                          doc,
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader(
    List<
            QueryDocumentSnapshot<
                Map<String, dynamic>>>
        docs,
  ) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        14,
        12,
        14,
        0,
      ),

      padding:
          const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        23,
      ),

      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF111827),
            Color(0xFF312E81),
            Color(0xFF4F46E5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius:
            BorderRadius.circular(
          30,
        ),

        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF4F46E5,
            ).withOpacity(.18),
            blurRadius: 28,
            offset:
                const Offset(0, 14),
          ),
        ],
      ),

      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -45,
            child: Container(
              height: 160,
              width: 160,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                color: Colors.white
                    .withOpacity(.06),
              ),
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () =>
                        Navigator.pop(
                      context,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      50,
                    ),
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color: Colors.white
                            .withOpacity(
                          .10,
                        ),
                      ),
                      child:
                          const Icon(
                        Icons
                            .arrow_back_ios_new_rounded,
                        color:
                            Colors.white,
                        size: 18,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.white
                          .withOpacity(.10),
                      borderRadius:
                          BorderRadius.circular(
                        30,
                      ),
                    ),
                    child:
                        const Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .admin_panel_settings_outlined,
                          color:
                              Colors.white,
                          size: 15,
                        ),
                        SizedBox(
                            width: 6),
                        Text(
                          'ADMIN PANEL',
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            fontSize:
                                10,
                            letterSpacing:
                                .8,
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 28,
              ),

              const Text(
                'Registration\nApplications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  height: 1.1,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: -.5,
                ),
              ),

              const SizedBox(
                height: 9,
              ),

              Text(
                'Review customer applications and update their registration progress.',
                style: TextStyle(
                  color: Colors.white
                      .withOpacity(.70),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SUMMARY
  // ==========================================================

  Widget _buildSummary(
    List<
            QueryDocumentSnapshot<
                Map<String, dynamic>>>
        docs,
  ) {
    final submitted =
        docs.where((doc) {
      return doc.data()['status'] ==
          'submitted';
    }).length;

    final review =
        docs.where((doc) {
      return doc.data()['status'] ==
          'underReview';
    }).length;

    final completed =
        docs.where((doc) {
      final status =
          doc.data()['status'];

      return status == 'approved' ||
          status == 'completed';
    }).length;

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        14,
      ),
      child: Row(
        children: [
          Expanded(
            child:
                _summaryCard(
              '${docs.length}',
              'Total',
              Icons
                  .description_outlined,
              const Color(
                0xFF4F46E5,
              ),
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child:
                _summaryCard(
              '$submitted',
              'New',
              Icons
                  .fiber_new_rounded,
              const Color(
                0xFF2563EB,
              ),
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child:
                _summaryCard(
              '$review',
              'Review',
              Icons
                  .manage_search_outlined,
              const Color(
                0xFFF59E0B,
              ),
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child:
                _summaryCard(
              '$completed',
              'Done',
              Icons
                  .verified_outlined,
              const Color(
                0xFF059669,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    String value,
    String title,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 13,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color:
              const Color(0xFFE5E7EB),
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style:
                const TextStyle(
              color:
                  Color(0xFF111827),
              fontSize: 19,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          Text(
            title,
            style:
                const TextStyle(
              color:
                  Color(0xFF9CA3AF),
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FILTERS
  // ==========================================================

  Widget _buildFilters() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        2,
        0,
        17,
      ),

      child: SizedBox(
        height: 38,

        child:
            ListView.separated(
          scrollDirection:
              Axis.horizontal,

          itemCount:
              filters.length,

          separatorBuilder:
              (_, __) =>
                  const SizedBox(
            width: 8,
          ),

          itemBuilder:
              (context, index) {
            final filter =
                filters[index];

            final selected =
                selectedFilter ==
                    filter;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter =
                      filter;
                });
              },

              child:
                  AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 180,
                ),

                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 15,
                ),

                alignment:
                    Alignment.center,

                decoration:
                    BoxDecoration(
                  color: selected
                      ? const Color(
                          0xFF111827,
                        )
                      : Colors.white,

                  borderRadius:
                      BorderRadius
                          .circular(
                    30,
                  ),

                  border:
                      Border.all(
                    color: selected
                        ? const Color(
                            0xFF111827,
                          )
                        : const Color(
                            0xFFE5E7EB,
                          ),
                  ),
                ),

                child: Text(
                  filter,
                  style:
                      TextStyle(
                    color: selected
                        ? Colors.white
                        : const Color(
                            0xFF6B7280,
                          ),
                    fontSize: 11,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // APPLICATION CARD
  // ==========================================================

  Widget _applicationCard(
    QueryDocumentSnapshot<
            Map<String, dynamic>>
        doc,
  ) {
    final data = doc.data();

    final type =
        (data[
                    'registrationType'] ??
                'Registration')
            .toString();

    final status =
        (data['status'] ??
                'submitted')
            .toString();

    final name =
        _businessName(data);

    final style =
        _typeStyle(type);

    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          24,
        ),

      onTap: () {
  final registrationType =
      data['registrationType']
          ?.toString()
          .trim()
          .toUpperCase();

  if (registrationType == 'GST') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminGstRegistrationScreen(
          applicationId: doc.id,
        ),
      ),
    );

    return;
  }

  // Other applications for now
  _openApplication(
    doc.id,
    data,
  );
},

        child: Ink(
          padding:
              const EdgeInsets.all(17),

          decoration:
              BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(
              24,
            ),

            border: Border.all(
              color:
                  const Color(
                0xFFE7EAF0,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(.025),
                blurRadius: 18,
                offset:
                    const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),

          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,

                decoration:
                    BoxDecoration(
                  color: style.color
                      .withOpacity(.09),

                  borderRadius:
                      BorderRadius
                          .circular(
                    16,
                  ),
                ),

                child: Icon(
                  style.icon,
                  color: style.color,
                  size: 24,
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            type,
                            style:
                                TextStyle(
                              color: style
                                  .color,
                              fontSize: 9.5,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              letterSpacing:
                                  .6,
                            ),
                          ),
                        ),

                        _statusBadge(
                          status,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      name,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        color: Color(
                          0xFF111827,
                        ),
                        fontSize: 15.5,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      'Tap to review & update',
                      style:
                          const TextStyle(
                        color: Color(
                          0xFF9CA3AF,
                        ),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 15,
                color:
                    Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // APPLICATION DETAILS
  // ==========================================================

  void _openApplication(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final type =
        data['registrationType']
                ?.toString() ??
            'Registration';

    final status =
        data['status']
                ?.toString() ??
            'submitted';

    final name =
        _businessName(data);

    final style =
        _typeStyle(type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,

      builder: (
        sheetContext,
      ) {
        return DraggableScrollableSheet(
          initialChildSize: .84,
          minChildSize: .60,
          maxChildSize: .95,
          expand: false,

          builder: (
            context,
            scrollController,
          ) {
            return Container(
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFF7F8FA),

                borderRadius:
                    BorderRadius.vertical(
                  top:
                      Radius.circular(
                    30,
                  ),
                ),
              ),

              child: ListView(
                controller:
                    scrollController,

                padding:
                    const EdgeInsets
                        .fromLTRB(
                  18,
                  12,
                  18,
                  35,
                ),

                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFD1D5DB,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 23,
                  ),

                  // ==============================================
                  // HERO
                  // ==============================================

                  Container(
                    padding:
                        const EdgeInsets
                            .all(
                      19,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          style.color,

                      borderRadius:
                          BorderRadius
                              .circular(
                        24,
                      ),
                    ),

                    child: Row(
                      children: [
                        Container(
                          height: 55,
                          width: 55,

                          decoration:
                              BoxDecoration(
                            color: Colors
                                .white
                                .withOpacity(
                              .15,
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              17,
                            ),
                          ),

                          child: Icon(
                            style.icon,
                            color:
                                Colors.white,
                            size: 27,
                          ),
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                type,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white70,
                                  fontSize:
                                      10.5,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                name,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize:
                                      18,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // ==============================================
                  // CURRENT STATUS
                  // ==============================================

                  const Text(
                    'Current Status',
                    style: TextStyle(
                      color:
                          Color(0xFF111827),
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 11,
                  ),

                  _statusSelection(
                    currentStatus:
                        status,

                    documentId:
                        documentId,

                    sheetContext:
                        sheetContext,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ==============================================
                  // APPLICATION INFO
                  // ==============================================

                  _detailsCard(
                    data,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // STATUS UPDATE
  // ==========================================================

  Widget _statusSelection({
    required String
        currentStatus,

    required String
        documentId,

    required BuildContext
        sheetContext,
  }) {
    final statuses = [
      _AdminStatus(
        value: 'submitted',
        title: 'Submitted',
        subtitle:
            'Application received',
        icon:
            Icons.description_outlined,
      ),

      _AdminStatus(
        value: 'underReview',
        title: 'Under Review',
        subtitle:
            'Verification in progress',
        icon:
            Icons.manage_search_rounded,
      ),

      _AdminStatus(
        value: 'documentsPending',
        title:
            'Documents Pending',
        subtitle:
            'Customer action required',
        icon:
            Icons.upload_file_rounded,
      ),

      _AdminStatus(
        value: 'readyForFiling',
        title:
            'Ready for Filing',
        subtitle:
            'Verification completed',
        icon:
            Icons.task_alt_rounded,
      ),

      _AdminStatus(
        value: 'filed',
        title: 'Filed',
        subtitle:
            'Submitted to authority',
        icon:
            Icons.cloud_done_outlined,
      ),

      _AdminStatus(
        value: 'approved',
        title: 'Completed',
        subtitle:
            'Registration completed',
        icon:
            Icons.verified_rounded,
      ),
    ];

    return Container(
      padding:
          const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        border: Border.all(
          color:
              const Color(
            0xFFE5E7EB,
          ),
        ),
      ),

      child: Column(
        children:
            statuses.map((status) {
          final selected =
              currentStatus ==
                  status.value;

          return InkWell(
            onTap: () {
              if (!selected) {
                _confirmStatusUpdate(
                  sheetContext:
                      sheetContext,

                  documentId:
                      documentId,

                  status:
                      status,
                );
              }
            },

            borderRadius:
                BorderRadius.circular(
              15,
            ),

            child: Container(
              margin:
                  const EdgeInsets
                      .only(
                bottom: 7,
              ),

              padding:
                  const EdgeInsets
                      .all(
                12,
              ),

              decoration:
                  BoxDecoration(
                color: selected
                    ? const Color(
                        0xFFEEF2FF,
                      )
                    : Colors
                        .transparent,

                borderRadius:
                    BorderRadius
                        .circular(
                  15,
                ),

                border: Border.all(
                  color: selected
                      ? const Color(
                          0xFFC7D2FE,
                        )
                      : const Color(
                          0xFFF0F1F3,
                        ),
                ),
              ),

              child: Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,

                    decoration:
                        BoxDecoration(
                      color: selected
                          ? const Color(
                              0xFF4F46E5,
                            )
                          : const Color(
                              0xFFF3F4F6,
                            ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),

                    child: Icon(
                      status.icon,

                      color: selected
                          ? Colors.white
                          : const Color(
                              0xFF6B7280,
                            ),

                      size: 18,
                    ),
                  ),

                  const SizedBox(
                    width: 11,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Text(
                          status.title,

                          style:
                              TextStyle(
                            color:
                                const Color(
                              0xFF111827,
                            ),

                            fontSize:
                                12.5,

                            fontWeight:
                                selected
                                    ? FontWeight
                                        .w800
                                    : FontWeight
                                        .w700,
                          ),
                        ),

                        const SizedBox(
                          height: 2,
                        ),

                        Text(
                          status.subtitle,

                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF9CA3AF,
                            ),

                            fontSize:
                                10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (selected)
                    const Icon(
                      Icons
                          .check_circle_rounded,
                      color:
                          Color(
                        0xFF4F46E5,
                      ),
                      size: 20,
                    )
                  else
                    const Icon(
                      Icons
                          .chevron_right_rounded,
                      color:
                          Color(
                        0xFFD1D5DB,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _confirmStatusUpdate({
    required BuildContext
        sheetContext,

    required String
        documentId,

    required _AdminStatus
        status,
  }) {
    final remarksController =
        TextEditingController();

    showDialog(
      context: context,

      builder: (
        dialogContext,
      ) {
        bool updating = false;

        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  22,
                ),
              ),

              title: Text(
                'Change to ${status.title}?',
              ),

              content: Column(
                mainAxisSize:
                    MainAxisSize.min,

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Text(
                    'The customer will see this status immediately.',
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF6B7280,
                      ),
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  TextField(
                    controller:
                        remarksController,

                    maxLines: 3,

                    decoration:
                        InputDecoration(
                      labelText:
                          'Remarks (optional)',

                      hintText:
                          'Add note for customer',

                      filled: true,

                      fillColor:
                          const Color(
                        0xFFF8FAFC,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: updating
                      ? null
                      : () =>
                          Navigator.pop(
                        dialogContext,
                      ),
                  child:
                      const Text(
                    'Cancel',
                  ),
                ),

                ElevatedButton(
                  onPressed:
                      updating
                          ? null
                          : () async {
                              setDialogState(
                                () {
                                  updating =
                                      true;
                                },
                              );

                              try {
                                await _updateStatus(
                                  documentId:
                                      documentId,

                                  status:
                                      status,

                                  remarks:
                                      remarksController
                                          .text
                                          .trim(),
                                );

                                if (!mounted) {
                                  return;
                                }

                                Navigator.pop(
                                  dialogContext,
                                );

                                Navigator.pop(
                                  sheetContext,
                                );

                                ScaffoldMessenger
                                        .of(
                                  context,
                                )
                                    .showSnackBar(
                                  SnackBar(
                                    behavior:
                                        SnackBarBehavior
                                            .floating,
                                    content: Text(
                                      'Status updated to ${status.title}',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                setDialogState(
                                  () {
                                    updating =
                                        false;
                                  },
                                );

                                if (!mounted) {
                                  return;
                                }

                                ScaffoldMessenger
                                        .of(
                                  context,
                                )
                                    .showSnackBar(
                                  SnackBar(
                                    content:
                                        Text(
                                      'Unable to update: $e',
                                    ),
                                  ),
                                );
                              }
                            },

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF4F46E5,
                    ),

                    foregroundColor:
                        Colors.white,
                  ),

                  child: updating
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Text(
                          'Update Status',
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateStatus({
    required String documentId,
    required _AdminStatus status,
    required String remarks,
  }) async {
    final ref =
        FirebaseFirestore.instance
            .collection(
              'registrationApplications',
            )
            .doc(documentId);

    final historyItem = {
      'status': status.value,
      'title': status.title,
      'remarks': remarks,
      'timestamp':
          Timestamp.now(),
    };

    await ref.update({
      'status':
          status.value,

      'statusMessage':
          status.subtitle,

      'adminRemarks':
          remarks,

      'updatedAt':
          FieldValue.serverTimestamp(),

      'statusHistory':
          FieldValue.arrayUnion(
        [
          historyItem,
        ],
      ),

      if (status.value ==
          'approved')
        'completedAt':
            FieldValue
                .serverTimestamp(),
    });
  }

  // ==========================================================
  // DETAILS
  // ==========================================================

  Widget _detailsCard(
    Map<String, dynamic> data,
  ) {
    final email =
        data['email'] ??
            data['contact']?['email'] ??
            '';

    final mobile =
        data['mobile'] ??
            data['contact']?['mobile'] ??
            '';

    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        border: Border.all(
          color:
              const Color(
            0xFFE5E7EB,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Application Details',
            style: TextStyle(
              color:
                  Color(0xFF111827),
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          _detailRow(
            'Type',
            data['registrationType']
                    ?.toString() ??
                '-',
          ),

          _detailRow(
            'Business',
            _businessName(data),
          ),

          if (email
              .toString()
              .isNotEmpty)
            _detailRow(
              'Email',
              email.toString(),
            ),

          if (mobile
              .toString()
              .isNotEmpty)
            _detailRow(
              'Mobile',
              mobile.toString(),
            ),

          _detailRow(
            'Application ID',
            data['applicationId']
                    ?.toString() ??
                '-',
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style:
                  const TextStyle(
                color:
                    Color(0xFF9CA3AF),
                fontSize: 11.5,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(
                color:
                    Color(0xFF111827),
                fontSize: 12.5,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  String _businessName(
    Map<String, dynamic> data,
  ) {
    return (
      data['enterpriseName'] ??
      data['legalName'] ??
      data['tradeName'] ??
      data['firmName'] ??
      data['proposedNames']?[0] ??
      'Registration Application'
    ).toString();
  }

  Widget _statusBadge(
    String status,
  ) {
    final color =
        _statusColor(status);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color:
            color.withOpacity(.09),

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Text(
        _statusTitle(status),

        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight:
              FontWeight.w800,
        ),
      ),
    );
  }

  String _statusTitle(
    String status,
  ) {
    switch (status) {
      case 'submitted':
        return 'Submitted';

      case 'underReview':
        return 'Under Review';

      case 'documentsPending':
        return 'Documents Pending';

      case 'readyForFiling':
        return 'Ready for Filing';

      case 'filed':
        return 'Filed';

      case 'approved':
      case 'completed':
        return 'Completed';

      default:
        return 'Processing';
    }
  }

  Color _statusColor(
    String status,
  ) {
    switch (status) {
      case 'submitted':
        return const Color(
          0xFF2563EB,
        );

      case 'underReview':
        return const Color(
          0xFFF59E0B,
        );

      case 'documentsPending':
        return const Color(
          0xFFDC2626,
        );

      case 'readyForFiling':
        return const Color(
          0xFF7C3AED,
        );

      case 'filed':
        return const Color(
          0xFF0891B2,
        );

      case 'approved':
      case 'completed':
        return const Color(
          0xFF059669,
        );

      default:
        return const Color(
          0xFF6B7280,
        );
    }
  }

  _TypeStyle _typeStyle(
    String type,
  ) {
    switch (
        type.toUpperCase()) {
      case 'GST':
        return const _TypeStyle(
          Icons.receipt_long_outlined,
          Color(0xFF2563EB),
        );

      case 'MSME':
        return const _TypeStyle(
          Icons.factory_outlined,
          Color(0xFF0F766E),
        );

      case 'IEC':
        return const _TypeStyle(
          Icons.public_rounded,
          Color(0xFF0891B2),
        );

      case 'PROPRIETORSHIP':
        return const _TypeStyle(
          Icons.person_outline_rounded,
          Color(0xFFEA580C),
        );

      case 'PARTNERSHIP':
        return const _TypeStyle(
          Icons.handshake_outlined,
          Color(0xFF0891B2),
        );

      case 'LLP':
        return const _TypeStyle(
          Icons.groups_2_outlined,
          Color(0xFF7C3AED),
        );

      case 'PRIVATE LIMITED':
        return const _TypeStyle(
          Icons.apartment_rounded,
          Color(0xFFBE123C),
        );

      default:
        return const _TypeStyle(
          Icons.description_outlined,
          Color(0xFF4F46E5),
        );
    }
  }
}

class _AdminStatus {
  final String value;
  final String title;
  final String subtitle;
  final IconData icon;

  const _AdminStatus({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _TypeStyle {
  final IconData icon;
  final Color color;

  const _TypeStyle(
    this.icon,
    this.color,
  );
}