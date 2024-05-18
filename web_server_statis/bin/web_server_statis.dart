// contoh program static handler
import 'package:shelf_static/shelf_static.dart' as shelf_static;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:path/path.dart' as path;
import 'dart:io' as io;
import 'package:mysql1/mysql1.dart';
import 'package:os_detect/os_detect.dart' as os_detect;

Future<String> readData() async {
final conn=await MySqlConnection.connect(ConnectionSettings(
    host:'192.168.137.1',
    port:3306,
    user:'root',
    db:'programmer',
    password:'12345',
));

var hasil=StringBuffer('');
var results=await conn.query(
           'select BookName, AuthorName, Summary, Price from Books');
for(var row in results) {
  hasil.writeln('''
        <tr class="table-info">
        <td>${row[0]}</td>
        <td>${row[1]}</td>
        <td>${row[3]}</td>
         </tr>
''');
 }
 await conn.close();
 return hasil.toString();
}

Future<void> insertData(String jbuku, String pbuku, String pnbuku, String sumary, String hbuku, String agbuku) async {
final conn=await MySqlConnection.connect(ConnectionSettings(
    host:'192.168.137.1',
    port:3306,
    user:'root',
    db:'programmer',
    password:'12345',
));

var results=await conn.query(
           'insert into Books ( BookName, AuthorName, Publisher, Summary, Price, PictureAdd) value (?,?,?,?,?,?)',[jbuku, pbuku, pnbuku, sumary, hbuku, agbuku]);
  print(' insert row is = ${results.insertId}');
 await conn.close();
 
}


Future<String> readDataEditDelete(int jenis) async {
final conn=await MySqlConnection.connect(ConnectionSettings(
    host:'192.168.137.1',
    port:3306,
    user:'root',
    db:'programmer',
    password:'12345',
));

var menujenis='';
var menu='';
if(jenis==1){menujenis='/editData';menu="edit";} else if(jenis==2){menujenis='/deleteData';menu="delete";}
var hasil=StringBuffer('');
var results=await conn.query(
           'select BookID, BookName, AuthorName, Summary, Price from Books');
for(var row in results) {
  hasil.writeln('''
        <tr class="table-info">
        <td>${row[1]}</td>
        <td>${row[2]}</td>
        <td>${row[4]}</td>
        <td><a href="$menujenis/${row[0]}">$menu</a></td>
         </tr>
''');
 }
 await conn.close();
 return hasil.toString();
}

Future<String> readData1Record(String id) async {
final conn=await MySqlConnection.connect(ConnectionSettings(
    host:'192.168.137.1',
    port:3306,
    user:'root',
    db:'programmer',
    password:'12345',
));

var hasil=StringBuffer('');
var results=await conn.query(
           'select  BookName, AuthorName,Publisher, Summary, Price, PictureAdd from Books where BookID=?',[id]);
for(var row in results) {
  hasil.writeln('''
        ${row[0]};${row[1]};${row[2]};${row[3]};${row[4]};${row[5]}
''');
 }
 await conn.close();
 return hasil.toString();
}

Future<void> updateData(String idbuku, String jbuku, String pbuku, String pnbuku, String sumary, String hbuku, String agbuku) async {
final conn=await MySqlConnection.connect(ConnectionSettings(
    host:'192.168.137.1',
    port:3306,
    user:'root',
    db:'programmer',
    password:'12345',
));

var results=await conn.query(
           'update Books set BookName=?, AuthorName=?, Publisher=?, Summary=?, Price=?, PictureAdd=? where BookID=?',[jbuku, pbuku, pnbuku, sumary, hbuku, agbuku,idbuku]);
 // print(' insert row is = ${results.insertId}');
 await conn.close();
 
}

Future<void> deleteData(String idbuku) async {
final conn=await MySqlConnection.connect(ConnectionSettings(
    host:'192.168.137.1',
    port:3306,
    user:'root',
    db:'programmer',
    password:'12345',
));

var results=await conn.query(
           'delete from Books  where BookID=?',[idbuku]);
 // print(' insert row is = ${results.insertId}');
 await conn.close();
 
}



String getSign()
{
var sign1='';
if(os_detect.isLinux) {
  print('  OS type : Linux');
  sign1='/';
} else if(os_detect.isMacOS) {
  print('  OS type : MacOS');
  sign1='/';
} else if(os_detect.isWindows) {
  print('  OS type : Windows');
  sign1='\\';
}
return sign1;
}

