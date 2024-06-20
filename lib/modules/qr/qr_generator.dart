import 'dart:convert';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:to_do_app/cubit/cubit.dart';
import 'package:to_do_app/cubit/states.dart';
import 'package:to_do_app/models/list_model.dart';
import 'package:to_do_app/modules/home/home_screen.dart';
import 'package:to_do_app/modules/qr/qr_result.dart';
import 'package:to_do_app/shared/component.dart';
import 'package:to_do_app/shared/constants.dart';

class ReadQRCodePage extends StatefulWidget {
  @override
  _ReadQRCodePageState createState() => _ReadQRCodePageState();
}

class _ReadQRCodePageState extends State<ReadQRCodePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String qrText = '';
  Barcode? barcode;
  bool isScanned = false;

  void closeScan() {
    isScanned = false;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, States>(
      listener: (BuildContext context, States state) {
        if (state is OneSuccessState) {
          navigateTo(
              context, QrResultScreen(model: AppCubit.get(context).oneModel));
        }
        if(state is OneErrorState){
          toast(msg: 'Can not find this task!', state: ToastState.error);
          navigateToFinish(
              context, HomeScreen());
        }
      },
      builder: (BuildContext context, States state) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Read QR Code"),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: isScanned
                    ? ConditionalBuilder(
                      condition: state is! OneLoadingState ,
                      builder: (BuildContext context) => Container(),
                      fallback: (BuildContext context) => Center(child: CircularProgressIndicator(color: DefaultColor.purple,),),
                    )
                    : QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                        overlay: QrScannerOverlayShape(),
                      ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text('Scanned Data: $qrText'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    if (!isScanned) {
      this.controller = controller;
      controller.scannedDataStream.listen((scanData) {
        setState(() {
          qrText = scanData.code ?? '';
          if (qrText != '') {
            isScanned = true;
            // var model = json.decode(qrText);
            // print(model);
            // ListModel listModel = ListModel.fromJson(model);
            // print(listModel.title);
            try {
              AppCubit.get(context).getOne(id: qrText);
            } catch (error) {
              print(error);
              toast(msg: 'Wrong QR Item', state: ToastState.error);
              Navigator.pop(context);
            }
          }
        });
      });
    }
  }
}
