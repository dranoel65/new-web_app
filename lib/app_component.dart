import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js';

import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular/angular.dart';
//import 'package:web_app/components/dashboard/admin/statistics/costs_centers/costs_centers.dart';
//import 'package:web_app/components/dashboard/admin/statistics/service_levels/service_levels.dart';
//import 'package:web_app/components/dashboard/admin/reports/reports.dart';
//import 'package:web_app/components/dashboard/admin/statistics/users/users.dart';
//import 'package:web_app/components/dashboard/dashboard.dart';
//import 'package:web_app/components/dashboard/admin/alliances/overview/sub_alliances.dart';
//import 'package:web_app/components/dashboard/admin/alliances/overview/users.dart';
//import 'package:web_app/components/dashboard/admin/alliances/alliances.dart';
//import 'package:web_app/components/dashboard/admin/users/users.dart';
//import 'package:web_app/components/dashboard/admin/favorites/favorites.dart';
//import 'package:web_app/components/dashboard/admin/credits_cards/credits_cards.dart';
//import 'package:web_app/components/dashboard/admin/costs_centers/costs_centers.dart';
//import 'package:web_app/components/dashboard/profile/favorites/favorites.dart';
//import 'package:web_app/components/dashboard/profile/histories/histories.dart';
//import 'package:web_app/components/dashboard/profile/payments/payments.dart';
//import 'package:web_app/components/dashboard/profile/fares/fares.dart';
//import 'package:web_app/components/dashboard/profile/promo_codes/promo_codes.dart';
//import 'package:web_app/components/dashboard/services/trips/trips.dart';
//import 'package:web_app/components/dashboard/services/routes/massive_routes.dart';
//import 'package:web_app/components/login/login.dart';
//import 'package:web_app/components/dashboard/profile/personal/profile.dart';
//import 'package:web_app/components/dashboard/profile/payments_methods/credits_cards/credits_cards.dart';
import 'package:web_app/classes/User.dart';
import 'package:web_app/services/services.dart';
//import 'package:web_app/components/menu_top/menu_top.dart';
import 'package:web_app/src/config.dart';
import 'package:web_app/services/model.dart';
import 'package:web_app/src/routes.dart';
import 'package:web_app/src/route_paths.dart';


@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [coreDirectives, routerDirectives, formDirectives],
  providers: [AdminServices],
  exports: [RoutePaths, Routes],
)

class AppComponent {
  final Router _router;
  Storage localStorage = window.localStorage;
  Config config = Config();
  ModelService users = ModelService('users');
  final AdminServices adminServices;

  Future updateUser(){
    return users.get('me', {'return': 'personal_info,alliance_id,type_user,email,balance,credit_card_id,costs_centers_ids'});
  }

  AppComponent(this._router, this.adminServices) {
    //locale a moment
    context['moment'].callMethod('locale', ['es']);
    //actualiza los datos del usuario

    //mira si hay una sesión para el usuario
    if (localStorage.containsKey('token')) {
      User.token = localStorage['token'];
    }
    if (localStorage.containsKey('user')) {
      User.user = jsonDecode(localStorage['user']);
    }

//    if (!User.user.containsKey('profile')) {
    if (!User.user.containsKey('personal_info')) {
      _router.navigate(RoutePaths.login.toUrl());
    } else {
//      var news = updateUser();

//      news.then((request) {
      users.get('me', {
        'return':
        'personal_info,alliance_id,type_user,email,balance,credit_card_id,costs_centers_ids'
      }).then((request) {
        Future(() {
          localStorage['user'] = request.responseText;
          User.user = jsonDecode(localStorage['user']);

          _router.navigate(RoutePaths.new_trip.toUrl());
//          _router.navigate(RoutePaths.test.toUrl());
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
}


