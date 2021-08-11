// ignore_for_file: avoid_renaming_method_parameters

import 'package:flutter/material.dart';
import 'package:xterm/buffer/line/line.dart';
import 'package:async_task/async_task.dart';
import 'dart:async';
import 'dart:io';
import 'package:xterm/xterm.dart';
import 'package:xterm/flutter.dart';
import 'alexpark_taskprocessor.dart' as g;
import 'globals.dart' as globals;
import 'videolayerstruct.dart';
//import 'package:clipboard/clipboard.dart';

void main(List<String> arguments) 
async
{
  
  runApp(const ServerApp());
}

List<AsyncTask> _taskTypeReg() => [ServeTask('')];
class ServeTask extends AsyncTask<String, bool> 
{
  String args;

  ServeTask(this.args);

  @override
  AsyncTask<String, bool> instantiate(String parameters,[m]) 
  {
    return ServeTask(parameters);
  }

  @override
  String parameters() 
  {
    return args;
  }

  @override
  FutureOr<bool> run() 
  {
    return taskThread(args);
  }

  Future<bool> taskThread(String args) 
  async
  {
    switch (args) 
    {
      case 'taskreading':

        await g.fp.dbconnect();
        await g.fp.ifenablelog();
        while (true) 
        {
      try
      {          
          int i0 = int.parse(await g.fp.getdbvar("tasklooptotal"));
          await g.fp.setdbvar("tasklooptotal", (i0+1).toString());
          //await g.fp.appendecho('taskreading '+i0.toString()+"\n");
          sleep(const Duration(seconds:1));

          int currenttaskid = int.parse(await g.fp.getdbvar("currenttaskid"));
          if(currenttaskid==0)
          {
            String needprocessing = await g.fp.gettaskneedprocessing();
            await g.fp.setdbvar("currenttaskid", needprocessing);
          }
      }
      catch(e)
      {
        g.fp.appendecho(e.toString()+"\n");
      }
        }
        //await g.fp.dbclose();
        //break;
      case 'processing':

        await g.fp.dbconnect();
        await g.fp.ifenablelog();
        while (true) 
        {
      try
      {
          int j0 = int.parse(await g.fp.getdbvar("tasklooptotal"));
          await g.fp.setdbvar("tasklooptotal", (j0+1).toString());
          //await g.fp.appendecho('processing '+j0.toString()+"\n");
          sleep(const Duration(seconds:1));

          String ctid = await g.fp.getdbvar("currenttaskid");
          String ctcl = "";
          int currenttaskid = int.parse(ctid);
          if(currenttaskid!=0)
          {
            vlu.vls.videolayers.clear();
            await g.fp.loadtovls(ctid);
            await g.fp.appendecho("load task: "+ctid+"\n"+"load video layers: "+vlu.vls.videolayers.length.toString()+"\n");
            ctcl = await g.fp.gettaskclass(ctid);
            switch (ctcl) 
            {
              case "regular":
                await g.fp.calcurrentvls(ctid);
                break;
              case "-":
                await g.fp.appendecho("task class error.\n");
                break;
              case "backgroundmattingv2":
                await g.fp.calbackgroundmattingv2(ctid);
                break;
              case "freeformvideoinpainting":
                await g.fp.calfreeformvideoinpainting(ctid);
                break; 
              case "panopticdeeplab":
                await g.fp.calpanopticdeeplab(ctid);
                break;                  
              case "skyar":
                await g.fp.calskyar(ctid);
                break;   
              case "wav2lip":
                await g.fp.calwav2lip(ctid);
                break;               
              default:
            }
            await g.fp.setdbvar("currenttaskid", "0");
          }

      }
      catch(e)
      {
        g.fp.appendecho(e.toString()+"\n");
        String ctid = await g.fp.getdbvar("currenttaskid");
        await g.fp.taskfailed(ctid);
        await g.fp.setdbvar("currenttaskid", "0");
      }
        }
        //await g.fp.dbclose();
        //break;
      case 'statusdealing':

        await g.fp.dbconnect();
        await g.fp.ifenablelog();
        while (true) 
        {
      try
      {          
          int k0 = int.parse(await g.fp.getdbvar("tasklooptotal"));
          await g.fp.setdbvar("tasklooptotal", (k0+1).toString());
          //await g.fp.appendecho('statusdealing '+k0.toString()+"\n");
          sleep(const Duration(seconds:1));
      }
      catch(e)
      {
        g.fp.appendecho(e.toString()+"\n");
      }         
        }
        //await g.fp.dbclose();
        //break;
      case 'test':
        await g.fp.dbconnect(); 
        await g.fp.ifenablelog();
        while (true) 
        {
          //print('test ');
          sleep(const Duration(seconds:1));
        }
        //await g.fp.dbclose();
        //break; 
      default:
    }
    return true;
  }


}

