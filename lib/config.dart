import 'package:http_parser/http_parser.dart';


class Config {

  static String ws_url = "wss://api.sv.pro.vn/ws/";
  //static String ws_url = "ws://127.0.0.1:8000/ws/";


  static const request_url = 'https://api.sv.pro.vn';
  //static const request_url = 'http://127.0.0.1:8000';


  static MediaType getMediaType(String path) {
    final ext = path.toLowerCase().split('.').last;

    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

}