class SignUpStates{}

class SignUpInitialState extends SignUpStates{}
class SignUpLoadingState extends SignUpStates{}
class SignupSuccessState extends SignUpStates{}
class SignUpErrorState extends SignUpStates{

  final String errorMessage;
  SignUpErrorState(this.errorMessage);
}
