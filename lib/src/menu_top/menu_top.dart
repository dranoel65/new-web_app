import 'dart:html';

import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular/angular.dart';

import 'package:web_app/classes/User.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';

import '../route_paths.dart';
import '../routes.dart';

@Component(
    selector: 'sel-menu_top',
    templateUrl: 'menu_top.html',
    styleUrls: ['menu_top.css'],
    pipes: [CurrencyPipe],
    directives: [coreDirectives, routerDirectives, formDirectives],
    exports: [RoutePaths, Routes]
    )
class MenuTopComponent extends DashboardComponent {
  Map user = User.user;
  Storage localStorage = window.localStorage;
  String me = User.user['type_user'];

  String goToListPersonalCreditCards(key) => RoutePaths.list_personal_credit_cards.toUrl(parameters: {target: key});
  String goToListTrips(key) => RoutePaths.list_trips.toUrl(parameters: {target: key});

  MenuTopComponent(Router router, AdminServices adminServices) : super(router, adminServices) {}

  void logoutBtn() {
    User.token = '';
    User.user = {};

    localStorage.remove('token');
    localStorage.remove('user');

    router.navigate(RoutePaths.login.toUrl());
  }
}

@Component(
    selector: 'login-out',
    templateUrl: 'login_out.html',
    styleUrls: ['menu_top.css'],
    directives: [],
    )
class LoginOutComponent extends DashboardComponent {
  Map user = User.user;
  Storage localStorage = window.localStorage;
  String me = User.user['type_user'];

  LoginOutComponent(Router router, AdminServices adminServices) : super(null, null) {
    logoutBtn();
  }

  void logoutBtn() {
    User.token = '';
    User.user = {};

    localStorage.remove('token');
    localStorage.remove('user');

//    router.navigate(['Login', {}]);
  }
}
