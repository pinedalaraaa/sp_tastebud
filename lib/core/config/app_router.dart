import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sp_tastebud/core/config/service_locator.dart';
import 'package:sp_tastebud/features/auth/ui/forgot_password_ui.dart';

// UI widgets
import 'package:sp_tastebud/features/auth/ui/login_ui.dart';
import 'package:sp_tastebud/features/auth/ui/main_menu_ui.dart';
import 'package:sp_tastebud/features/auth/ui/signup_ui.dart';
import 'package:sp_tastebud/features/ingredients/ui/ingredient_management_ui.dart';
import 'package:sp_tastebud/features/navigation/ui/navigation_bar_ui.dart';
import 'package:sp_tastebud/features/recipe-collection/bloc/recipe_collection_bloc.dart';
import 'package:sp_tastebud/features/recipe-collection/ui/recipe_collection_ui.dart';
import 'package:sp_tastebud/features/recipe-collection/ui/view_collection_page.dart';
import 'package:sp_tastebud/features/recipe/search-recipe/ui/search_recipe_ui.dart';
import 'package:sp_tastebud/features/recipe/view-recipe/bloc/view_recipe_bloc.dart';
import 'package:sp_tastebud/features/user-profile/ui/user_profile_ui.dart';
import 'package:sp_tastebud/features/recipe/view-recipe/ui/view_recipe_ui.dart';

//BLoCs
import 'package:sp_tastebud/shared/recipe_card/bloc/recipe_bloc.dart';
import 'package:sp_tastebud/features/navigation/bloc/app_navigation_bloc.dart';

class AppRoutes {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorSearchKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellSearch');
  static final _shellNavigatorIngredientsKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellIngredients');
  static final _shellNavigatorCollectionKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellCollection');
  static final _shellNavigatorProfileKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  static GoRouter get router => GoRouter(
        initialLocation: "/",
        navigatorKey: _rootNavigatorKey,
        routes: [
          GoRoute(
            name: "mainMenu",
            path: "/",
            builder: (context, state) =>
                const MainMenu(appName1: "Taste", appName2: "Bud"),
          ),
          GoRoute(
            name: "signup",
            path: "/signup",
            builder: (context, state) => SignupPage(),
          ),
          GoRoute(
            name: "login",
            path: "/login",
            builder: (context, state) => LoginPage(),
          ),
          GoRoute(
            name: "forgotPassword",
            path: "/forgot-password",
            builder: (context, state) => ForgotPassword(),
          ),
          StatefulShellRoute.indexedStack(
              builder: (context, state, navigationShell) {
                return BlocProvider<AppNavigationBloc>(
                    create: (context) => AppNavigationBloc(),
                    child: AppBottomNavBar(
                        appName1: 'Taste',
                        appName2: 'Bud',
                        navigationShell: navigationShell));
              },
              branches: [
                StatefulShellBranch(
                    navigatorKey: _shellNavigatorSearchKey,
                    routes: [
                      GoRoute(
                        name: "search",
                        path: "/search",
                        builder: (context, state) =>
                            BlocProvider<RecipeCardBloc>(
                          create: (context) => getIt<RecipeCardBloc>(),
                          child: SearchRecipe(),
                        ),
                        routes: [
                          GoRoute(
                            name: "viewRecipe",
                            path: "view/:recipeId",
                            builder: (context, state) =>
                                BlocProvider<ViewRecipeBloc>(
                              create: (context) => getIt<ViewRecipeBloc>(),
                              child: ViewRecipe(
                                // Retrieve the recipe ID from path parameters
                                // Assert that recipeId is non-null
                                recipeId: state.pathParameters['recipeId']!,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                // Ingredients branch
                StatefulShellBranch(
                  navigatorKey: _shellNavigatorIngredientsKey,
                  routes: [
                    GoRoute(
                      path: '/ingredients',
                      builder: (context, state) => IngredientManagement(),
                    ),
                  ],
                ),
                // Recipe Collection branch
                StatefulShellBranch(
                  navigatorKey: _shellNavigatorCollectionKey,
                  routes: [
                    GoRoute(
                      path: '/recipe-collection',
                      builder: (context, state) => RecipeCollection(),
                      routes: [
                        GoRoute(
                          name: "viewCollection",
                          path: 'collection/:collectionType',
                          builder: (context, state) {
                            // Extract the 'collectionType' parameter from the route
                            final collectionType =
                                state.pathParameters['collectionType']!;
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider<RecipeCollectionBloc>.value(
                                  value: getIt<RecipeCollectionBloc>(),
                                ),
                                BlocProvider<RecipeCardBloc>(
                                  create: (context) => getIt<RecipeCardBloc>(),
                                  child: SearchRecipe(),
                                ),
                              ],
                              child: ViewCollectionPage(
                                  collectionType: collectionType),
                            );
                          },
                          routes: [
                            GoRoute(
                              name: "viewRecipeFromCollection",
                              path: "view/:recipeId",
                              builder: (context, state) =>
                                  BlocProvider<ViewRecipeBloc>(
                                create: (context) => getIt<ViewRecipeBloc>(),
                                child: ViewRecipe(
                                  // Retrieve the recipe ID from path parameters
                                  // Assert that recipeId is non-null
                                  recipeId: state.pathParameters['recipeId']!,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                // User Profile branch
                StatefulShellBranch(
                  navigatorKey: _shellNavigatorProfileKey,
                  routes: [
                    GoRoute(
                      path: '/profile',
                      builder: (context, state) => UserProfile(),
                    ),
                  ],
                ),
              ])
        ],
      );
}
