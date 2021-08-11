import 'package:alexpark_videoeditor/aieditorpanel.dart';
import 'package:alexpark_videoeditor/backgroundmattingv2.dart';
import 'package:alexpark_videoeditor/freeformvideoinpainting.dart';
import 'package:alexpark_videoeditor/panopticdeeplab.dart';
import 'package:alexpark_videoeditor/skyar.dart';
import 'package:alexpark_videoeditor/wav2lip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'globals.dart' as globals;

class AIEditorApp extends StatelessWidget 
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
      home: AIEditor(),
    );
  }
}

class AIEditor extends StatefulWidget 
{
  @override
  _AIEditorState createState() => _AIEditorState();
}

class _AIEditorState extends State<AIEditor> 
{
  ItemScrollController aiscc = ItemScrollController();

  @override
  void initState() 
  {
    super.initState();
    globals.packData.aiscc = aiscc;
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
              AppLocalizations.of(context)!.aieditor,
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
            ScrollablePositionedList.builder(
              scrollDirection: Axis.horizontal,
  itemCount: 20,
  itemBuilder: (context, index)
  {
    if(index.isOdd)
    {
      return SizedBox(width: 5,);
    }
    switch (index~/2) 
    {
      case 0:
        return AIEditorPanel();
      case 1:
        return BackgroundMattingV2();
      case 2:
        return FreeFormVideoInpainting();
      case 3:
        return PanopticDeeplab();
      case 4:
        return SkyAR();  
      case 5:
        return Wav2Lip();                  
      default:
      try 
      {
        return SizedBox(width: globals.packData.optpanelwidth,child: Text((index~/2).toString()),);
      } 
      catch (e)
      {
        return SizedBox(width: globals.packData.optpanelwidth,child: Text(e.toString()),);
      }     
    }
  },
  itemScrollController: aiscc,
  //itemPositionsListener: itemPositionsListener,
),

          
          ),
        ],
      ),
    );
  }
}