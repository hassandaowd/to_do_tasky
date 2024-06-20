import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:to_do_app/shared/component.dart';
import 'package:to_do_app/modules/sign_in/sign_in_screen.dart';

class StartScreen extends StatelessWidget {
  StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Column(
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

                  ).createShader(Rect.fromLTRB(200, 200, rect.width, rect.height));
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
          const Column(
            children: [
              Text(
                'Task Management &\nTo-Do List',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'This productive tool is designed to help you better manage your task project-wise conveniently!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  navigateToFinish(context, SignInScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(95, 51, 225, 1),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Let's Start ",
                        style: TextStyle(fontSize: 16,color: Colors.white,fontFamily: 'DMSans'),

                      ),
                      const SizedBox(width: 5,),
                      SvgPicture.asset('assets/images/arrowWhiteLeft.svg'),

                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}