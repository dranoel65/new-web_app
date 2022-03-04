import 'dart:js' as js;

import 'package:angular_router/angular_router.dart';

import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';

class TripsDetailsComponent extends DashboardComponent {
  bool processing = false;
  String q = '';
  String fi = '';
  String ff = '';
  String r = '';
  String c = '';
  String s = '';
  String year = '2017';
  List<Map> months = [
    { 'name': 'Mes', 'v': '00'},
    { 'name': 'Enero', 'v': '01'},
    { 'name': 'Febrero', 'v': '02'},
    { 'name': 'Marzo', 'v': '03'},
    { 'name': 'Abril', 'v': '04'},
    { 'name': 'Mayo', 'v': '05'},
    { 'name': 'Junio', 'v': '06'},
    { 'name': 'Julio', 'v': '07'},
    { 'name': 'Agosto', 'v': '08'},
    { 'name': 'Septiembre', 'v': '09'},
    { 'name': 'Octubre', 'v': '10'},
    { 'name': 'Noviembre', 'v': '11'},
    { 'name': 'Diciembre', 'v': '12'}
  ];


  TripsDetailsComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    var dateNow = DateTime.now();
    year = dateNow.year.toString();
  }

  int changeM(String m) {
    return js.context.callMethod('moment', ['${year}-${m}', 'YYYY-MM']).callMethod('daysInMonth');
  }

}
