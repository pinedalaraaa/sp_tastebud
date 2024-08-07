import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model/ingredient_substitute_response_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IngredientSubstitutionAPI {
  final apiKey = dotenv.env['SPOONACULAR_APIKEY'];
  static const String baseUrl =
      'https://api.spoonacular.com/food/ingredients/substitutes';

  static Future<IngredientSubstituteResponseSpoonacular?>
      getIngredientSubstitute({String query = ''}) async {
    final url = '$baseUrl?ingredientName=$query&apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // final jsonResponse = json.decode(response.body);
        final jsonResponse = jsonDecode(utf8.decode(response.body.codeUnits));

        // Check if substitutes are found
        if (jsonResponse.containsKey('substitutes')) {
          // Substitutes found, parse the response
          return IngredientSubstituteResponseSpoonacular.fromJson(jsonResponse);
        } else {
          // No substitutes found, construct response manually
          return IngredientSubstituteResponseSpoonacular(
            ingredient: query,
            substitutes: [],
            message: jsonResponse['message'],
          );
        }
      } else {
        print('Failed to load ingredient substitutes');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  void getIngredientSubstitutesRapidAPI(String ingredientName) async {
    // pre-defined headers
    final Map<String, String> headers = {
      "X-RapidAPI-Key": "6952326c6amsh579671cd91ffa58p1d0b93jsn135c5cfdbb40",
      "X-RapidAPI-Host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com"
    };

    const String baseUrl =
        "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/food/ingredients/substitutes";

    final encodedIngredientName = Uri.encodeComponent(ingredientName);
    var url = Uri.parse('$baseUrl?ingredientName=$encodedIngredientName');

    try {
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var ingredientSubstitutes =
            IngredientSubstituteResponseRapidAPI.fromJson(jsonResponse);
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }
}
