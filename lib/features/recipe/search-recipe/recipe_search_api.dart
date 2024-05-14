import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class RecipeSearchAPI {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  RecipeSearchAPI(this._firestore, this._firebaseAuth);

  // with ingredients
  // https://api.edamam.com/api/recipes/v2?type=public&app_id=your_app_id&app_key=your_app_key&q=chicken,garlic,onion&random=true

  // Future<List<Recipe>> fetchRecipes(List<String> ingredients) async {
  //   String ingredientQuery = ingredients.join(',');
  //   var url = Uri.parse(
  //       'https://api.edamam.com/api/recipes/v2?type=public&app_id=your_app_id&app_key=your_app_key&q=$ingredientQuery&random=true');
  //
  //   var response = await http.get(url);
  //   if (response.statusCode == 200) {
  //     var data = json.decode(response.body);
  //     List<Recipe> recipes = data['hits']
  //         .map<Recipe>((data) => Recipe.fromJson(data['recipe']))
  //         .toList();
  //     return recipes;
  //   } else {
  //     throw Exception('Failed to load recipes');
  //   }
  // }

  // Construct the URL for the Edamam Recipe Search API
  static Future<List<dynamic>> searchRecipes(
      String searchKey, String queryParams,
      {int start = 0, int end = 10}) async {
    // 3scale credentials
    const String appId = '944184b7';
    const String appKey = '32a51da0f5bf093de7b4cd19e2f55112';
    const String baseUrl = 'https://api.edamam.com';

    final String url =
        '$baseUrl/api/recipes/v2?q=$searchKey&app_id=$appId&app_key=$appKey&type=public$queryParams';

    print(url);
    try {
      // Make the HTTP request
      final response = await http.get(Uri.parse(url));

      print(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // get lesser of the two numbers
        final int maxRecipes = math.min(end, data['hits'].length as int);

        final List<dynamic> recipes = data['hits']
            .map((hit) => hit['recipe'])
            .toList()
            .sublist(start, maxRecipes); // Manage slicing locally
        return recipes;
      } else {
        print('Error: ${response.statusCode}');
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load recipes');
    }
  }

  // Construct the URL for the Edamam Recipe Search API
  static Future<Map<String, dynamic>> searchRecipeById(String recipeId) async {
    // 3scale credentials
    const String appId = '944184b7';
    const String appKey = '32a51da0f5bf093de7b4cd19e2f55112';
    const String baseUrl = 'https://api.edamam.com';

    final String url =
        '$baseUrl/api/recipes/v2/$recipeId?type=public&app_id=$appId&app_key=$appKey';

    try {
      // Make the HTTP request
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the JSON data
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          return data['recipe'];
        } else {
          throw Exception('Recipe not found.');
        }
      } else {
        throw Exception('Failed to load recipe: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load recipes');
    }
  }
}
