// ignore_for_file: prefer_const_constructors, avoid_print, unnecessary_question_mark, prefer_void_to_null, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class QuranController extends GetxController {
  var quran = Quran().obs;

  @override
  void onInit() {
    super.onInit();
    fetchQuran();
  }

  void fetchQuran() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var quranData = sharedPreferences.getString('quranData');

    if (quranData != null) {
      quran.value = Quran.fromJson(json.decode(quranData));
    } else {
      var url =
          'http://api.quran.com/api/v3/search?q=quran&size=20&page=0&language=en';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == HttpStatus.ok) {
        var responseBody = response.body;
        sharedPreferences.setString('quranData', responseBody);

        quran.value = Quran.fromJson(json.decode(responseBody));
      } else {
        print('Error fetching data from server');
      }
    }
  }
}

class QuranApp extends StatelessWidget {
  final QuranController quranController = Get.put(QuranController());

  QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[200],
      appBar: AppBar(
        title: Text('Quran App'),
      ),
      body: Obx(
        () => quranController.quran.value.search == null
            ? Center(child: CircularProgressIndicator())
            : AnimationLimiter(
                child: ListView.builder(
                  itemCount:
                      quranController.quran.value.search!.results!.length,
                  itemBuilder: (BuildContext context, int index) {
                    Results result =
                        quranController.quran.value.search!.results![index];

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Card(
                            color: Colors.blueGrey[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            margin: EdgeInsets.all(10.0),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Verse Key: ${result.verseKey}',
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 10.0),
                                  Text(
                                    'Text: ${result.text}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 10.0),
                                  Text.rich(
                                    parseText(
                                      'Translation: ${result.translations!.first.text}',
                                    ),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class Quran {
  Search? search;

  Quran({this.search});

  Quran.fromJson(Map<String, dynamic> json) {
    search = json['search'] != null ? Search.fromJson(json['search']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (search != null) {
      data['search'] = search!.toJson();
    }
    return data;
  }
}

class Search {
  String? query;
  int? totalResults;
  int? currentPage;
  int? totalPages;
  List<Results>? results;

  Search(
      {this.query,
      this.totalResults,
      this.currentPage,
      this.totalPages,
      this.results});

  Search.fromJson(Map<String, dynamic> json) {
    query = json['query'];
    totalResults = json['total_results'];
    currentPage = json['current_page'];
    totalPages = json['total_pages'];
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['query'] = query;
    data['total_results'] = totalResults;
    data['current_page'] = currentPage;
    data['total_pages'] = totalPages;
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? verseKey;
  int? verseId;
  String? text;
  Null? highlighted;
  List<Words>? words;
  List<Translations>? translations;

  Results(
      {this.verseKey,
      this.verseId,
      this.text,
      this.highlighted,
      this.words,
      this.translations});

  Results.fromJson(Map<String, dynamic> json) {
    verseKey = json['verse_key'];
    verseId = json['verse_id'];
    text = json['text'];
    highlighted = json['highlighted'];
    if (json['words'] != null) {
      words = <Words>[];
      json['words'].forEach((v) {
        words!.add(Words.fromJson(v));
      });
    }
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['verse_key'] = verseKey;
    data['verse_id'] = verseId;
    data['text'] = text;
    data['highlighted'] = highlighted;
    if (words != null) {
      data['words'] = words!.map((v) => v.toJson()).toList();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Words {
  String? charType;
  String? text;

  Words({this.charType, this.text});

  Words.fromJson(Map<String, dynamic> json) {
    charType = json['char_type'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['char_type'] = charType;
    data['text'] = text;
    return data;
  }
}

class Translations {
  String? text;
  int? resourceId;
  String? name;
  String? languageName;

  Translations({this.text, this.resourceId, this.name, this.languageName});

  Translations.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    resourceId = json['resource_id'];
    name = json['name'];
    languageName = json['language_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['resource_id'] = resourceId;
    data['name'] = name;
    data['language_name'] = languageName;
    return data;
  }
}

TextSpan parseText(String text) {
  final regex = RegExp('<em>Quran</em>', caseSensitive: false);
  final matches = regex.allMatches(text);
  if (matches.isEmpty) {
    return TextSpan(text: text);
  }

  final textSpans = <TextSpan>[];
  int start = 0;
  for (final match in matches) {
    final before = text.substring(start, match.start);
    final after = text.substring(match.end);

    if (before.isNotEmpty) {
      textSpans.add(TextSpan(text: before));
    }

    textSpans.add(TextSpan(
      text: 'Quran',
      style: TextStyle(fontWeight: FontWeight.bold),
    ));

    start = match.end;

    if (after.isEmpty) {
      textSpans.add(TextSpan(text: after));
    }
  }

  if (start < text.length) {
    textSpans.add(TextSpan(text: text.substring(start)));
  }

  return TextSpan(children: textSpans);
}
