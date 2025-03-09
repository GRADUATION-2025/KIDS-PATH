
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidspath/test/LOGIC/SIGNUP/state.dart';



class SignupCubit extends Cubit<SignUpStates>{
  FirebaseAuth firebaseAuth;
  SignupCubit(this.firebaseAuth):super(SignUpInitialState());


  Future signup(String email,String password)async{
    emit(SignUpLoadingState());
    try{
      await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      emit(SignupSuccessState());
    }
    catch(e){
      emit(SignUpErrorState(e.toString()));
    }
  }
}
