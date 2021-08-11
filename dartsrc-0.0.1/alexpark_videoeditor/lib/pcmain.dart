import 'package:alexpark_videoeditor/videooperatorpc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:resizable_widget/resizable_widget.dart';
import 'package:quiver/async.dart';
//import 'package:animated_text_kit/animated_text_kit.dart';
import 'globals.dart' as globals;
import 'videolayer.dart';


class PCMainApp extends StatelessWidget 
{
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp
    (
      title: globals.packData.apptitle,
      localizationsDelegates: 
      [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: 
      [
        const Locale('en', ''),
        const Locale('zh', ''),
        const Locale('es', ''),
      ],
      theme: 
      ThemeData
      (
        fontFamily: "Roboto",
        brightness: Brightness.dark,
        primarySwatch: globals.packData.color1(colorcase:1),
        elevatedButtonTheme: ElevatedButtonThemeData
        (
          style: 
          ButtonStyle
          (
            padding: 
            MaterialStateProperty.all<EdgeInsets>
            (
              EdgeInsets.symmetric(horizontal: 0, vertical: 0)
            ),
            textStyle: 
            MaterialStateProperty.all<TextStyle>
            (
              TextStyle
              (
                fontFamily: "Roboto",
                fontSize: 12,
                //fontWeight: FontWeight.normal
              )
            ),
            minimumSize: 
            MaterialStateProperty.all<Size>
            (
              Size(globals.packData.buttonminwidth, globals.packData.buttonheight)
            ),
            enableFeedback: false,
          ), 
        ),
        scrollbarTheme: ScrollbarThemeData
        (
          
        ),
      ),
      home: PCMain(),
    );
  }
}

class PCMain extends StatefulWidget 
{
  //String titletimepos = "";

  @override
  _PCMainState createState() => _PCMainState();
}

class _PCMainState extends State<PCMain>
{
  //String titletimepos = "";

  //late Timer timerloop;

  void mainsetstate()
  {
      setState(() 
      {
        //rebuildAllChildren(context);
      });
  }

  @override
  void initState() 
  {
    super.initState();

    globals.packData.mainsetstate = mainsetstate;
/*
    timerloop = Timer.periodic(Duration(milliseconds: 100), (timer) 
    async
    {
      setState(() 
      {
        //rebuildAllChildren(context);
      });
    });
 */

    //Size size = await DesktopWindow.getWindowSize();
    //await DesktopWindow.setMinWindowSize(size);
    //await DesktopWindow.setMaxWindowSize(size);
    //DesktopWindow.toggleFullScreen();
  }

  @override
  void dispose() 
  {
    //timerloop.cancel();

    super.dispose();
  }

  void rebuildAllChildren(BuildContext context) 
  {
    void rebuild(Element el) 
    {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }

  //int _start = 100;
  //int _current = 100;
  void startTimer(BuildContext context) 
  {
    CountdownTimer countDownTimer = new CountdownTimer
    (
      //new Duration(milliseconds: _start),
      new Duration(milliseconds: 100),
      new Duration(milliseconds: 50),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) 
    {
      //setState
      //(
        //() 
        //{ 
          //_current = _start - duration.elapsed.inMilliseconds; 
          //print('$_current');
        //}
      //);
    });
    sub.onDone(() 
    {
      //print('$_current');   
        setState
        (
        () 
        { 
          globals.packData.initflag = 2;
        }
        );
      sub.cancel();
    });
  }

  void startTimer2(BuildContext context) 
  {
    CountdownTimer countDownTimer = new CountdownTimer
    (
      new Duration(milliseconds: 1000),
      new Duration(milliseconds: 100),
    );
    var sub = countDownTimer.listen(null);
    sub.onData((duration) 
    {
    });
    sub.onDone(() 
    {
      if(globals.packData.initflag==4)
      {
        globals.packData.initflag = 0;
      }
      sub.cancel();
    });
  }


