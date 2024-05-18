import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sp_tastebud/core/utils/extract_recipe_id.dart';
import 'package:sp_tastebud/core/config/assets_path.dart';
import 'package:sp_tastebud/shared/custom_dialog.dart';
import '../bloc/recipe_bloc.dart';

class RecipeCardCollection extends StatefulWidget {
  final String recipeName;
  final String imageUrl;
  final String sourceWebsite;
  final String recipeUri;

  const RecipeCardCollection({
    super.key,
    required this.recipeName,
    required this.imageUrl,
    required this.sourceWebsite,
    required this.recipeUri,
  });

  @override
  State<RecipeCardCollection> createState() => _RecipeCardCollectionState();
}

class _RecipeCardCollectionState extends State<RecipeCardCollection> {
  final RecipeCardBloc _recipeCardBloc = GetIt.instance<RecipeCardBloc>();

  void _handleActionConfirmation(
      BuildContext context, String actionType, VoidCallback onConfirm) {
    final action = actionType == 'favorite' ? 'saved' : 'rejected';
    final confirmationMessage =
        'Are you sure you want to remove this recipe from your $action recipe collection?';

    openDialog(
      context,
      'Confirmation',
      confirmationMessage,
      onConfirm: onConfirm,
      showCancelButton: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeCardBloc, RecipeCardState>(
        bloc: _recipeCardBloc,
        builder: (context, state) {
          bool isInFavorites = false;
          bool isInRejected = false;

          if (state is RecipeCardUpdated) {
            isInFavorites = state.favorites
                .contains(extractRecipeIdUsingRegExp(widget.recipeUri));
            isInRejected = state.rejected
                .contains(extractRecipeIdUsingRegExp(widget.recipeUri));
          }

          return Container(
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),

            // Actual Recipe Contents
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Load the image and handle errors gracefully
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Print error to console
                          print('Failed to load image: $error');
                          return Image.asset(
                            Assets
                                .imagePlaceholder, // Use a local fallback image
                            width: 100,
                            height: 100,
                          );
                        },
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              widget.recipeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Source: ${widget.sourceWebsite}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),

                // Icons for adding/removing favorites and rejected recipes
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Row(
                    children: [
                      // Show favorite icon if not in rejected collection
                      if (!isInRejected)
                        GestureDetector(
                          onTap: () {
                            _handleActionConfirmation(context, 'favorite', () {
                              _recipeCardBloc.add(ToggleFavorite(
                                recipeName: widget.recipeName,
                                imageUrl: widget.imageUrl,
                                sourceWebsite: widget.sourceWebsite,
                                recipeUri: widget.recipeUri,
                              ));
                            });
                          },
                          child: Icon(
                            isInFavorites
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                      const SizedBox(width: 8), // Spacing between icons
                      // Show reject icon if not in favorites collection
                      if (!isInFavorites)
                        GestureDetector(
                          onTap: () {
                            _handleActionConfirmation(context, 'reject', () {
                              _recipeCardBloc.add(ToggleReject(
                                recipeName: widget.recipeName,
                                imageUrl: widget.imageUrl,
                                sourceWebsite: widget.sourceWebsite,
                                recipeUri: widget.recipeUri,
                              ));
                            });
                          },
                          child: Icon(
                            isInRejected
                                ? Icons.remove_circle
                                : Icons.remove_circle_outline,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}