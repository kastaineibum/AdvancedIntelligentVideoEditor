import 'dart:io';

import 'package:alexpark_apikeydecryptor/alexpark_apikeydecryptor.dart' as alexpark_apikeydecryptor;

void main(List<String> arguments) 
async
{
  /*
  String key = alexpark_apikeydecryptor.datetimetokey();
  print('key: $key');
  
  String encodetest = alexpark_apikeydecryptor.encodeDES3CBC("3mn.net-123456789987654321");
  print('3mn.net-123456789987654321: $encodetest');
  String decodetest = alexpark_apikeydecryptor.decodeDES3CBC(encodetest);
  print('$encodetest: $decodetest');
  String decodetest1minago = alexpark_apikeydecryptor.decodeDES3CBC1minago(encodetest);
  print('$encodetest 1minago: $decodetest1minago');
  */
  String message='-';
  String ifformer='0';
  String decodesrt = '';
  String taskid='';

  if(arguments.length<2)
  {
    print ("argument1: php \$_REQUEST[\"key\"]\r\nargument2: 0:current key decode 1:former key decode");
  }
  else
  {
    message = arguments[0];
    ifformer = arguments[1];

    if(arguments.length==3)
    {
      taskid = arguments[2];
      await alexpark_apikeydecryptor.dbconnect();
      String keystr = (await alexpark_apikeydecryptor.gettaskkey(taskid)).trim();
      print(keystr);
      exit(0);
      //return;
    }

    if(ifformer=='0')
    {
      decodesrt = alexpark_apikeydecryptor.decodeDES3CBC(message);
      print(decodesrt);
      exit(0);
    }
    else if(ifformer=='1')
    {
      decodesrt = alexpark_apikeydecryptor.decodeDES3CBC1minago(message);
      print(decodesrt);
      exit(0);
    }
    else
    {

    }
  }

}