  @override
  Widget build(BuildContext context) 
  {
    final scrsize = MediaQuery.of(context).size;
    final scrpixelratio = MediaQuery.of(context).devicePixelRatio;
    final scrwidth = scrsize.width;
    final scrheight = scrsize.height;
    if(globals.packData.initflag==1)
    {
      //globals.packData.readCfg();

      //globals.packData.videolinepercent = 0.5;

      //globals.packData.titleheight = 20.0;
      //globals.packData.rulerheight = 20.0;
      //globals.packData.layeritemheight = 50.0;
      //globals.packData.tabsize = 20.0;
      globals.packData.scrheight = scrheight;
      globals.packData.scrwidth = scrwidth;
      globals.packData.scrpixelratio = scrpixelratio;

      globals.packData.videolinepercent = ((scrwidth-600.0)/globals.packData.videoaspect+globals.packData.titleheight)/scrheight;

      globals.packData.videoheight = scrsize.height*globals.packData.videolinepercent;
      globals.packData.videowidth = (scrsize.height*globals.packData.videolinepercent-globals.packData.titleheight)*globals.packData.videoaspectforbp;
      globals.packData.listheight = scrsize.height*(0.96-globals.packData.videolinepercent);
      globals.packData.listwidth = scrsize.width;
      globals.packData.optpanelwidth = scrsize.width - globals.packData.videowidth - 55.0;

      globals.packData.mobilemaincontext = context;
      globals.packData.currentposctl = TextEditingController(text:globals.packData.currentpos);

      for(int i=0;i<100;i++)
      {
        globals.packData.blockpicktcc.add(TextEditingController());
      }
      for(int i=0;i<100;i++)
      {
        globals.packData.colorpicktcc.add(TextEditingController());
      }
      
      globals.packData.initflag = 0;      
    }
    else if(globals.packData.initflag==2)
    {
      globals.packData.initflag = 4;
      rebuildAllChildren(context);
      startTimer2(context);
    }
    
    //print('scrsize: $scrwidth x $scrheight; $scrpixelratio');
    return Scaffold
    (
      body: 
      ResizableWidget
      (
        isHorizontalSeparator: true,
        percentages: [0.04,globals.packData.videolinepercent,0.96-globals.packData.videolinepercent],
        separatorSize: 4,
        separatorColor: globals.packData.color1(colorcase:2),
        onResized: (infoList)
        {
          //print(infoList.map((x) => '(${x.size}, ${x.percentage}%)').join(", "));

          globals.packData.videowidth = (infoList[1].size-globals.packData.titleheight)*globals.packData.videoaspectforbp;
          globals.packData.videoheight = infoList[1].size;
          globals.packData.listheight = infoList[2].size;

          if(globals.packData.initflag != 4)
          {
            startTimer(context);
          }
          else
          {

          }
        },
        children: 
        [
          Container
          (
            //alignment: Alignment.centerRight,
            color: globals.packData.color1(colorcase:1),
            child: 
                Row
                (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: 
                  [
                    Text
                    (
                      AppLocalizations.of(context)!.apptitle 
                      + AppLocalizations.of(context)!.spacechar3
                      + AppLocalizations.of(context)!.softwarever
                      + globals.packData.softwarever 
                      + " "
                      + AppLocalizations.of(context)!.nocommercial
                      + AppLocalizations.of(context)!.spacechar3
                      + AppLocalizations.of(context)!.currentpos,
                      style: 
                      TextStyle(fontSize: 12),
                    ),
                    SizedBox
                    (
                      width: 100,
                      height: 21,
                      child: 
                      TextFormField
                      (
                        controller: globals.packData.currentposctl,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.bottom,
                        onChanged:
                        (text)
                        {
                        },
                        //decoration: 
                        //InputDecoration
                        //(
                          //contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                          //border: OutlineInputBorder
                          //(
                            //borderRadius: BorderRadius.circular(0.0),
                            //borderSide: BorderSide(width: 0.0),
                          //),
                        //),
                        //readOnly: true,
                        keyboardType: TextInputType.datetime,
                        style: TextStyle
                        (
                          fontSize: 12,
                          //fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    ElevatedButton
                    (
                      onPressed: 
                      ()
                      async
                      {
                        if(!globals.packData.isVideoPlaying())
                        {
                          await globals.packData.videoPauseAt
                          (
                            globals.packData.millisecFromTimestr(globals.packData.currentposctl.text.trim())
                          );
                          globals.packData.marklayerneedscroll = true;
                        }
                      }, 
                      child: Icon(Icons.fmd_good),
                      
                    ),
                  ],
                ), 
            
                
                //CText(k: UniqueKey(),text: '$titletimepos',ts: TextStyle(fontSize: 12),),

/*
AnimatedTextKit(
  animatedTexts: [
    TypewriterAnimatedText(
      AppLocalizations.of(context)!.apptitle + AppLocalizations.of(context)!.spacechar3+AppLocalizations.of(context)!.softwarever+globals.packData.softwarever 
      + AppLocalizations.of(context)!.spacechar3 + AppLocalizations.of(context)!.currentpos + '$titletimepos',
      textStyle: const TextStyle(
        fontSize: 12.0,
        //fontWeight: FontWeight.bold,
      ),
      speed: const Duration(milliseconds: 200),
    ),
  ],
  totalRepeatCount: 4,
  pause: const Duration(milliseconds: 200),
  displayFullTextOnTap: true,
  stopPauseOnTap: true,
),
*/

          ),
          VideoOperatorPC(),
          VideoLayer(),
        ],
      ),

/*
      floatingActionButton: 
      FloatingActionButton
      (
        onPressed: () 
        {
          setState(() 
          {
              if (_betterPlayerController.isPlaying().toString()=='true') 
              {
                _betterPlayerController.pause();
              } 
              else 
              {
                _betterPlayerController.play();
              }
          });
        },
        child: 
        Icon
        (
          _betterPlayerController.isPlaying().toString()=='true' ? Icons.pause : Icons.play_arrow,
        ),
      ),
*/
    );
  }
}