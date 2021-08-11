import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'videolayerstruct.dart';

class VideoRulerPainter extends CustomPainter
{
  double rulerlength = 0;
  double shortlinesize = 0;
  double longlinesize = 0;
  double shortgapsize = 0;
  double shortgapsec = 0;
  int howmanyshortstolong = 0;
  int howmanyshortstotext = 0;
  Paint paint1 = Paint();
  Paint paint2 = Paint();


  VideoRulerPainter()
  {
    this.rulerlength = vlu.getListWidthLength();

    this.shortlinesize = 10.0;
    this.longlinesize = 15.0;
    this.shortgapsec = 1.0;
    this.shortgapsize = vlu.vls.scalefactor * this.shortgapsec;
    this.howmanyshortstolong = 15;
    this.howmanyshortstotext = 15;
    paint1.color = globals.packData.color2(colorcase:2);
    paint1.style = PaintingStyle.fill;
    paint2.color = globals.packData.color2(colorcase:3);
    paint2.style = PaintingStyle.fill;
  }

  void resizeRuler()
  {
    rulerlength = vlu.getListWidthLength();

  }

  @override
  void paint(Canvas canvas, Size size) 
  {

    int howmanyshorts = 0;
    int howmanyshorts2 = 0;
    for(double x=0.0;x<size.width;x+=shortgapsize)
    {
      
      if(howmanyshorts==howmanyshortstolong)
      {
        Offset p1 = Offset(x, 0.0);
        Offset p2 = Offset(x, longlinesize);
        canvas.drawLine(p1, p2, paint2);
        howmanyshorts = 0;
      }
      else
      {
        Offset p1 = Offset(x, 0.0);
        Offset p2 = Offset(x, shortlinesize);
        canvas.drawLine(p1, p2, paint1);
      }
      howmanyshorts += 1;
      
      String st1 = Duration
              (
                //milliseconds: (x/vlu.vls.scalefactor*1000.0).toInt()
                milliseconds: (x/vlu.vls.scalefactor*1000.0).ceil()
              ).toString();
      st1=st1.substring(0,st1.indexOf('.'));
      if(howmanyshorts2==howmanyshortstotext)
      {
         final TextPainter textPainter = 
         TextPainter
         (
          text: 
          TextSpan
          (
            text: 
              st1,
              style: 
              TextStyle
              (
                fontSize: 8.0,
                color: globals.packData.color2(colorcase:4),
              ), 
          ),
          textAlign: TextAlign.justify,
          textDirection: TextDirection.ltr
        )
          ..layout(maxWidth: 32.0);  
        textPainter.paint(canvas, Offset(x-12.0, 2.0));

        howmanyshorts2 = 0;
      }
      howmanyshorts2 += 1;
    }
    
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) 
  {
    return false;
  }

}

