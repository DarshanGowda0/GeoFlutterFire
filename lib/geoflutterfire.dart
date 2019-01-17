import 'dart:async';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/util.dart';

class Geoflutterfire {
  /*static const MethodChannel _channel =
      const MethodChannel('geoflutterfire');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }*/

  Geoflutterfire(){
    
  }
  
  static List<double> getHash(){
    List<double> something = Util().decode_bbox("tdr1zdkb0");
    return something;
  }


}
