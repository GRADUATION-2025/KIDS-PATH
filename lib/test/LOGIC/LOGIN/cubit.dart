import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidspath/test/LOGIC/LOGIN/state.dart';



class LoginCubit extends Cubit<LoginStates>{
 FirebaseAuth firebaseAuth;
 LoginCubit(this.firebaseAuth):super(LogininitialState());


 Future Login(String email,String password)async{
   emit(LoginLoadingState());
   try{
     await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
emit(LoginSucessState());
   }
       catch(e){
emit(LoginErrorState(e.toString()));
       }
 }
}