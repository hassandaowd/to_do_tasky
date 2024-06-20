import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:to_do_app/shared/component.dart';

import '../../cubit/cubit.dart';
import '../../cubit/states.dart';
import '../../shared/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, States>(
      listener: (BuildContext context, States state) {},
      builder: (BuildContext context, States state) {
        var cubit = AppCubit.get(context);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,

            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: SvgPicture.asset('assets/images/blackArrow.svg'),
            ),
            title: Text(
              'Profile',
              style: TextStyle(
                color: DefaultColor.title,
                fontWeight: FontWeight.w700,
                fontFamily: "DMSans",
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  profileItems(key: 'NAME',value: cubit.userModel!.displayName ),
                  profileItems(key: 'PHONE',value: cubit.userModel!.username,coby: true),
                  profileItems(key: 'LEVEL',value: cubit.userModel!.level),
                  profileItems(key: 'YEARS OF EXPERIENCE',value: '${cubit.userModel!.experienceYears.toString()} Years'),
                  profileItems(key: 'LOCATION',value: cubit.userModel!.address),

                ],
              ),
            ),
          ),
        );
      },
    );


  }

  Widget profileItems({
    String? key,
    String? value,
    bool coby = false,

  }) => Column(
    children: [
      Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color:  Color.fromARGB(255, 245, 245, 245),//HexColor('#F5F5F5'), //#F5F5F5
            ),
            child: Row(

              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        key!,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color.fromARGB(102, 47, 47, 47),//HexColor('#2F2F2F99')
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        value!,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color.fromARGB(153, 47, 47, 47),//HexColor('#2F2F2F99')
                        ),
                      ),
                    ],
                  ),
                ),
                if(coby)
                Spacer(),
                if(coby)
                IconButton(onPressed: (){
                  Clipboard.setData(ClipboardData(text: value));
                  toast(msg: 'Copy to Clipboard', state: ToastState.grey);
                }, icon: SvgPicture.asset('assets/images/copy.svg'),
                ),
              ],
            ),
          ),
      const SizedBox(height: 10,)
    ],
  );
}
