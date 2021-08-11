import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'globals.dart' as globals;

class BackendsettingsPanelApp extends StatelessWidget 
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
      home: BackendsettingsPanel(),
    );
  }
}

class BackendsettingsPanel extends StatefulWidget 
{
  @override
  _BackendsettingsPanelState createState() => _BackendsettingsPanelState();
}

class _BackendsettingsPanelState extends State<BackendsettingsPanel> 
{
  final _formKey = new GlobalKey<FormState>();
  TextEditingController serveraddrctl = TextEditingController();
  TextEditingController apikeyctl = TextEditingController();
  TextEditingController finalwidthctl = TextEditingController();
  TextEditingController finalheightctl = TextEditingController();

  @override
  void initState() 
  {
    super.initState();

    serveraddrctl.text=globals.configFile.serveraddr;
    apikeyctl.text=globals.configFile.apikey;
    finalwidthctl.text=globals.configFile.finalwidth;
    finalheightctl.text=globals.configFile.finalheight;
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

  @override
  Widget build(BuildContext context) 
  {
    return 
    SizedBox
    (
      width: globals.packData.optpanelwidth,
      height: globals.packData.videoheight-globals.packData.titleheight,
      child:
      Align
      (
        alignment: Alignment.bottomCenter, 
        child:
        Form
        (
        key: _formKey,
        child: 
        ListView
        (
          reverse: true,
          padding: EdgeInsets.all(0.0),
          children:
          [
            SizedBox(height: globals.packData.buttonheight+globals.packData.buttongap,child:
            Row
            (
              children:
              [
                SizedBox
                (
                  width: globals.packData.optpanelwidth-110.0,
                ),
                ElevatedButton
                (
                  onPressed: 
                  ()
                  async
                  { 
                    //String rst = 
                    await globals.packData.readCfg();
                    _formKey.currentState!.reset();
                    serveraddrctl.text = globals.configFile.serveraddr;
                    apikeyctl.text = globals.configFile.apikey;
                    finalwidthctl.text = globals.configFile.finalwidth;
                    finalheightctl.text = globals.configFile.finalheight;
                  },
                  child: 
                  Text(AppLocalizations.of(context)!.resettodefault),
                ),
                SizedBox
                (
                  width: globals.packData.buttongaphrz,
                ),
                ElevatedButton
                (
                  onPressed: 
                  ()
                  async
                  {
                    final form = _formKey.currentState;
                    if(form!.validate())
                    {
                    }
                    else
                    {
                      return;
                    }
                    while(int.parse(globals.configFile.finalheight).isOdd||int.parse(globals.configFile.finalwidth).isOdd)
                    {
                      if(int.parse(globals.configFile.finalwidth)<320)
                      {
                        globals.configFile.finalwidth=321.toString();
                      }
                      if(int.parse(globals.configFile.finalwidth)>7680)
                      {
                        globals.configFile.finalwidth=7681.toString();
                      }
                      globals.configFile.finalwidth=(int.parse(globals.configFile.finalwidth)-1).toString();
                      globals.configFile.finalheight = (int.parse(globals.configFile.finalwidth).toDouble()~/globals.packData.videoaspect).toString();
                    }
                    //String rst = 
                    await globals.packData.writeCfg();
                    showDialog
                    (
                      context: context,
                      builder: (_) => new 
                      AlertDialog
                      (
                          title: new Text(AppLocalizations.of(context)!.resultdialog),
                          content: new Text(AppLocalizations.of(context)!.savesuccess),
                          actions: <Widget>
                          [
                            ElevatedButton(
                              child: Text(AppLocalizations.of(context)!.ok),
                              onPressed: () 
                              {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                      )
                    );
                  },
                  child: 
                  Text(AppLocalizations.of(context)!.submit),
                ),
              ],
            ),
            ),
            SizedBox
            (
              height:globals.packData.buttongap,
            ),
            TextFormField
            (
              controller: serveraddrctl,
              onChanged:
              (text)
              {
                globals.configFile.serveraddr = text;
              },
              decoration: 
              InputDecoration
              (
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                labelText: AppLocalizations.of(context)!.serveraddr,
                border: OutlineInputBorder
                (
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(),
                ),
              ),
              validator:
              (String? val) 
              {
                if(val==null||val.isEmpty) 
                {
                  return AppLocalizations.of(context)!.cannotempty;
                }
                else
                {
                  return null;
                }
              },
              keyboardType: TextInputType.text,
              style: TextStyle
              (
                fontSize: 12,
                //fontFamily: "Poppins",
              ),
            ),
            SizedBox
            (
              height:globals.packData.buttongap,
            ),
            TextFormField
            (
              controller: apikeyctl,
              onChanged:
              (text)
              {
                if(text.length>2)
                {
                  globals.configFile.apikey = text;
                }
              },
              decoration: 
              InputDecoration
              (
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                labelText: AppLocalizations.of(context)!.apikey,
                border: OutlineInputBorder
                (
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(),
                ),
              ),
              validator:
              (String? val) 
              {
                if(val==null||val.isEmpty) 
                {
                  return AppLocalizations.of(context)!.cannotempty;
                }
                else
                {
                  return null;
                }
              },
              keyboardType: TextInputType.text,
              style: TextStyle
              (
                fontSize: 12,
              ),
            ),
            SizedBox
            (
              height:globals.packData.buttongap,
            ),
            TextFormField
            (
              decoration: 
              InputDecoration
              (
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                labelText: AppLocalizations.of(context)!.finalvideowidth,
                border: OutlineInputBorder
                (
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(),
                ),
              ),
              controller: finalwidthctl,
              textAlign: TextAlign.center,
              onChanged:
              (text)
              {
                try
                {
                  globals.configFile.finalwidth = text;
                  globals.configFile.finalheight = (int.parse(globals.configFile.finalwidth).toDouble()~/globals.packData.videoaspect).toString();

                  finalheightctl.text = globals.configFile.finalheight;
                }
                catch(e)
                {

                }
              },
              keyboardType: TextInputType.number,
              style: TextStyle
              (
                fontSize: 12,
              ),
            ),
            SizedBox
            (
              height:globals.packData.buttongap,
            ),
            TextFormField
            (
              decoration: 
              InputDecoration
              (
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                labelText: AppLocalizations.of(context)!.finalvideoheight,
                border: OutlineInputBorder
                (
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(),
                ),
              ),
              controller: finalheightctl,
              textAlign: TextAlign.center,
              onChanged:
              (text)
              {
                try
                {
                  globals.configFile.finalheight = text;
                  globals.configFile.finalwidth = (int.parse(globals.configFile.finalheight).toDouble()*globals.packData.videoaspect).toInt().toString();

                  finalwidthctl.text = globals.configFile.finalwidth;
                }
                catch(e)
                {

                }
              },
              keyboardType: TextInputType.number,
              style: TextStyle
              (
                fontSize: 12,
              ),
            ),
            SizedBox
            (
              height:globals.packData.buttongap,
            ),
            Row(
              children:
              [
            Text
            (
              AppLocalizations.of(context)!.finalaspectratio,
              style: TextStyle(fontSize: 10),
            ),
            SizedBox(width: 40,),
            DropdownButton<String>
            (
      value: globals.configFile.videoaspect,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(fontSize: 12),
      underline: Container(
        height: 2,
      ),
      onChanged: (String? newValue) 
      {
          if(newValue=="16:9")
          {
            globals.packData.videoaspect = 16/9;
            globals.configFile.videoaspect = "16:9";
          }
          else if(newValue=="16:10")
          {
            globals.packData.videoaspect = 16/10;
            globals.configFile.videoaspect = "16:10";
          }
          else if(newValue=="9:16")
          {
            globals.packData.videoaspect = 9/16;
            globals.configFile.videoaspect = "9:16";
          }
          else if(newValue=="4:3")
          {
            globals.packData.videoaspect = 4/3;
            globals.configFile.videoaspect = "4:3";
          }
          else
          {
            globals.packData.videoaspect = 16/9;
            globals.configFile.videoaspect = "16:9";
          }
          try
          {
            globals.configFile.finalheight = (int.parse(globals.configFile.finalwidth).toDouble()~/globals.packData.videoaspect).toString();
            finalheightctl.text = globals.configFile.finalheight;
            while(int.parse(globals.configFile.finalheight).isOdd||int.parse(globals.configFile.finalwidth).isOdd)
            {
              if(int.parse(globals.configFile.finalwidth)<320)
              {
                globals.configFile.finalwidth=321.toString();
              }
              if(int.parse(globals.configFile.finalwidth)>7680)
              {
                globals.configFile.finalwidth=7681.toString();
              }
              globals.configFile.finalwidth=(int.parse(globals.configFile.finalwidth)-1).toString();
              globals.configFile.finalheight = (int.parse(globals.configFile.finalwidth).toDouble()~/globals.packData.videoaspect).toString();
            }
          }
          catch(e)
          {
          }
      },
      items: <String>['16:9', '16:10', '9:16', '4:3']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
            ),
              ],
            ),
            SizedBox
            (
              height:globals.packData.buttongap,
            ),
            SizedBox(height: globals.packData.buttonheight+globals.packData.buttongap,child:
            Row
            (
              children:
              [
                SizedBox
                (
                  width: globals.packData.optpanelwidth-110.0,
                ),
                ElevatedButton
                (
                  onPressed: 
                  ()
                  async
                  { 
                    //String rst = 
                    await globals.packData.readCfg();
                    _formKey.currentState!.reset();
                    serveraddrctl.text = globals.configFile.serveraddr;
                    apikeyctl.text = globals.configFile.apikey;
                    finalwidthctl.text = globals.configFile.finalwidth;
                    finalheightctl.text = globals.configFile.finalheight;
                    //globals.packData.mainsetstate.call();
                  },
                  child: 
                  Text(AppLocalizations.of(context)!.resettodefault),
                ),
                SizedBox
                (
                  width: globals.packData.buttongaphrz,
                ),
                ElevatedButton
                (
                  onPressed: 
                  ()
                  async
                  {
                    final form = _formKey.currentState;
                    if(form!.validate())
                    {
                    }
                    else
                    {
                      return;
                    }
                    while(int.parse(globals.configFile.finalheight).isOdd||int.parse(globals.configFile.finalwidth).isOdd)
                    {
                      if(int.parse(globals.configFile.finalwidth)<320)
                      {
                        globals.configFile.finalwidth=321.toString();
                      }
                      if(int.parse(globals.configFile.finalwidth)>7680)
                      {
                        globals.configFile.finalwidth=7681.toString();
                      }
                      globals.configFile.finalwidth=(int.parse(globals.configFile.finalwidth)-1).toString();
                      globals.configFile.finalheight = (int.parse(globals.configFile.finalwidth).toDouble()~/globals.packData.videoaspect).toString();
                    }
                    //String rst = 
                    await globals.packData.writeCfg();
                    showDialog
                    (
                      context: context,
                      builder: (_) => new 
                      AlertDialog
                      (
                          title: new Text(AppLocalizations.of(context)!.resultdialog),
                          content: new Text(AppLocalizations.of(context)!.savesuccess),
                          actions: <Widget>
                          [
                            ElevatedButton(
                              child: Text(AppLocalizations.of(context)!.ok),
                              onPressed: () 
                              {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                      )
                    );
                  },
                  child: 
                  Text(AppLocalizations.of(context)!.submit),
                ),
              ],
            ),
            ),
          ]
        ),
        ),
      ),
    );
  }
}