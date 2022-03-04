import 'dart:async';
/**
 * IMPORTANTE
 * - Los campos que usen un input select deben usar el evento
 * change y este debe ir con un future
 *
 * - Los select multiple, deben tener una función que busque sus valores
 * y los asigne a la variable List, asi mismo deben tener una función que los
 * seleccione desde una variable List
 * heber.rodriguez+test@miaguila.com
 */
import 'dart:convert';
import 'dart:html';

import 'package:angular_router/angular_router.dart';
import 'package:angular/angular.dart';

import 'package:web_app/classes/User.dart';
import 'package:web_app/src/config.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../route_paths.dart';
import '../routes.dart';

@Component(
  selector: 'router-outlet',
  styleUrls: ['dashboard.css'],
  templateUrl: 'dashboard.html',
  directives: [ MenuTopComponent],
  providers: [AdminServices],
  exports: [RoutePaths, Routes]
)
class DashboardComponent {

  static Map xFiles = {'list': []};
  final AdminServices adminServices;
  final Router router;

  Map user = User.user;

  String Af;
  Config config = Config();
  Storage localStorage = window.localStorage;
  List<String> alliances_all = [];
  bool routes_active = false;

  DashboardComponent(this.router, this.adminServices) {
//    updateUser(_router);
    if (!User.user.containsKey('personal_info')) {
       router.navigate(RoutePaths.login.toUrl());
    } else {
      updateUser(router);
    }
  }

  Future updateUser(Router _router) async {
    await adminServices?.users?.get('me', {
      'return':
          'personal_info,alliance_id,type_user,email,balance,credit_card_id,costs_centers_ids,promo_code_id',
      'populate':
          'alliance_id:_id,info.type_payment,legal.name,alliance_father_id,routes_active|promo_code_id:active,description,expiration,activation,code'
    })?.then((request) {
      Future(() {
        localStorage['user'] = request.responseText;
        User.user = jsonDecode(localStorage['user']);
        if (User.user['alliance_id'].containsKey('alliance_father_id')) {
          if (User.user['alliance_id']['alliance_father_id'] != null) {
            Af = User.user['alliance_id']['alliance_father_id'];
            adminServices.alliances.query({'alliance_father_id': Af, 'return': 'legal'}).then(
                (request) {
              Map child_alliance = jsonDecode(request.responseText);
              alliances_all.add(Af);
              child_alliance['result'].forEach((a) {
                alliances_all.add(a['_id']);
              });
            }, onError: (e) {
              adminServices.evaluateError(e);
            });
          } else {
            Af = User.user['alliance_id']['_id'];
            adminServices.alliances.query({'alliance_father_id': Af, 'return': 'legal'}).then(
                (request) {
              Map child_alliance = jsonDecode(request.responseText);
              alliances_all.add(Af);
              child_alliance['result'].forEach((a) {
                alliances_all.add(a['_id']);
              });
            }, onError: (e) {
              adminServices.evaluateError(e);
            });
          }
        }
        routes_active = User.user['alliance_id']['routes_active'];
      });
    }, onError: (e) {
      User.token = '';
      User.user = {};

      localStorage.remove('token');
      localStorage.remove('user');

      _router.navigate(RoutePaths.login.toUrl());
    });
  }

}
