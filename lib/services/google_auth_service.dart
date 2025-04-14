import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

signInWithGoogle() async{
                                // begin interactive sign in process
                                final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

                                // obtain auth details from request
                                final GoogleSignInAuthentication gAuth = await gUser!.authentication;

                                // create a new credential from auth
                                final credential = firebase_auth.GoogleAuthProvider.credential(
                                  accessToken: gAuth.accessToken,
                                  idToken: gAuth.idToken,
                                );  

                                // sign in with credential
                               return await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);

                                // check if sign in was successful  
                                
                              }