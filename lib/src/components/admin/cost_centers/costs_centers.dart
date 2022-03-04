import 'dart:js' as js;

import 'package:angular_router/angular_router.dart';

import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';

class CostCentersComponent extends DashboardComponent {
  String q = '';
  Map<String,dynamic> item;
  String alliance_id;
  String cost_center_id;
  Map<String,dynamic> cost_center = {'alliance_father_id': null, 'budget': {}, 'tags': [], 'restrictions':[]};
  Map<String,dynamic> alliance_view = {'legal': {}};
  String xactive = '1';
  num n = 1;
  bool edit = false;
  List<dynamic> hours = [
    { 'name': '00', 'v': '00'},
    { 'name': '01', 'v': '01'},
    { 'name': '02', 'v': '02'},
    { 'name': '03', 'v': '03'},
    { 'name': '04', 'v': '04'},
    { 'name': '05', 'v': '05'},
    { 'name': '06', 'v': '06'},
    { 'name': '07', 'v': '07'},
    { 'name': '08', 'v': '08'},
    { 'name': '09', 'v': '09'},
    { 'name': '10', 'v': '10'},
    { 'name': '11', 'v': '11'},
    { 'name': '12', 'v': '12'},
    { 'name': '13', 'v': '13'},
    { 'name': '14', 'v': '14'},
    { 'name': '15', 'v': '15'},
    { 'name': '16', 'v': '16'},
    { 'name': '17', 'v': '17'},
    { 'name': '18', 'v': '18'},
    { 'name': '19', 'v': '19'},
    { 'name': '20', 'v': '20'},
    { 'name': '21', 'v': '21'},
    { 'name': '22', 'v': '22'},
    { 'name': '23', 'v': '23'},
  ];
  List<dynamic> hours2 = [];
  Map time = {'hour': null, 'minute': null};
  Map time2 = {'hour': null, 'minute': null};
  String start, end = '';
  String day = '0';
  String restrictions_error = '';
  bool er =false;

  CostCentersComponent(Router router, AdminServices adminServices) : super(router, adminServices);

  void add(){
    if(cost_center['restrictions']==null){
      cost_center['restrictions']=[];
    }
    if(time['hour']!=null && time['minute']!=null && time2['hour']!=null && time2['minute']!=null){
      if(int.parse(time['hour']) > int.parse(time2['hour'])){
        er=true;
        restrictions_error='La hora de inicio de la restricción siempre debe ser menor que la hora final.';
        return;
      }
      else{
        if((int.parse(time['minute']) >= int.parse(time2['minute'])) && (int.parse(time['hour']) == int.parse(time2['hour']))){
          er=true;
          restrictions_error='La hora de inicio de la restricción siempre debe ser menor que la hora final.';
          return;
        }
      }
    }

    if(time['hour']==null || time['minute']==null){
      time['minute']==null;
      time['hour']==null;
      start='00:00';
    }
    else{
      start=time['hour'].toString()+':'+time['minute'].toString();
    }
    if(time2['hour']==null || time2['minute']==null){
      time2['hour']==null;
      time2['minute']==null;
      end='23:59';
    }
    else{
      end=time2['hour'].toString()+':'+time2['minute'].toString();
    }
    cost_center['restrictions'].add({'day':int.parse(day),'start':start,'end':end});
    js.context.callMethod(r'$', ['#createRestrictionModal']).callMethod('modal', ['hide']);
  }

  void e_restrictions(){
    er = false;
  }

  void createRestrictionModal() {
    er = false;
    js.context.callMethod(r'$', ['#createRestrictionModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

}
