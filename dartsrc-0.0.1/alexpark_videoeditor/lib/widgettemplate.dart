import 'package:flutter/material.dart';
import 'globals.dart' as globals;

class WidgetSampleApp extends StatelessWidget 
{
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: globals.packData.apptitle,
      theme: ThemeData(
        primarySwatch: globals.packData.colorFromARGB(255,136,14,79),
        buttonTheme: const ButtonThemeData
        (
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: WidgetSample(),
    );
  }
}

class WidgetSample extends StatefulWidget 
{
  @override
  _WidgetSampleState createState() => _WidgetSampleState();
}

class _WidgetSampleState extends State<WidgetSample> 
{
  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      body: 
      Text('text'),
      floatingActionButton: 
      FloatingActionButton
      (
        onPressed: () 
        {
          setState(() 
          {
            
          });
        },
        child: 
        Icon
        (
          Icons.play_arrow,
        ),
      ),
    );
  }
}