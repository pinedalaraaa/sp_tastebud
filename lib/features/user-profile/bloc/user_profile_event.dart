part of 'user_profile_bloc.dart';

abstract class UserProfileEvent {}

class LoadUserProfile extends UserProfileEvent {}

class UpdateUserProfile extends UserProfileEvent {
  final List<String> selectedDietPref;
  final List<String> selectedAllergies;
  final List<String> selectedMacro;
  final List<String> selectedMicro;

  UpdateUserProfile(this.selectedDietPref, this.selectedAllergies,
      this.selectedMacro, this.selectedMicro);
}
