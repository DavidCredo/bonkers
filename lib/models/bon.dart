import 'package:bonkers/models/bon_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Bon {
  Bon(
      {required this.title,
      required this.createdAt,
      required this.articles,
      required this.uid});
  final String uid;
  final String title;
  final Timestamp createdAt;
  final List<BonItem> articles;

  factory Bon.fromJson(Map<String, dynamic> data) {
    final title = data['title'] as String;
    final createdAt = data['createdAt'] as Timestamp;
    final articlesData = data['articles'] as List<dynamic>;
    final articles = articlesData
        .map((articleData) => BonItem.fromJson(articleData))
        .toList();
    final uid = data['uid'] as String;
    return Bon(
        articles: articles, createdAt: createdAt, title: title, uid: uid);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'createdAt': createdAt,
      'articles': articles.map((article) => article.toJson()).toList(),
      'uid': uid,
    };
  }
}
