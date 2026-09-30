import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/competitor_report.dart';

class ApiService {
  // IMPORTANT: point this at YOUR server. Never put OpenAI/Google/Search API secrets in Flutter.
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  Future<CompetitorReport> analyze(String company, {String? website}) async {
    if (baseUrl.isEmpty) return _demo(company);
    final r = await http.post(Uri.parse('$baseUrl/v1/competitors/analyze'), headers:{'Content-Type':'application/json'},
      body:jsonEncode({'company':company,'website':website}));
    if (r.statusCode < 200 || r.statusCode >= 300) throw Exception('Analysis failed (${r.statusCode})');
    return CompetitorReport.fromJson(jsonDecode(r.body));
  }

  Future<void> setMonitoring(String company, String frequency) async {
    if (baseUrl.isEmpty) return;
    final r = await http.post(Uri.parse('$baseUrl/v1/competitors/monitor'), headers:{'Content-Type':'application/json'},
      body:jsonEncode({'company':company,'frequency':frequency,'enabled':true}));
    if (r.statusCode < 200 || r.statusCode >= 300) throw Exception('Monitoring setup failed');
  }

  CompetitorReport _demo(String company) => CompetitorReport(
    company: company, website:'', summary:'Demo mode: connect API_BASE_URL to your backend to research the web, permitted review sources and news, then return evidence-grounded AI analysis.',
    lastUpdated:DateTime.now().toIso8601String(), rating:4.2, sentiment:72, reviewCount:1250,
    strengths:const ['Strong brand awareness','Broad product assortment','Physical retail presence'],
    weaknesses:const ['Customer experience can vary by location','Digital experience has room for improvement'],
    opportunities:const ['Improve omnichannel journey','Track recurring customer complaints','Benchmark promotions against competitors'],
    positiveThemes:const ['Product variety','Selection','Store experience'], negativeThemes:const ['Wait time','Service consistency'],
    positiveReviews:const [ReviewItem(author:'Demo customer',text:'Good selection and a wide range of products.',source:'Demo',rating:5)],
    negativeReviews:const [ReviewItem(author:'Demo customer',text:'Service was slower than expected during a busy period.',source:'Demo',rating:2)],
    sources:const ['Demo data — backend not connected']);
}
