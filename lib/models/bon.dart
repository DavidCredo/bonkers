import 'package:bonkers/models/article.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Bon {
  Bon({required this.title, required this.createdAt, required this.articles});

  final String title;
  final Timestamp createdAt;
  final List<Article> articles;

  factory Bon.fromJson(Map<String, dynamic> data) {
    final title = data['title'] as String;
    final createdAt = data['createdAt'] as Timestamp;
    final articlesData = data['articles'] as List<dynamic>;
    final articles = articlesData
        .map((articleData) => Article.fromJson(articleData))
        .toList();

    return Bon(articles: articles, createdAt: createdAt, title: title);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'createdAt': createdAt,
      'articles': articles.map((article) => article.toJson()).toList(),
    };
  }
}
