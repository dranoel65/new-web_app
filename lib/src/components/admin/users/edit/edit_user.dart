import 'dart:convert';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';
import 'package:web_app/src/route_paths.dart';

import '../users.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(selector: 'edit-user',
    styleUrls: ['../style.css'],
    templateUrl: 'edit_user.html',
    directives: [coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [ GetErrorsPipe, IdPipe, NamePipe, I18NPipe],
    exports: [RoutePaths, Routes])
class EditUserComponent extends UsersComponent implements OnActivate {
  String u = '';
  Map address_delete = {};

  @override
  void onActivate(_, RouterState current) {
    user_id = current.parameters['id'];
    getUser();
  }

  String goToAddPersonalAddress(id) => RoutePaths.add_personal_address.toUrl(parameters: {idParam: '$id'});
  String goToViewAlliance(id) => RoutePaths.view_alliance.toUrl(parameters: {idParam: id});

  EditUserComponent(Router router, AdminServices adminServices) : super(router, adminServices);

  void getUser() {
    adminServices.users.get(user_id, {
      'populate': 'alliance_id:legal.name,can_share_trips|costs_centers_ids:name,active,alliance_father_id,tags|users_ids:email,personal_info,active',
      'return': 'email,alliance_id,costs_centers_ids,users_ids,personal_info,type_user,balance,active,budget,routes,identification_document,work_address,can_share_trips'
    }.cast<String,dynamic>())
        .then((request) {
      user_view = jsonDecode(request.responseText);
      canSharedTrips = user_view['alliance_id']['can_share_trips'];
      address=user_view['work_address'];
      address ??= {'address':null, 'name':null, 'position':null};

      alliance_id = user_view['alliance_id']['_id'];
      adminServices.listAreaCodes();
      if (user_view['costs_centers_ids'] == null) {
        user_view['costs_centers_ids'] = [];
      }
      if (user_view['users_ids'] == null) {
        user_view['users_ids'] = [];
      }
      if(!user_view.containsKey('budget')){
        user_view['budget'] = {'mount': 0, 'mount_alert': 0, 'block': false};
      }
      if (user_view['identification_document'] == null){
        user_view['identification_document']={'type':'', 'number':''};
      }
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void selectCostCenterModal() {
    q = '';
    searchCostsCenters();
    js.context.callMethod(r'$', ['#selectCostCenterModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  void searchCostsCenters() {
    adminServices.costs_centers.get('for-user/$user_id',
        {
          'active': 'true',
          'name__like': q.trim(),
          '_limit': '500',
          'return': 'name,active,alliance_father_id,tags',
          'populate': 'alliance_father_id:legal.name',
          '_sort': 'name'
        }.cast<String,dynamic>()).then((request) {
      Map<String,dynamic> data = jsonDecode(request.responseText);
      adminServices.list_costs_centers = data['result'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void selectUserModal() {
    u = '';
    searchUsers();
    js.context.callMethod(r'$', ['#selectUserModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  void searchUsers() {
    Map<String,dynamic> s = {
      'alliance_id__in': alliances_all.join(','),
      'return': 'email,personal_info,active',
      '_or': 'personal_info.firstname,personal_info.lastname,personal_info.phone,email,_id',
      '_sort': 'personal_info.lastname'
    };
    if (u != '') {
      s['personal_info.firstname__like'] = u.trim();
      s['personal_info.lastname__like'] = u.trim();
      s['personal_info.phone__like'] = u.trim();
      s['email__like'] = u.trim();
      s['_id__likeid'] = u.trim();
    }

    adminServices.listUsers(s);
  }

  void selectUsers(Map item) {
    List<dynamic> data_users = user_view['users_ids'].where((uu) => uu['_id'] == item['_id']).toList();
    if (data_users.isEmpty) {
      user_view['users_ids'].add(item);
    }
  }

  void searchFavorites(){
    Map<String,dynamic> dat = {'alliance_id': user['alliance_id']['_id'], 'active': 'true',
      'return': 'name,start.position,start,end,alliance_id'};

    adminServices.favorites.query(dat).then((request) {
      Map data = jsonDecode(request.responseText);
      alliance_favorites = data['result'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void selectWorkAddressModal() {
    searchFavorites();
    js.context.callMethod(r'$', ['#selectWorkAddressModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  void selectWorkAddress(item_address){
    address = Map.from(item_address);
    address={'address':address['start']['address'], 'name':address['name'], 'position':address['start']['position']};
  }

  void save() {
    if(address['position']==null){
      address={'address':null, 'name':null, 'position':null};
    }
    user_view['work_address']=address;
    Map new_user = Map.from(user_view);
    new_user['costs_centers_ids'] = new_user['costs_centers_ids'].map((cc) => cc['_id']).toList();
    new_user['users_ids'] = new_user['users_ids'].map((cc) => cc['_id']).toList();
    new_user['can_share_trips'] = canSharedTrips ? new_user['can_share_trips'] : false;

    adminServices.users.put(user_id, new_user).then((request) {
      router.navigate(RoutePaths.view_user.toUrl(parameters: {idParam: '$user_id'}));
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void delete_address(item_delete) {
    address_delete=item_delete;
    js.context.callMethod(r'$', ['#modalDelete']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  void delete() {
    user_view['routes'].remove(address_delete);
    adminServices.users.put('${user_view['_id']}/routes',{'routes':user_view['routes']}).then((request) {
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
    js.context.callMethod(r'$', ['#modalDelete']).callMethod('modal', ['hide']);
  }
}
