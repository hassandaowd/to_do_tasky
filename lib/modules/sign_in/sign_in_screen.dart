import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:to_do_app/cubit/cubit.dart';
import 'package:to_do_app/modules/home/home_screen.dart';
import 'package:to_do_app/modules/sign_in/sign_in_cubit.dart';
import 'package:to_do_app/modules/sign_up/sign_up_screen.dart';
import 'package:to_do_app/shared/component.dart';
import '../../shared/constants.dart';
import '../../shared/network/cache_helper.dart';
import 'states.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  var password = TextEditingController();
  var phone = TextEditingController();
  String phoneNum = '';
  String countryCode = '';
  AutovalidateMode? onValied = AutovalidateMode.disabled;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginStates>(
        listener: (BuildContext context, state) {
          if (state is LoginErrorState) {
            toast(
              msg: state.error,
              state: ToastState.error,
            );
          }
          if (state is LoginSuccessState) {
            if (state.message == 'Login Successfully') {
              toast(
                msg: 'Login Successfully ',
                state: ToastState.success,
              );
              CacheHelper.saveData(key: 'accessToken', value: state.loginModel.accessToken)
                  .then((value) {
                    accessToken = state.loginModel.accessToken!;

              });
              // CacheHelper.saveData(key: 'dataLogin', value: LoginCubit.get(context).loginModel).then((value) {
              //   dataLogin = LoginCubit.get(context).loginModel;
              // });
              CacheHelper.saveData(key: 'userPhone', value: phoneNum)
                  .then((value) {
                userPhone = phoneNum;

              });
              CacheHelper.saveData(key: 'refreshToken', value: state.loginModel.refreshToken)
                  .then((value) {
                refreshToken = state.loginModel.refreshToken!;
                   AppCubit.get(context).getUserData();
                   AppCubit.get(context).getList();
                //Future.delayed(const Duration(seconds: 2)).then((value) {
                  navigateToFinish(context,  HomeScreen());
                  //Future.delayed(const Duration(seconds: 2)).then((value) {});
                //});
              });
            }
            else {
              toast(
                msg: state.message,
                state: ToastState.error,
              );
            }
          }
        },
        builder: (BuildContext context, state) {
          return Scaffold(
            body: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Center(
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black, Colors.transparent],
                          ).createShader(
                              Rect.fromLTRB(200, 200, rect.width, rect.height));
                        },
                        blendMode: BlendMode.dstIn,
                        child: Image.asset(
                          'assets/images/art2.png',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          color: Colors.white, colorBlendMode: BlendMode.darken,
                          //height: 150,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: DefaultColor.title,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 60,
                          child: IntlPhoneField(
                            controller: phone,
                            disableLengthCheck: true,
                            dropdownTextStyle: TextStyle(
                              color: DefaultColor.emptyField,
                            ),
                            onTap: () {},
                            //autovalidateMode: AutovalidateMode.onUserInteraction ,

                            validator: (phoneNumber) {
                              try {
                                if (phoneNumber!.isValidNumber()) {

                                }
                              }catch(error){
                                if(error is NumberTooShortException) {
                                  return 'Number is too short';
                                }
                                if(error is NumberTooLongException) {
                                  if(phoneNumber!.number.length == 11 && phoneNumber.number.startsWith('0')){
                                    if(phoneNumber.countryISOCode == 'EG'){
                                      return null;
                                    }
                                  }else {
                                    return 'Number is too long ';
                                  }
                                }
                              }
                              return null;
                            },
                            onChanged: (phone) {

                              countryCode = phone.countryCode;
                              if (phone.number.startsWith('0')) {
                                phoneNum = countryCode +
                                    phone.number.replaceFirst('0', '');
                                print(phoneNum);
                              } else {
                                phoneNum = countryCode + phone.number;
                                print(phoneNum);
                              }
                            },
                            initialCountryCode: "EG",
                            dropdownIconPosition: IconPosition.trailing,
                            flagsButtonPadding: EdgeInsets.only(left: 10),
                            decoration: InputDecoration(
                              prefixIconColor: DefaultColor.emptyField,
                              labelText: "Mobile Number",
                              labelStyle:
                                  TextStyle(color: DefaultColor.emptyField),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: DefaultColor.emptyField),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        defaultFormField(
                            controller: password,
                            validate: (value) {
                              if (value.isEmpty) {
                                return 'This field can not be empty';
                              }
                              return null;
                            },
                            label: 'Password...',
                            type: TextInputType.visiblePassword,
                            suffix: LoginCubit.get(context).suffix,
                            onSubmit: (value) {
                              // if(formKey.currentState!.validate()){
                              //   LoginCubit.get(context).userLogin(
                              //     email: emailController.text,
                              //     password: passwordController.text,
                              //   );
                              // }
                            },
                            isPassword: LoginCubit.get(context).isPassword,
                            suffixPressed: () {
                              LoginCubit.get(context)
                                  .changePasswordVisibility();
                            }),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 50,
                          child: ConditionalBuilder(
                            condition: state is! LoginLoadingState ||
                                state is LoginErrorState,
                            builder: (BuildContext context) => ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate() && phoneNum.isNotEmpty) {
                                  LoginCubit.get(context).userLogin(
                                    phoneNum: phoneNum,
                                    password: password.text,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DefaultColor.purple,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontFamily: 'DMSans',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            fallback: (BuildContext context) => Center(
                              child: CircularProgressIndicator(
                                color: DefaultColor.purple,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Didn’t have any account?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 14,
                                  color: DefaultColor.subTitle,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              TextButton(
                                onPressed: () {
                                  navigateToFinish(context, SignUpScreen());
                                },
                                child: Text(
                                  'Sign Up here',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationColor: DefaultColor.purple,
                                    fontFamily: 'DMSans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: DefaultColor.purple,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
