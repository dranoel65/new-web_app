import 'dart:convert';

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../users.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(selector: 'view-user',
    styleUrls: ['../style.css'],
    templateUrl: 'view_user.html',
    directives: [
      coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [ CurrencyPipe, GetErrorsPipe, IdPipe, I18NPipe],
    exports: [RoutePaths, Routes])
class ViewUserComponent extends UsersComponent implements OnActivate {

  @override
  void onActivate(_, RouterState current) {
    user_id = current.parameters['id'];
    getUser();
  }

  String goToViewAlliance(id) => RoutePaths.view_alliance.toUrl(parameters: {idParam: id});
  String goToEditCostCenter(id) => RoutePaths.edit_cost_center.toUrl(parameters: {idParam: '$id'});
  String goToEditUser(id) => RoutePaths.edit_user.toUrl(parameters: {idParam: '$id'});
  String goToViewUser(id) => RoutePaths.view_user.toUrl(parameters: {idParam: '$id'});

  ViewUserComponent(Router router, AdminServices adminServices) : super(router, adminServices);

  void getUser() {
    adminServices.users.get(user_id, {
      'populate': 'alliance_id:legal.name|costs_centers_ids:name,active,alliance_father_id|users_ids:email,personal_info,active,type_user',
      'return': 'email,alliance_id,costs_centers_ids,personal_info,active,type_user,balance,budget,users_ids,routes,identification_document,work_address,can_share_trips'
    }.cast<String,dynamic>())
        .then((request) {
      user_view = jsonDecode(request.responseText);
      alliance_id = user_view['alliance_id']['_id'];

      if(!user_view.containsKey('budget')){
        user_view['budget'] = {'mount': 0, 'mount_alert': 0, 'block': false};
      }

    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }
}