import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'dart:async';

class recipes {
  int? id;
  String? name;
  String? source;
  int? preptime;
  int? waittime;
  int? cooktime;
  int? servings;
  String? comments;
  int? calories;
  int? fat;
  int? satfat;
  int? carbs;
  int? fiber;
  int? sugar;
  int? protein;
  String? instructions;
  List<dynamic>? ingredients;
  List<dynamic>? tags;

  recipes(
      {this.id,
      this.name,
      this.source,
      this.preptime,
      this.waittime,
      this.cooktime,
      this.servings,
      this.comments,
      this.calories,
      this.fat,
      this.satfat,
      this.carbs,
      this.fiber,
      this.sugar,
      this.protein,
      this.instructions,
      this.ingredients,
      this.tags});

  recipes.fromJSON(Map<String, dynamic> json) {
    id = json['id'];
    name = json["name"];
    source = json['source'];
    preptime = json['preptime'];
    waittime = json['waittime'];
    cooktime = json['cooktime'];
    servings = json['servings'];
    comments = json['comments'];
    calories = json['calories'];
    fat = json['fat'];
    satfat = json['satfat'];
    carbs = json['carbs'];
    fiber = json['fiber'];
    sugar = json['sugar'];
    protein = json['protein'];
    instructions = json['instructions'];
    ingredients = json['ingredients'];
    tags = json['tags'];
  }

  pullFromDB() async {
    final response = await http.get(Uri.parse(
        'http://3.145.164.187/RecipeRecommender/RecipeRecommender-Backend.py/items'));
    print(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load items');
    }
  }
}
