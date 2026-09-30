import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'competitor_report_pdf.dart';

class CompetitorResultScreen
    extends StatefulWidget {
  final String companyName;
  final String industry;
  final List<String> selectedModules;
  final Map<String, dynamic> analysisResult;

  const CompetitorResultScreen({
    super.key,
    required this.companyName,
    required this.industry,
    required this.selectedModules,
    required this.analysisResult,
  });

  @override
  State<CompetitorResultScreen>
      createState() =>
          _CompetitorResultScreenState();
}

class _CompetitorResultScreenState
    extends State<CompetitorResultScreen> {
  bool downloading = false;

  // ==========================================================
  // HELPERS
  // ==========================================================

  List<String> _list(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .take(10)
        .toList();
  }

  Map<String, dynamic> _map(
    dynamic value,
  ) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  List<Map<String, dynamic>> _mapList(
    dynamic value,
  ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (e) =>
              Map<String, dynamic>.from(e),
        )
        .toList();
  }

  String get reportId =>
      widget.analysisResult["reportId"]
          ?.toString() ??
      "";

  String get generatedAt =>
      widget.analysisResult["generatedAt"]
          ?.toString() ??
      "";

  // ==========================================================
  // DOWNLOAD
  // ==========================================================

  Future<void> _download() async {
    if (downloading) {
      return;
    }

    setState(() {
      downloading = true;
    });

    try {
      await CompetitorReportPdf.download(
        companyName:
            widget.companyName,

        industry:
            widget.industry,

        analysisResult:
            widget.analysisResult,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Unable to create report: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          downloading = false;
        });
      }
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final executive =
        _list(
          widget.analysisResult[
              "executiveSummary"],
        );

    final company =
        _map(
          widget.analysisResult[
              "companyProfile"],
        );

    final reviews =
        _map(
          widget.analysisResult[
              "customerReviews"],
        );

    final competitors =
        _map(
          widget.analysisResult[
              "competitors"],
        );

    final growth =
        _map(
          widget.analysisResult[
              "growthIdeas"],
        );

    final risks =
        _list(
          widget.analysisResult["risks"],
        );

    final opportunities =
        _list(
          widget.analysisResult[
              "opportunities"],
        );

    final sources =
        _mapList(
          widget.analysisResult["sources"],
        );

    return Scaffold(
      backgroundColor:
          const Color(0xffF4F6FB),

      body: CustomScrollView(
        physics:
            const BouncingScrollPhysics(),

        slivers: [
          _premiumHeader(),

          SliverPadding(
            padding:
                const EdgeInsets.fromLTRB(
              18,
              20,
              18,
              120,
            ),

            sliver: SliverList(
              delegate:
                  SliverChildListDelegate(
                [
                  _overviewCard(),

                  const SizedBox(height: 22),

                  if (executive.isNotEmpty)
                    _analysisSection(
                      number: "01",
                      title:
                          "Executive Summary",
                      subtitle:
                          "What matters most",
                      icon:
                          Icons.auto_awesome_rounded,
                      items:
                          executive,
                      accent:
                          const Color(
                        0xff6750A4,
                      ),
                    ),

                  if (_list(
                    company["summary"],
                  ).isNotEmpty) ...[
                    const SizedBox(height: 18),

                    _analysisSection(
                      number: "02",
                      title:
                          "Company Profile",
                      subtitle:
                          "Business & market position",
                      icon:
                          Icons.business_rounded,
                      items:
                          _list(
                        company["summary"],
                      ),
                      accent:
                          const Color(
                        0xff2563EB,
                      ),
                    ),
                  ],

                  if (_list(
                    company["strengths"],
                  ).isNotEmpty) ...[
                    const SizedBox(height: 18),

                    _analysisSection(
                      title:
                          "Key Strengths",
                      subtitle:
                          "Areas of advantage",
                      icon:
                          Icons
                              .verified_rounded,
                      items:
                          _list(
                        company["strengths"],
                      ),
                      accent:
                          const Color(
                        0xff059669,
                      ),
                    ),
                  ],

                  if (_list(
                    company["weaknesses"],
                  ).isNotEmpty) ...[
                    const SizedBox(height: 18),

                    _analysisSection(
                      title:
                          "Key Weaknesses",
                      subtitle:
                          "Areas requiring attention",
                      icon:
                          Icons
                              .warning_amber_rounded,
                      items:
                          _list(
                        company["weaknesses"],
                      ),
                      accent:
                          const Color(
                        0xffEA580C,
                      ),
                    ),
                  ],

                  if (_list(
                    reviews["summary"],
                  ).isNotEmpty) ...[
                    const SizedBox(height: 18),

                    _analysisSection(
                      number: "03",
                      title:
                          "Customer Voice",
                      subtitle:
                          "Review intelligence",
                      icon:
                          Icons
                              .forum_rounded,
                      items:
                          _list(
                        reviews["summary"],
                      ),
                      accent:
                          const Color(
                        0xff7C3AED,
                      ),
                    ),
                  ],

                  if (_list(
                    reviews["positive"],
                  ).isNotEmpty) ...[
                    const SizedBox(height: 18),

                    _analysisSection(
                      title:
                          "Customers Love",
                      subtitle:
                          "Recurring positive themes",
                      icon:
                          Icons
                              .thumb_up_alt_rounded,
                      items:
                          _list(
                        reviews["positive"],
                      ),
                      accent:
                          const Color(
                        0xff059669,
                      ),
                    ),
                  ],

                  if (_list(
                    reviews["negative"],
                  ).isNotEmpty) ...[
                    const SizedBox(height: 18),

                    _analysisSection(
                      title:
                          "Customer Pain Points",
                      subtitle:
                          "Recurring negative themes",
                      icon:
                          Icons
                              .report_problem_rounded,
                      items:
                          _list(
                        reviews["negative"],
                      ),
                      accent:
                          const Color(
                        0xffDC2626,
                      ),
                    ),
                  ],

                  if (_list(
                    competitors["summary"],
                  ).isNotEmpty) ...[
                    const SizedBox(height: 18),

                    _analysisSection(
                      number: "04",
                      title:
                          "Competitive Landscape",
                      subtitle:
                          "Where the company stands",
                      icon:
                          Icons
                              .compare_arrows_rounded,
                      items:
                          _list(
                        competitors["summary"],
                      ),
                      accent:
                          const Color(
                        0xff0284C7,
                      ),
                    ),
                  ],

                  if (_mapList(
                    competitors["companies"],
                  ).isNotEmpty) ...[
                    const SizedBox(height: 18),

                    _competitorsCard(
                      _mapList(
                        competitors["companies"],
                      ),
                    ),
                  ],

                  if (_list(
                    growth["summary"],
                  ).isNotEmpty) ...[
                    const SizedBox(height: 18),

                    _analysisSection(
                      number: "05",
                      title:
                          "Growth Opportunities",
                      subtitle:
                          "Where to grow next",
                      icon:
                          Icons
                              .trending_up_rounded,
                      items:
                          _list(
                        growth["summary"],
                      ),
                      accent:
                          const Color(
                        0xff0D9488,
                      ),
                    ),
                  ],

                  if (_list(
                    growth["immediate"],
                  ).isNotEmpty) ...[
                    const SizedBox(height: 18),

                    _analysisSection(
                      title:
                          "Immediate Actions",
                      subtitle:
                          "0–3 month priorities",
                      icon:
                          Icons.bolt_rounded,
                      items:
                          _list(
                        growth["immediate"],
                      ),
                      accent:
                          const Color(
                        0xffF59E0B,
                      ),
                    ),
                  ],

                  if (_list(
                    growth["mediumTerm"],
                  ).isNotEmpty) ...[
                    const SizedBox(height: 18),

                    _analysisSection(
                      title:
                          "Medium-Term",
                      subtitle:
                          "3–12 month priorities",
                      icon:
                          Icons
                              .calendar_month_rounded,
                      items:
                          _list(
                        growth["mediumTerm"],
                      ),
                      accent:
                          const Color(
                        0xff6366F1,
                      ),
                    ),
                  ],

                  if (opportunities.isNotEmpty) ...[
                    const SizedBox(height: 18),

                    _analysisSection(
                      title:
                          "Opportunities",
                      subtitle:
                          "Potential upside",
                      icon:
                          Icons
                              .lightbulb_rounded,
                      items:
                          opportunities,
                      accent:
                          const Color(
                        0xff16A34A,
                      ),
                    ),
                  ],

                  if (risks.isNotEmpty) ...[
                    const SizedBox(height: 18),

                    _analysisSection(
                      title:
                          "Business Risks",
                      subtitle:
                          "What management should watch",
                      icon:
                          Icons
                              .shield_outlined,
                      items:
                          risks,
                      accent:
                          const Color(
                        0xffDC2626,
                      ),
                    ),
                  ],

                  if (sources.isNotEmpty) ...[
                    const SizedBox(height: 18),

                    _sourcesCard(
                      sources,
                    ),
                  ],

                  const SizedBox(height: 24),

                  _downloadButton(),

                  const SizedBox(height: 15),

                  _savedIndicator(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _premiumHeader() {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      elevation: 0,
      backgroundColor:
          const Color(0xff111827),

      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
        ),
      ),

      actions: [
        IconButton(
          onPressed:
              downloading
                  ? null
                  : _download,
          icon:
              downloading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons
                          .download_rounded,
                      color:
                          Colors.white,
                    ),
        ),

        const SizedBox(width: 8),
      ],

      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration:
              const BoxDecoration(
            gradient:
                LinearGradient(
              begin:
                  Alignment.topLeft,
              end:
                  Alignment.bottomRight,
              colors: [
                Color(0xff0F172A),
                Color(0xff312E81),
                Color(0xff5B21B6),
              ],
            ),
          ),

          padding:
              const EdgeInsets.fromLTRB(
            22,
            95,
            22,
            25,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white
                          .withOpacity(.12),
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
                          .auto_awesome_rounded,
                      size: 14,
                      color:
                          Color(
                        0xffDDD6FE,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "AI INTELLIGENCE REPORT",
                      style:
                          TextStyle(
                        color:
                            Color(
                          0xffDDD6FE,
                        ),
                        fontSize:
                            10,
                        fontWeight:
                            FontWeight.w700,
                        letterSpacing:
                            1.1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              Text(
                widget.companyName,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize:
                      30,
                  height:
                      1.05,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Row(
                children: [
                  Text(
                    widget.industry,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xffDDD6FE,
                      ),
                      fontSize:
                          14,
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Container(
                    width: 4,
                    height: 4,
                    decoration:
                        const BoxDecoration(
                      color:
                          Color(
                        0xffA7F3D0,
                      ),
                      shape:
                          BoxShape.circle,
                    ),
                  ),

                  const SizedBox(
                    width: 7,
                  ),

                  const Text(
                    "Analysis Complete",
                    style:
                        TextStyle(
                      color:
                          Color(
                        0xffA7F3D0,
                      ),
                      fontSize:
                          12,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // OVERVIEW
  // ==========================================================

  Widget _overviewCard() {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration:
          _cardDecoration(),

      child: Row(
        children: [
          Expanded(
            child:
                _metric(
              Icons.dashboard_rounded,
              "${widget.selectedModules.length}",
              "Modules",
            ),
          ),

          _divider(),

          Expanded(
            child:
                _metric(
              Icons
                  .travel_explore_rounded,
              "AI",
              "Researched",
            ),
          ),

          _divider(),

          Expanded(
            child:
                _metric(
              Icons
                  .cloud_done_rounded,
              "Saved",
              "Firestore",
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color:
              const Color(
            0xff6750A4,
          ),
          size: 22,
        ),

        const SizedBox(
          height: 7,
        ),

        Text(
          value,
          style:
              const TextStyle(
            color:
                Color(
              0xff111827,
            ),
            fontSize:
                16,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 2,
        ),

        Text(
          label,
          style:
              const TextStyle(
            color:
                Color(
              0xff6B7280,
            ),
            fontSize:
                10,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 45,
      width: 1,
      color:
          const Color(
        0xffE5E7EB,
      ),
    );
  }

  // ==========================================================
  // ANALYSIS SECTION
  // ==========================================================

  Widget _analysisSection({
    String? number,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> items,
    required Color accent,
  }) {
    if (items.isEmpty) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      decoration:
          _cardDecoration(),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              15,
            ),

            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration:
                      BoxDecoration(
                    color:
                        accent
                            .withOpacity(
                      .09,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color:
                        accent,
                    size:
                        22,
                  ),
                ),

                const SizedBox(
                  width: 13,
                ),

                Expanded(
                  child:
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      if (number !=
                          null)
                        Text(
                          "SECTION $number",
                          style:
                              TextStyle(
                            color:
                                accent,
                            fontSize:
                                9,
                            fontWeight:
                                FontWeight
                                    .w800,
                            letterSpacing:
                                1.2,
                          ),
                        ),

                      Text(
                        title,
                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xff111827,
                          ),
                          fontSize:
                              18,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 2,
                      ),

                      Text(
                        subtitle,
                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xff6B7280,
                          ),
                          fontSize:
                              11,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xffF3F4F6,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                  child: Text(
                    "${items.length} insights",
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xff6B7280,
                      ),
                      fontSize:
                          9,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            color:
                Color(
              0xffF1F5F9,
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.all(
              18,
            ),

            child: Column(
              children:
                  items
                      .take(10)
                      .toList()
                      .asMap()
                      .entries
                      .map(
                (entry) {
                  return _finding(
                    entry.key + 1,
                    entry.value,
                    accent,
                    entry.key ==
                        items.length - 1,
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _finding(
    int index,
    String text,
    Color accent,
    bool last,
  ) {
    return Padding(
      padding:
          EdgeInsets.only(
        bottom:
            last ? 0 : 14,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            height: 27,
            width: 27,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color:
                  accent
                      .withOpacity(
                .08,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                8,
              ),
            ),
            child: Text(
              index
                  .toString()
                  .padLeft(
                    2,
                    "0",
                  ),
              style:
                  TextStyle(
                color:
                    accent,
                fontSize:
                    9,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xff374151,
                ),
                fontSize:
                    13.5,
                height:
                    1.5,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // COMPETITORS
  // ==========================================================

  Widget _competitorsCard(
    List<Map<String, dynamic>>
        competitors,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          _cardDecoration(),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Key Competitors",
            style:
                TextStyle(
              color:
                  Color(
                0xff111827,
              ),
              fontSize:
                  18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          const Text(
            "Companies competing for similar customers",
            style:
                TextStyle(
              color:
                  Color(
                0xff6B7280,
              ),
              fontSize:
                  11,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          ...competitors
              .take(10)
              .map(
            (company) {
              return Container(
                width:
                    double.infinity,
                margin:
                    const EdgeInsets
                        .only(
                  bottom: 10,
                ),
                padding:
                    const EdgeInsets
                        .all(
                  14,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xffF8FAFC,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                  border:
                      Border.all(
                    color:
                        const Color(
                      0xffE5E7EB,
                    ),
                  ),
                ),

                child:
                    Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Container(
                      height: 38,
                      width: 38,
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xffE0E7FF,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          11,
                        ),
                      ),
                      child:
                          const Icon(
                        Icons
                            .business_center_rounded,
                        color:
                            Color(
                          0xff4F46E5,
                        ),
                        size:
                            18,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            company[
                                        "name"]
                                    ?.toString() ??
                                "",
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xff111827,
                              ),
                              fontSize:
                                  14,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            company[
                                        "reason"]
                                    ?.toString() ??
                                "",
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xff6B7280,
                              ),
                              fontSize:
                                  12,
                              height:
                                  1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SOURCES
  // ==========================================================

  Widget _sourcesCard(
    List<Map<String, dynamic>>
        sources,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          _cardDecoration(),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xffEEF2FF,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    13,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .travel_explore_rounded,
                  color:
                      Color(
                    0xff4F46E5,
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      "Research Sources",
                      style:
                          TextStyle(
                        fontSize:
                            17,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),

                    Text(
                      "${sources.length} sources referenced",
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xff6B7280,
                        ),
                        fontSize:
                            11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          ...sources
              .take(10)
              .map(
            (source) {
              final title =
                  source["title"]
                          ?.toString() ??
                      "Source";

              final url =
                  source["url"]
                          ?.toString() ??
                      "";

              return InkWell(
                onTap:
                    url.isEmpty
                        ? null
                        : () async {
                            final uri =
                                Uri.tryParse(
                              url,
                            );

                            if (uri !=
                                    null &&
                                await canLaunchUrl(
                                  uri,
                                )) {
                              await launchUrl(
                                uri,
                                mode:
                                    LaunchMode
                                        .externalApplication,
                              );
                            }
                          },

                child:
                    Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 9,
                  ),

                  child:
                      Row(
                    children: [
                      const Icon(
                        Icons
                            .link_rounded,
                        size:
                            17,
                        color:
                            Color(
                          0xff6366F1,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child:
                            Text(
                          title,
                          maxLines:
                              2,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xff374151,
                            ),
                            fontSize:
                                12,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons
                            .open_in_new_rounded,
                        size:
                            14,
                        color:
                            Color(
                          0xff9CA3AF,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DOWNLOAD
  // ==========================================================

  Widget _downloadButton() {
    return SizedBox(
      width:
          double.infinity,
      height:
          58,

      child:
          ElevatedButton.icon(
        onPressed:
            downloading
                ? null
                : _download,

        style:
            ElevatedButton
                .styleFrom(
          elevation:
              0,
          backgroundColor:
              const Color(
            0xff111827,
          ),
          foregroundColor:
              Colors.white,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              17,
            ),
          ),
        ),

        icon:
            downloading
                ? const SizedBox(
                    height:
                        18,
                    width:
                        18,
                    child:
                        CircularProgressIndicator(
                      strokeWidth:
                          2,
                      color:
                          Colors.white,
                    ),
                  )
                : const Icon(
                    Icons
                        .picture_as_pdf_rounded,
                  ),

        label:
            Text(
          downloading
              ? "Preparing Report..."
              : "Download Full Report",
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SAVED INDICATOR
  // ==========================================================

  Widget _savedIndicator() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        const Icon(
          Icons
              .cloud_done_outlined,
          size:
              15,
          color:
              Color(
            0xff059669,
          ),
        ),

        const SizedBox(
          width: 6,
        ),

        Text(
          reportId.isEmpty
              ? "Report saved"
              : "Saved • Report $reportId",
          style:
              const TextStyle(
            color:
                Color(
              0xff6B7280,
            ),
            fontSize:
                10,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color:
          Colors.white,
      borderRadius:
          BorderRadius.circular(
        22,
      ),
      border:
          Border.all(
        color:
            const Color(
          0xffE9ECF2,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color:
              Colors.black
                  .withOpacity(
            .035,
          ),
          blurRadius:
              22,
          offset:
              const Offset(
            0,
            8,
          ),
        ),
      ],
    );
  }
}