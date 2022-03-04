import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:web_app/classes/pipes.dart';

import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../users.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(selector: 'list-users',
    styleUrls: ['../style.css'],
    templateUrl: 'list_users.html',
    directives: [
      coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [ CurrencyPipe, GetErrorsPipe, IdPipe, I18NPipe],
    exports: [RoutePaths, Routes])
class ListUsersComponent extends UsersComponent implements OnInit{

  @Input('alliance_id')
  String alliance_id;

  String type_user = '';
  String active = '1';
  String errorCargar = '';
  String costcenter_q = '';
  bool show_all = false;
  bool flagSuccess = false;
  Map<String,dynamic> alliance = {};
  Map<String,dynamic> costcenter_item = {};
//  List <Map>  costs_centers_list = [];
  num n = 1;

  String goToAlliance(id) => RoutePaths.view_alliance.toUrl(parameters: {idParam: id});
  String goToNewUser(id) => RoutePaths.new_user.toUrl(parameters: {idParam: '$id'});
  String goToViewUser(id) => RoutePaths.view_user.toUrl(parameters: {idParam: '$id'});

  ListUsersComponent(Router router, AdminServices adminServices) : super(router, adminServices);

  @override
  void ngOnInit() {
    searchUsers(1);
    adminServices.listAlliances({'populate': populate, 'return': str_return}.cast<String,dynamic>());
  }

  void addUserForBulk(String id){
    if(usersForBulk.indexOf(id)<0){
      usersForBulk.add(id);
    }else{
      usersForBulk.remove(id);
    }
  }

  Future bulkUpdate() async{
    Map<String,dynamic> body={'alliance_id':alliance['_id']};
    Map<String,dynamic> query = {
      '_id__in': usersForBulk.join(","),
      '_or': 'email,_id'
    };
    await  adminServices.users.bulkUpdate('alliance', body,query).then((request) {
      Map<String,dynamic> data = jsonDecode(request.responseText);
      if (data['result'].isNotEmpty){
        flagSuccess=true;
        js.context.callMethod(r'$', ['#susessAlert']).callMethod('show');
      }else{
        errorCargar='No se actualizaron registros';
        js.context.callMethod(r'$', ['#errorAlert']).callMethod('show');
      }
      window.scrollTo(0,0);
    }, onError:(e){
      adminServices.evaluateError(e);
    });

  }

  void setTypeUser() {
//    Future(() {
//      switch (who) {
//        case 'me':
//          resetGuest();
//          resetCostCenter();
//          break;
//        case 'guest':
//          resetPassenger();
//          resetCostCenter();
//          break;
//        case 'users':
//          resetGuest();
//          resetCostCenter();
//          selectPassengerModal();
//          break;
//      }
//    });
  }

  void searchUsers(num nn) {
    n = nn;
    Map<String,dynamic> s = {
      'populate': 'alliance_id:legal.name|costs_centers_ids:name,active,tags',
      'return': 'email,alliance_id,costs_centers_ids,personal_info,active,type_user,balance,budget',
      '_page': n.toString(),
      '_sort': 'personal_info.lastname'
    };
    if(costcenter_item['_id']=='all'){
      s['costs_centers_ids__in']='null';
    }
    else if(costcenter_item.isNotEmpty){
      s['costs_centers_ids__in']=costcenter_item['_id'];
    }
    if(alliance_id!=null){
      s['alliance_id'] = alliance_id;
    }
    else{
      //s['alliance_id']=Af;
    }
    if (m['firstname'] != '') {
      s['personal_info.firstname__like'] = m['firstname'].replaceAll(RegExp(r' '), '|');
    }
    if (m['lastname'] != '') {
      s['personal_info.lastname__like'] = m['lastname'].replaceAll(RegExp(r' '), '|');
    }
    if (m['all'] != '') {
      s['personal_info.phone__like'] = m['all'].trim();
      s['email__like'] = m['all'].trim();
      s['_id__likeid'] = m['all'].trim();
      s['identification_document.number__like'] = m['all'].trim();
      s['_or'] = 'personal_info.firstname,personal_info.lastname,personal_info.phone,email,_id,identification_document.number';

    }
    if (type_user != '') {
      s['type_user'] = type_user;
    }
    if (active != '') {
      s['active'] = active;
    }

    adminServices.listUsers(s);
  }

  void deactivateModal(Map item) {
    itemModal = item;
    js.context.callMethod(r'$', ['#modalDeactivate2']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  void activateModal(Map item) {
    itemModal = item;
    js.context.callMethod(r'$', ['#modalActivate2']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  void deactivate(user_id) {
    adminServices.users.deactivate(user_id).then((request) {
      searchUsers(n);
    }, onError: (e) {
      adminServices.evaluateError(e);
    });

    js.context.callMethod(r'$', ['#modalDeactivate2']).callMethod('modal', ['hide']);
  }

  void activate(user_id) {
    adminServices.users.activate(user_id).then((request) {
      searchUsers(n);
    }, onError: (e) {
      adminServices.evaluateError(e);
    });

    js.context.callMethod(r'$', ['#modalActivate2']).callMethod('modal', ['hide']);
  }

  void searchCostCenter() {
    adminServices.costs_centers.query(
        {
          'alliance_father_id':Af,
          'name__like': costcenter_q,
          'populate': 'alliance_father_id:legal.name',
          '_or': '_id, name'
        }.cast<String,dynamic>()).then((request) {
      Map<String,dynamic> data = jsonDecode(request.responseText);
      adminServices.list_costs_centers = data['result'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void selectItem([item]) {
    costcenter_item = item;
    js.context.callMethod(r'$', ['#CostCenterModal']).callMethod('modal', ['hide']);
  }

  void deleteThis(String a) {
    costcenter_item = {};
  }

  void selectCostCenterModal2() {
    searchCostCenter();
    js.context.callMethod(r'$', ['#CostCenterModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

}
