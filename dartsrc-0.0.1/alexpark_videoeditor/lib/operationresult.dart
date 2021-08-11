import 'package:alexpark_videoeditor/operationresultpanel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'globals.dart' as globals;

class OperationResultApp extends StatelessWidget 
{
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: globals.packData.apptitle,
      theme: ThemeData(
        primarySwatch: globals.packData.color1(colorcase:1),
        buttonTheme: const ButtonThemeData
        (
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: OperationResult(),
    );
  }
}

class OperationResult extends StatefulWidget 
{
  @override
  _OperationResultState createState() => _OperationResultState();
}

class _OperationResultState extends State<OperationResult> 
{
  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) 
  {
    return Container
    (
      child: 
      Column
      (
        children: 
        [
          Container
          (
            alignment: Alignment.center,
            height: globals.packData.titleheight,
            //width: globals.packData.scrwidth-globals.packData.videowidth-globals.packData.tabsize,
            color: globals.packData.color2(colorcase: 6),
            padding: EdgeInsets.all(0.0),
            child: 
            Text
            (
              AppLocalizations.of(context)!.operationresult,
              style: TextStyle
              (
                fontSize: 10.0,
              ),
            ),
          ),
          SizedBox
          (
            height: globals.packData.videoheight-globals.packData.titleheight,
            child:
            ListView
            (
              scrollDirection: Axis.horizontal,
              children: 
              [
                OperationResultPanel(),
              ],
            ) 
          
          ),
        ],
      ),
    );
  }
}