class ServerApp extends StatelessWidget 
{
  const ServerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp
    (
      title: 'alexpark_taskserverui',
      theme: ThemeData
      (
        primarySwatch: globals.packData.color1(colorcase: 1),
      ),
      home: const ServerAppUI(title: 'alexpark_taskserverui'),
    );
  }
}

class ServerAppUI extends StatefulWidget 
{
  const ServerAppUI({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ServerAppUI> createState() => _ServerAppUIState();
}

class _ServerAppUIState extends State<ServerAppUI> 
{
  late Terminal terminal;
  late List<BufferLine> lbs;
  //List<String> tlines=List.filled(0,"",growable: true);
  late Timer timerloop;
  late ScrollController scc;
  int initflag=0;

  @override
  void initState() 
  {
    initflag = 1;
    scc = ScrollController();
    terminal = Terminal(maxLines: 2048);
    
    /*    */
    terminal.addListener
    (
      ()
      async
      {

      }
    );


    timerloop = Timer.periodic(const Duration(milliseconds: 200), (timer) 
    async
    {
      if(initflag==1)
      {
        initflag=0;

        terminal.write(DateTime.now().toString()+"\r\n");
        //tlines.add(DateTime.now().toString()+"\r\n");
        await g.fp.dbconnect();
        terminal.write("database connected.\r\n");
        //tlines.add("database connected.\r\n");
        int i0 = int.parse(await g.fp.getdbvar("tasklooptotal"));
        await g.fp.setdbvar("tasklooptotal: ", i0.toString()+"\r\n");
      }

      try
      {
        terminal.write(await g.fp.pumpecho());
        //tlines.add(await g.fp.pumpecho());
      }
      catch(e)
      // ignore: empty_catches
      {

      }
      
        setState(() 
        {

        });

    });

    var tasks = 
    [
      ServeTask('taskreading'),
      ServeTask('processing'),
      //ServeTask('statusdealing'),
      //ServeTask('test'),
    ];

    var asyncExecutor = 
    AsyncExecutor
    (
      sequential: false, 
      parallelism: 2,
      taskTypeRegister: _taskTypeReg,
    );
    asyncExecutor.logger.enabled = true ;
    //var executions = 
      asyncExecutor.executeAll(tasks);
    //await Future.wait(executions);

    super.initState();
  }

  @override
  Widget build(BuildContext context) 
  {
    final scrsize = MediaQuery.of(context).size;
    //final scrpixelratio = MediaQuery.of(context).devicePixelRatio;
    final scrwidth = scrsize.width;
    final scrheight = scrsize.height;
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text(widget.title),
      ),
      body: 
      Center
      (
        child: Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children:
          [
            SizedBox
            (
              width: scrwidth,
              height: scrheight-56,
              child: 
              /*
                ListView.builder
                (itemBuilder: 
                  (context,idx)
                  {
                    return Text(tlines[idx],style: const TextStyle(fontSize: 10),);
                  }
                ),
              */
              /*              */
                TerminalView
                (
                  scrollController: scc,
                  terminal: terminal
                ),

            ),
            
          ],
        ),
      ),
    );
  }
}
