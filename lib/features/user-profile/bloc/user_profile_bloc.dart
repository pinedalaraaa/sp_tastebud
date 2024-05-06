import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sp_tastebud/features/user-profile/data/user_profile_repository.dart';
import 'package:sp_tastebud/shared/checkbox_card/options.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserProfileRepository _userProfileRepository;

  UserProfileBloc(this._userProfileRepository) : super(UserProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  void _onLoadUserProfile(
      LoadUserProfile event, Emitter<UserProfileState> emit) async {
    var userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      emit(UserProfileError("User not logged in"));
      return;
    }

    try {
      var data = await _userProfileRepository.fetchUserProfile(userId);
      if (data != null) {
        var fetchDietPref =
            List<bool>.from(data['dietaryPreferences'] as List<dynamic>);
        var fetchAllergies =
            List<bool>.from(data['allergies'] as List<dynamic>);
        var fetchMacro =
            List<bool>.from(data['macronutrients'] as List<dynamic>);
        var fetchMicro =
            List<bool>.from(data['micronutrients'] as List<dynamic>);

        print("fetchDietPref: $fetchDietPref");
        print("fetchAllergies: $fetchAllergies");
        print("fetchMacro: $fetchMacro");
        print("fetchMicro: $fetchMicro");

        emit(UserProfileLoaded(
            fetchDietPref, fetchAllergies, fetchMacro, fetchMicro));
      } else {
        emit(UserProfileLoaded(
          List<bool>.filled(Options.dietaryPreferences.length, false),
          List<bool>.filled(Options.allergies.length, false),
          List<bool>.filled(Options.macronutrients.length, false),
          List<bool>.filled(Options.micronutrients.length, false),
        ));
      }
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  void _onUpdateUserProfile(
      UpdateUserProfile event, Emitter<UserProfileState> emit) async {
    var userId = FirebaseAuth.instance.currentUser?.uid;
    print("UserID 1:");
    print(userId);

    if (userId == null) {
      emit(UserProfileError("User not logged in"));
      return;
    }
    try {
      await _userProfileRepository.saveUserProfile(
          userId,
          event.selectedDietPref,
          event.selectedAllergies,
          event.selectedMacro,
          event.selectedMicro);
      emit(UserProfileUpdated());
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }
}
