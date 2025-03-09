
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kidspath/test/home.dart';

import '../LOGIC/SIGNUP/cubit.dart';
import '../LOGIC/SIGNUP/state.dart';

import 'LOGIN_SCREEN.dart';



class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController  = TextEditingController();
  TextEditingController passwordController =TextEditingController();
  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context)=>SignupCubit(FirebaseAuth.instance,),

        child: BlocConsumer<SignupCubit,SignUpStates>(
        listener: (context,state){
      if(state is SignupSuccessState){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User ID Is Created Successfully ")));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));
      }else if (state is SignUpErrorState){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage)));
      }
    },

    builder: (context,state){
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),

      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image(image:AssetImage("assets/IMAGES/IG_Logo.png",),width: 244,height: 68),
            SizedBox(height: 15,),


            Form(key: formkey,
              child:
              //Email Text Field
              Column(
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration:
                    InputDecoration(
                      fillColor: Color(0xFFD9D9D9),
                      filled: true,

                      label: Text("EMAIL"),
                      labelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
                          borderSide:BorderSide(color:Colors.transparent) ),

                    ),

                  ),
                  SizedBox(height: 15,),
                  //PASSWORD TEXT FIELD
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(

                      fillColor: Color(0xFFD9D9D9),
                      filled: true,


                      label: Text("PASSWORD"),
                      labelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
                          borderSide:BorderSide(color:Colors.transparent) ),

                    ),
                  )
                ],
              ),
            ),



            SizedBox(height: 15,),
            InkWell(
              onTap: () {
                if (formkey.currentState?.validate() ?? false) {
                  final email = emailController.text;
                  final password = passwordController.text;
                  context.read<SignupCubit>().signup(email, password);
                }
              },
              child: Container(
                width: 400,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: state is SignUpLoadingState
                      ? CircularProgressIndicator(
                    color: Colors.white,
                  ) // Show loading spinner
                      : Text(
                    'Register',
                    style: TextStyle(
                        fontSize: 15, color: Colors.white),
                  ), // Show normal text when not loading
                ),
              ),
            ),





            SizedBox(height: 10,),
            Center(child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Have An Account ?"),
                SizedBox(width: 5,),
                TextButton(onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(),));

                },
                    child:
                    Text('Login',style: TextStyle(fontWeight: FontWeight.bold),))],

            ),)

          ],
        ),
      ));
        }
        )
    );

    }
  }

