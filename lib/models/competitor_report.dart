class ReviewItem {
  final String author, text, source;
  final double rating;
  const ReviewItem({required this.author, required this.text, required this.source, required this.rating});
  factory ReviewItem.fromJson(Map<String,dynamic> j) => ReviewItem(
    author: '${j['author'] ?? 'Anonymous'}', text: '${j['text'] ?? ''}', source: '${j['source'] ?? ''}',
    rating: (j['rating'] as num?)?.toDouble() ?? 0,
  );
}

class CompetitorReport {
  final String company, website, summary, lastUpdated;
  final double rating, sentiment;
  final int reviewCount;
  final List<String> strengths, weaknesses, opportunities, positiveThemes, negativeThemes, sources;
  final List<ReviewItem> positiveReviews, negativeReviews;
  const CompetitorReport({required this.company, required this.website, required this.summary, required this.lastUpdated,
    required this.rating, required this.sentiment, required this.reviewCount, required this.strengths, required this.weaknesses,
    required this.opportunities, required this.positiveThemes, required this.negativeThemes, required this.sources,
    required this.positiveReviews, required this.negativeReviews});
  static List<String> _s(dynamic v) => (v as List? ?? []).map((e)=>'$e').toList();
  static List<ReviewItem> _r(dynamic v) => (v as List? ?? []).whereType<Map>().map((e)=>ReviewItem.fromJson(Map<String,dynamic>.from(e))).toList();
  factory CompetitorReport.fromJson(Map<String,dynamic> j) => CompetitorReport(
    company:'${j['company']??''}', website:'${j['website']??''}', summary:'${j['summary']??''}', lastUpdated:'${j['lastUpdated']??''}',
    rating:(j['rating'] as num?)?.toDouble()??0, sentiment:(j['sentiment'] as num?)?.toDouble()??0, reviewCount:(j['reviewCount'] as num?)?.toInt()??0,
    strengths:_s(j['strengths']), weaknesses:_s(j['weaknesses']), opportunities:_s(j['opportunities']), positiveThemes:_s(j['positiveThemes']),
    negativeThemes:_s(j['negativeThemes']), sources:_s(j['sources']), positiveReviews:_r(j['positiveReviews']), negativeReviews:_r(j['negativeReviews']));
}
