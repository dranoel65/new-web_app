import 'dart:convert';
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

@Component(selector: 'new-user',
    styleUrls: ['../style.css'],
    templateUrl: 'new_user.html',
    directives: [coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [GetErrorsPipe, IdPipe, I18NPipe, NamePipe],
    exports: [RoutePaths, Routes])
class NewUserComponent extends UsersComponent implements OnActivate {
  String u = '';

  @override
  void onActivate(_, RouterState current) {
    alliance_id = current.parameters['id'];
    getAlliance();
  }

  String goToViewAlliance(id) => RoutePaths.view_alliance.toUrl(parameters: {idParam: id});

  NewUserComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    adminServices.listAreaCodes();
  }

  void getAlliance() {
    adminServices.alliances.get(alliance_id, {'return': 'legal,can_share_trips'}.cast<String,dynamic>()).then((request) {
      alliance_view = jsonDecode(request.responseText);
      canSharedTrips = alliance_view['can_share_trips'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void save() {
    user_view['alliance_id'] = alliance_id;
    Map<String,dynamic> new_user = Map.from(user_view);
    new_user['costs_centers_ids'] = new_user['costs_centers_ids'].map((cc) => cc['_id']).toList();
    new_user['users_ids'] = new_user['users_ids'].map((cc) => cc['_id']).toList();
    new_user['can_share_trips'] = canSharedTrips ? new_user['can_share_trips'] : false;

    adminServices.users.post(new_user).then((request) {
      router.navigate(RoutePaths.view_alliance.toUrl(parameters: {idParam: alliance_id}));
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void selectCostCenterModal() {
    q = '';
    searchCostsCenters();
    js.context.callMethod(r'$', ['#selectCostCenterModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
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
    List <Map> data_users = user_view['users_ids'].where((uu) => uu['_id'] == item['_id']).toList();
    if (data_users.isEmpty) {
      user_view['users_ids'].add(item);
    }
  }

  void searchCostsCenters() {
    adminServices.costs_centers.query(
        {
          'alliance_father_id__in':alliances_all.join(','),
          'active': 'true',
          'name__like': q,
          '_limit': '500',
          'return': 'name,active,alliance_father_id',
          'populate': 'alliance_father_id:legal.name',
          '_sort': 'name'
        }.cast<String,dynamic>()).then((request) {
      Map data = jsonDecode(request.responseText);
      adminServices.list_costs_centers = data['result'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void searchFavorites(){
    Map<String,dynamic> dat = {'alliance_id': user['alliance_id']['_id'], 'user_id': user['_id'], 'active': 'true',
      'return': 'name,start.position,start,end,alliance_id', '_or':'alliance_id,user_id'};

    if (q!=''){
      dat['name__like']=q;
    }
    adminServices.favorites.query(dat).then((request) {
      Map data = jsonDecode(request.responseText);
      alliance_favorites = data['result'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void selectWorkAddressModal() {
    q = '';
    searchFavorites();
    js.context.callMethod(r'$', ['#selectWorkAddressModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  void selectWorkAddress(item_address){
  }

}
