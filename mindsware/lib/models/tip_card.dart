import 'dart:convert';

class TipCardModel {
  final String id;
  final String category;
  final String title;
  final String summary;
  final String detail;
  final List<String> tips;
  final List<String> sources;
  final String? image;

  TipCardModel({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.detail,
    required this.tips,
    required this.sources,
    this.image,
  });

  factory TipCardModel.fromMap(Map<String, dynamic> map) {
    return TipCardModel(
      id: map['id'] as String,
      category: map['category'] as String,
      title: map['title'] as String,
      summary: map['summary'] as String,
      detail: map['detail'] as String,
      tips: List<String>.from(map['tips'] ?? const <String>[]),
      sources: List<String>.from(map['sources'] ?? const <String>[]),
      image: map['image'] as String?, 
    );
  }

  static List<TipCardModel> listFromJsonString(String jsonStr) {
    final list = json.decode(jsonStr) as List<dynamic>;
    return list.map((e) => TipCardModel.fromMap(e as Map<String, dynamic>)).toList();
  }


  String get resolvedImagePath => image ?? 'assets/tips/$id.png';
}
