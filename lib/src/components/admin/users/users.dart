import 'dart:async';
import 'dart:html';
import 'dart:js' as js;
import 'dart:convert';
import 'dart:async';

import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular/angular.dart';

import 'package:web_app/services/model.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';

class UsersComponent extends DashboardComponent {
  Map<String,dynamic> m = {'all': '', 'firstname': '', 'lastname': ''};
  String q = '';
  Map<String,dynamic> itemModal;
  String alliance_id;
  bool itemModalError = false;
  bool itemModalError2 = false;
  Map<String,dynamic> alliance_view = {'legal': {}};
  Map<String,dynamic> user_view = {'personal_info': {}, 'costs_centers_ids': [], 'users_ids':[], 'type_user': 'user', 'alliance_id': {'legal': {}}, 'budget': {}, 'identification_document':{'type':'', 'number':''}, 'work_address':null};
  List usersForBulk=[];
  bool edit = false;
  String populate = 'country_id:name|alliance_father_id:legal.name';
  String str_return = '_id,legal,country_id,alliance_father_id,active,info,balance,budget,routes,identification_document';
  List<dynamic> alliance_favorites = [];
  Map<String,dynamic> address = {};
  bool canSharedTrips = false;
  String user_id;

  UsersComponent(Router router, AdminServices adminServices) : super(router, adminServices);

//  Future selectCostsCenters(Map item, String a) async {
  void selectCostsCenters(Map item) {

//    var count;
//    if(item['_id']=='all'){
//      Map s = {};
//      s['alliance_father_id__in']= alliances_all.join(',');
//      await costs_centers.get('count', {'alliance_father_id__in': alliances_all.join(',')}).then((request) {
//        Map data = jsonDecode(source)(request.responseText);
//        count=data['result'];
//      }, onError: (e) {
//        evaluateError(e);
//      });
//
//      for(num i = 0; i<=(count/20).ceil(); i++){
//        await listCostsCenters({'alliance_father_id__in': alliances_all.join(','), 'return':'name','_limit':'20','_page':i.toString()});
//        count.add(i);
//      }

//      List<Map> cost_center = list_costs_centers.where((cc) => cc['_id'] == item['_id']).toList();
//      if (cost_center.length == 0) {
//        user_view['costs_centers_ids'].add(item['_id']);
//      }

//      user_view['costs_centers_ids']=;
//    }
//    else{
      List<dynamic> cost_center = user_view['costs_centers_ids'].where((cc) => cc['_id'] == item['_id']).toList();
      if (cost_center.isEmpty) {
        user_view['costs_centers_ids'].add(item);
      }
//    }
  }

}
