import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewRecipeRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  ViewRecipeRepository(this._firestore, this._firebaseAuth);

  Future<void> addToRejected(
      String recipeName, String image, String source, String recipeId) async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user logged in!');
    }

    // print("in search repository");
    // print(recipeName);
    // print(image);
    // print(source);
    // print(recipeId);

    DocumentReference recipeRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('rejectedRecipes')
        .doc(recipeId);

    DocumentSnapshot snapshot = await recipeRef.get();
    if (snapshot.exists) {
      throw Exception('Recipe already in rejected collection.');
    }

    await recipeRef.set({
      'recipeName': recipeName,
      'image': image,
      'source': source,
      'recipeId': recipeId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
