import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:sp_tastebud/shared/recipe_card/recipe_card.dart';
import 'package:sp_tastebud/core/utils/extract_recipe_id.dart';
import '../../recipe/search-recipe/bloc/search_recipe_bloc.dart';
import '../bloc/recipe_collection_bloc.dart';

class ViewCollectionPage extends StatefulWidget {
  final String collectionType; // 'Saved' or 'Rejected'

  const ViewCollectionPage({super.key, required this.collectionType});

  @override
  State<ViewCollectionPage> createState() => _ViewCollectionPageState();
}

class _ViewCollectionPageState extends State<ViewCollectionPage> {
  late RecipeCollectionBloc _recipeCollectionBloc;
  late SearchRecipeBloc _searchRecipeBloc;

  @override
  void initState() {
    super.initState();
    print('init state!!');
    _recipeCollectionBloc = GetIt.instance<RecipeCollectionBloc>();
    _searchRecipeBloc = GetIt.instance<SearchRecipeBloc>();
    _fetchRecipes();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _fetchRecipes();
  // }

  void _fetchRecipes() {
    print(widget.collectionType);
    // Dispatch FetchSavedRecipes or FetchRejectedRecipes event based on collectionType
    if (!_recipeCollectionBloc.isClosed) {
      if (widget.collectionType.toLowerCase() == 'saved') {
        print('Fetching saved recipes...');
        _recipeCollectionBloc.add(FetchSavedRecipes());
      } else if (widget.collectionType.toLowerCase() == 'rejected') {
        print('Fetching rejected recipes...');
        _recipeCollectionBloc.add(FetchRejectedRecipes());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('inside view collection page');
    return BlocListener<SearchRecipeBloc, SearchRecipeState>(
      listener: (context, state) {
        if (state is FavoritesRemoved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Removed from recipe collection!")),
          );
          _fetchRecipes(); // Refetch recipes when a favorite is removed
        }
      },
      child: BlocBuilder<RecipeCollectionBloc, RecipeCollectionState>(
        builder: (context, state) {
          if (state is RecipeCollectionLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is SavedRecipesLoaded ||
              state is RejectedRecipesLoaded) {
            print('else conditionnn');
            final recipes = state is SavedRecipesLoaded
                ? state.savedRecipes
                : (state as RejectedRecipesLoaded).rejectedRecipes;
            return _buildCollectionPage(widget.collectionType, recipes);
          } else if (state is RecipeCollectionError) {
            return Center(child: Text(state.error));
          } else if (state is RecipeCollectionInitial) {
            return Center(child: Text('Initial'));
          } else {
            print('last statement');
            return Container();
          }
          // } else if (state is RecipeCollectionError) {
          //   return Center(child: Text(state.message));
          // } else {
          //   return Center(child: CircularProgressIndicator());
          // }
        },
      ),
    );
  }

  Widget _buildCollectionPage(String collectionType, List<dynamic> recipes) {
    print('inside build collection page');
    print(recipes);

    return Column(
      children: [
        Text('$collectionType Recipes'),
        Container(
            height: (MediaQuery.of(context).size.height / 3) * 2,
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return GestureDetector(
                  onTap: () {
                    print("Recipe tapped: ${recipe['recipeName']}");
                    // Get the recipe data as a Map or directly pass the Recipe object if serialized
                    final recipeId =
                        extractRecipeIdUsingRegExp(recipe['recipeUri']);
                    context.goNamed('viewRecipeFromCollection',
                        pathParameters: {
                          'collectionType': collectionType,
                          'recipeId': recipeId
                        });
                  },
                  child: RecipeCard(
                    recipeName: recipe['recipeName']!,
                    imageUrl: recipe['image']!,
                    sourceWebsite: recipe['source']!,
                    recipeUri: recipe['recipeUri'],
                  ),
                );
              },
            ))
      ],
    );
  }
}
