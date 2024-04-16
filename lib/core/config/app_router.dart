import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_provider/go_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// UI widgets
import 'package:sp_tastebud/features/auth/ui/login_ui.dart';
import 'package:sp_tastebud/features/auth/ui/main_menu_ui.dart';
import 'package:sp_tastebud/features/auth/ui/signup_ui.dart';
import 'package:sp_tastebud/features/ingredients/ui/ingredient_management_ui.dart';
import 'package:sp_tastebud/features/navigation/ui/navigation_bar_ui.dart';
import 'package:sp_tastebud/features/recipe-collection/ui/recipe_collection_ui.dart';
import 'package:sp_tastebud/features/recipe/search-recipe/ui/search_recipe_ui.dart';
import 'package:sp_tastebud/features/user-profile/ui/user_profile_ui.dart';

//BLoCs
import 'package:sp_tastebud/features/auth/bloc/signup_bloc.dart';
import 'package:sp_tastebud/features/auth/bloc/login_bloc.dart';
import 'package:sp_tastebud/features/user-profile/bloc/user_profile_bloc.dart';
import 'package:sp_tastebud/features/navigation/bloc/app_navigation_bloc.dart';

// services
import 'package:sp_tastebud/features/auth/data/auth_service.dart';
import 'package:sp_tastebud/features/auth/data/user_repository.dart';

class AppRoutes {
  static final _authService = AuthService(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );

  static final UserRepository _userRepository = UserRepository(_authService);

  // for the parent navigation stack
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  // for nested navigation with ShellRoute
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

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
            name: "login",
            path: "/login",
            builder: (context, state) {
              return BlocProvider<LoginBloc>(
                create: (context) => LoginBloc(_userRepository),
                child: LoginPage(),
              );
            },
          ),
          GoRoute(
            name: "signup",
            path: "/signup",
            builder: (context, state) {
              return BlocProvider<SignupBloc>(
                create: (context) => SignupBloc(_userRepository),
                child: SignupPage(),
              );
            },
          ),
          ShellProviderRoute(
            navigatorKey: _shellNavigatorKey,
            providers: [
              BlocProvider(
                  create: (context) =>
                      UserProfileBloc(FirebaseFirestore.instance))
            ],
            builder: (context, state, child) {
              return BlocProvider<AppNavigationBloc>(
                create: (context) => AppNavigationBloc(),
                child: AppBottomNavBar(appName1: 'Taste', appName2: 'Bud'),
              );
            },
            routes: [
              GoRoute(
                name: "search",
                path: "/search",
                parentNavigatorKey: _shellNavigatorKey,
                builder: (context, state) => const SearchRecipe(),
                // child route
                // routes:[
                //   GoRoute(
                //     name: "viewRecipe",
                //     path: "view-recipe",
                //     parentNavigatorKey: _rootNavigatorKey,
                //     builder: (context, state) => const ViewRecipe(),
                //     path: ":id",
                //     builder: (context, state) {
                //       final id = state.params['id'] // Get "id" param from URL
                //       return FruitsPage(id: id);
                //     },
                //    example path: /fruits?search=antonio
                //    builder: (context, state) {
                //      final search = state.queryParams['search'];
                //      return FruitsPage(search: search);
                //    },
                //   )
                // ]
              ),
              GoRoute(
                name: "ingredientManagement",
                path: "/ingredients",
                parentNavigatorKey: _shellNavigatorKey,
                builder: (context, state) => const IngredientManagement(),
              ),
              GoRoute(
                name: "recipeCollection",
                path: "/recipe-collection",
                parentNavigatorKey: _shellNavigatorKey,
                builder: (context, state) => const RecipeCollection(),
              ),
              GoRoute(
                name: "userProfile",
                path: "/profile",
                parentNavigatorKey: _shellNavigatorKey,
                builder: (context, state) => UserProfile(),
                // child: BlocBuilder<UserProfileBloc, UserProfileState>(
                //   builder: (context, state) {
                //     if (state is UserProfileLoaded) {
                //       return UserProfile();
                //     } else {
                //       return CircularProgressIndicator();
                //     }
                //   },
                // ),
              ),
            ],
          ),
        ],
      );
}