void main() async {
  var sign1=getSign();
  var pathToBuild = path.join(path.dirname(io.Platform.script.toFilePath()));
  var x=pathToBuild.split(sign1);
  var p=x.length-1;
  var hasil='${x.sublist(0,p).join(sign1)}${sign1}www${sign1}html';

  print(pathToBuild);
  final staticHandler0 = shelf_static.createStaticHandler('$hasil${sign1}program',
      defaultDocument: 'menuutama.html');

    final staticHandler1 = Pipeline().addHandler(
        shelf_static.createStaticHandler('$hasil${sign1}program', defaultDocument: 'about.html'));

    final staticHandler2 = Pipeline().addHandler(
        shelf_static.createStaticHandler('$hasil${sign1}program', defaultDocument: 'dashboard.html'));

    final staticHandler3 = Pipeline().addHandler(
        shelf_static.createStaticHandler('$hasil${sign1}program', defaultDocument: 'daftarbuku.html'));

    final staticHandler4 = Pipeline().addHandler(
        shelf_static.createStaticHandler('$hasil${sign1}program', defaultDocument: 'inputbuku.html'));

Response _render(String body){
    return Response.ok(body, headers:{
      'Content-type':'text/html; charset=UTF-8',
    });
}
   var router = Router()
       ..mount("/about",staticHandler1)
       ..mount("/dashboard",staticHandler2)
       ..mount("/db",staticHandler3)
       ..mount('/images_file/',shelf_static.createStaticHandler('$hasil${sign1}images'))
       ..get('/dbnew',(Request request) async {
                var filenya=io.File('$hasil${sign1}template${sign1}daftarbukutemplate.tp').readAsStringSync();
                 String data=await readData();
                 return _render(filenya.replaceAll('[[content]]',data));
         })
       ..mount("/inputbuku",staticHandler4)
       ..post('/action_simpan',(Request request) async {
                final body=await request.readAsString();
                final queryParameters=Uri(query:body).queryParameters;
                final jbuku=queryParameters['jbuku'] ?? ''
                            ..trim();
                final pbuku=queryParameters['pbuku'] ?? ''
                            ..trim();
                final pnbuku=queryParameters['pnbuku'] ?? ''
                            ..trim();
                final sumary=queryParameters['summary'] ?? ''
                            ..trim();
                final hbuku=queryParameters['hbuku'] ?? ''
                            ..trim();
                final agbuku=queryParameters['agbuku'] ?? ''
                            ..trim();
                insertData(jbuku, pbuku, pnbuku, sumary, hbuku, agbuku);
                 return Response.found("/dbnew");
         })
       ..get('/viewEditData',(Request request) async {
                var filenya=io.File('$hasil${sign1}template${sign1}daftarbukutemplate.tp').readAsStringSync();
                 String data=await readDataEditDelete(1);
                 return _render(filenya.replaceAll('[[content]]',data));
         })
       ..get('/editData/<id>',(Request request, String id) async {
                var filenya=io.File('$hasil${sign1}template${sign1}inputbukue.tp').readAsStringSync();
                 String data=await readData1Record(id);
                 var datarec=data.trim().split(";");
                 return _render(filenya.replaceAll('{{v0}}','$id').replaceAll('{{v1}}','$datarec[0]').replaceAll('{{v2}}','$datarec[1]').replaceAll('{{v3}}','$datarec[2]').replaceAll('{{v4}}','$datarec[3]').replaceAll('{{v5}}','$datarec[4]').replaceAll('{{v6}}','$datarec[5]'));
         })
       ..post('/action_simpan_edit',(Request request) async {
                final body=await request.readAsString();
                final queryParameters=Uri(query:body).queryParameters;
                final idbuku=queryParameters['idbuku'] ?? ''
                            ..trim();
                final jbuku=queryParameters['jbuku'] ?? ''
                            ..trim();
                final pbuku=queryParameters['pbuku'] ?? ''
                            ..trim();
                final pnbuku=queryParameters['pnbuku'] ?? ''
                            ..trim();
                final sumary=queryParameters['summary'] ?? ''
                            ..trim();
                final hbuku=queryParameters['hbuku'] ?? ''
                            ..trim();
                final agbuku=queryParameters['agbuku'] ?? ''
                            ..trim();
                updateData(idbuku,jbuku, pbuku, pnbuku, sumary, hbuku, agbuku);
                 return Response.found("/dbnew");
         })
       ..get('/viewDeleteData',(Request request) async {
                var filenya=io.File('$hasil${sign1}template${sign1}daftarbukutemplate.tp').readAsStringSync();
                 String data=await readDataEditDelete(2);
                 return _render(filenya.replaceAll('[[content]]',data));
         })
       ..get('/deleteData/<id>',(Request request, String id) async {
                var filenya=io.File('$hasil${sign1}template${sign1}daftarbukutemplate.tp').readAsStringSync();
                 await deleteData(id);
                 return Response.ok("$id sudah dihapus <a href='/'>back to main</a>",headers:{'Content-type':'text/html; charset=UTF-8',});
         })

       ..mount("/",staticHandler0);

   final handler = Cascade().add(router).handler;

   final pipeline=const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(handler);

  final io.HttpServer server = await shelf_io.serve(pipeline, io.InternetAddress.anyIPv4, 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}
