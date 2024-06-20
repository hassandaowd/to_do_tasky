import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:to_do_app/modules/sign_in/sign_in_screen.dart';
import 'package:to_do_app/modules/sign_up/sign_up_cubit.dart';
import 'package:to_do_app/modules/sign_up/states.dart';
import 'package:to_do_app/shared/component.dart';
import '../../shared/constants.dart';
import '../../shared/network/cache_helper.dart';
import '../home/home_screen.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  var name = TextEditingController();
  var phone = TextEditingController();
  var exp = TextEditingController();
  var address = TextEditingController();
  var password = TextEditingController();

  String phoneNum = '';
  String countryCode = '';
  final List<String> experience = [
    'fresh',
    'junior',
    'midLevel',
    'senior',
  ];

  String selectedValue ='';

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterStates>(
        listener: (BuildContext context, state) {
          if (state is RegisterErrorState) {
            toast(
              msg: state.error,
              state: ToastState.error,
            );
          }
          if (state is RegisterSuccessState) {
            if (state.message == 'Register Successfully') {
              toast(
                msg: 'Login Successfully ',
                state: ToastState.success,
              );
              CacheHelper.saveData(key: 'accessToken', value: state.registerModel.accessToken)
                  .then((value) {
                accessToken = state.registerModel.accessToken!;

              });

              // CacheHelper.saveData(key: 'userPhone', value: phoneNum)
              //     .then((value) {
              //   userPhone = phoneNum;
              // });
              CacheHelper.saveData(key: 'refreshToken', value: state.registerModel.refreshToken)
                  .then((value) {
                refreshToken = state.registerModel.refreshToken!;

                Future.delayed(const Duration(seconds: 2)).then((value) {
                  navigateToFinish(context,  HomeScreen());
                  //Future.delayed(const Duration(seconds: 2)).then((value) {});
                });
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
        builder: (BuildContext context, Object? state) {
          return Scaffold(
            //resizeToAvoidBottomInset: false,
            body: Form(
              key: _formKey,
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: ShaderMask(
                            shaderCallback: (rect) {
                              return const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black, Colors.transparent],
                              ).createShader(Rect.fromLTRB(
                                  50, 50, rect.width, rect.height));
                            },
                            blendMode: BlendMode.dstIn,
                            child: Image.asset(
                              'assets/images/art2.png',
                              width: double.infinity,
                              fit: BoxFit.cover,
                              color: Colors.white,
                              colorBlendMode: BlendMode.darken,
                              //height: 150,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                      )
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
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
                                defaultFormField(
                                  onSubmit: (value){},
                                  controller: name,
                                  validate: (value) {
                                    if (value.isEmpty) {
                                      return 'This field can not be empty';
                                    }
                                  },
                                  label: 'Name',
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
                                  onSubmit: (value){},
                                  controller: exp,
                                  validate: (value) {
                                    if (value.isEmpty) {
                                      return 'This field can not be empty';
                                    }
                                  },
                                  label: 'Years of experience...',
                                  type: TextInputType.number,
                                ),
                                const SizedBox(height: 15),
                                DropdownButtonFormField2<String>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    // Add more decoration..
                                  ),
                                  hint: const Text(
                                    'Choose experience Level',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  items: experience
                                      .map((item) => DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please Choose experience Level.';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    print(value);
                                    selectedValue = value.toString();
                                  },
                                  onSaved: (value) {
                                    selectedValue = value.toString();
                                  },
                                  buttonStyleData: const ButtonStyleData(
                                    padding: EdgeInsets.only(right: 8),
                                  ),
                                  iconStyleData: const IconStyleData(
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.black45,
                                    ),
                                    iconSize: 24,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  menuItemStyleData: const MenuItemStyleData(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                defaultFormField(
                                    onSubmit: (value){},
                                    controller: address,
                                    validate: (value) {
                                      if (value.isEmpty) {
                                        return 'This field can not be empty';
                                      }
                                    },
                                    label: 'Address'),
                                const SizedBox(height: 15),
                                defaultFormField(

                                    controller: password,
                                    validate: (value) {
                                      if (value.isEmpty) {
                                        return 'This field can not be empty';
                                      }
                                    },
                                    label: 'Password...',
                                    type: TextInputType.visiblePassword,
                                    suffix: RegisterCubit.get(context).suffix,
                                    onSubmit: (value) {
                                      // if(formKey.currentState!.validate()){
                                      //   LoginCubit.get(context).userLogin(
                                      //     email: emailController.text,
                                      //     password: passwordController.text,
                                      //   );
                                      // }
                                    },
                                    isPassword:
                                        RegisterCubit.get(context).isPassword,
                                    suffixPressed: () {
                                      RegisterCubit.get(context)
                                          .changePasswordVisibility();
                                    }),
                                const SizedBox(height: 15),
                                SizedBox(
                                  height: 50,
                                  child: ConditionalBuilder(
                                    condition: state is! RegisterLoadingState ||
                                        state is RegisterErrorState,
                                    builder: (BuildContext context) =>
                                        ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate() && phoneNum.isNotEmpty) {
                                          RegisterCubit.get(context)
                                              .userRegister(
                                            phoneNum: phoneNum,
                                            password: password.text,
                                            name: name.text,
                                            years: exp.text,
                                            address: address.text,
                                            experience: selectedValue,
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: DefaultColor.purple,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Sign Up",
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
                                        'Already have any account?',
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
                                          navigateToFinish(
                                              context, SignInScreen());
                                        },
                                        child: Text(
                                          'Sign in',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                DefaultColor.purple,
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
