import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:less_dart/less.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_body_parser/shelf_body_parser.dart';

final less = Less();

Future<Response> processLess(Request request) async {
  Map files = request.context['postFileParams'];
  await for (var item in Stream.fromIterable(files.values)) {
    FileParams pFile = item[0];
    if (pFile != null) {
      final file = pFile.part;
      final stringStream = file.transform(utf8.decoder);
      final content = await stringStream.reduce((value, element) => value + element);
      final return_code = await less.parseLessFile(content);
      if (return_code == 0){
        final data = less.stdout.toString();
        less.stdout = StringBuffer();
        return Response.ok(data);
      } else {
        return Response.ok('-1');
      }
    } else {
      return Response.ok('0');
    }
  }
}

void main() async {
  print('Less compiler fast-cgi');
  final handler = const Pipeline().addMiddleware(logRequests()).addMiddleware(bodyParser(storeOriginalBuffer: false)).addHandler(processLess);
  var server = await shelf_io.serve(handler, 'localhost', 8080);

  print('Server is running on ${server.address.host}:${server.port}');
}

