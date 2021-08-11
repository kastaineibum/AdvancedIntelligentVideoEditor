/*
import 'package:flutter/material.dart';

class CText extends StatefulWidget
{
  CText({Key? k,String this.text='',TextStyle? this.ts,}):super(key:k);
  String text;
  TextStyle? ts;

  @override
  _CTextState createState() => _CTextState();

}

class _CTextState extends State<CText>
{
  String localtext='';
  TextStyle? localts;
  @override
  void initState() 
  {
    localtext = widget.text;
    localts = widget.ts;
    super.initState();
  }

  @override
  void dispose() 
  {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Text(localtext,style: localts,);
  }
}
*/