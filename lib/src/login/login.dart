import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;
import 'dart:math';

import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular/angular.dart';

import 'package:web_app/src/config.dart';
import 'package:web_app/classes/User.dart';

import '../route_paths.dart';
import '../routes.dart';

@Component(
    selector: 'login',
    styleUrls: ['login.css'],
    templateUrl: 'login.html',
    directives: [ coreDirectives, routerDirectives, formDirectives],
    exports: [RoutePaths, Routes]
)
class LoginComponent {
  Map login = {'email': '', 'password': '', 'fcm_id': 'x', 'device_id': '', 'device_type': 'web'};
  Map errors = {};
  String msg_error = '';

  Config config = Config();
  Router router;
  Storage localStorage = window.localStorage;

  String goToRecoveryPassword(key) => RoutePaths.recovery_password.toUrl(parameters: {target: key == '' ? 'null' : key});

  LoginComponent(this.router) {
    if (!localStorage.containsKey('device_id')) {
      var rng = Random();
      localStorage['device_id'] = 'web-' + rng.nextInt(10000).toString() + '-' + rng.nextInt(10000).toString();
    }
    if (User.user.containsKey('personal_info')) {
      router.navigate(RoutePaths.new_trip.toUrl());
    }
    hide();
  }

  void show() {
    js.context.callMethod(r'$', ['.loader']).callMethod('show');
  }

  void hide() {
    js.context.callMethod(r'$', ['.loader']).callMethod('hide');
  }

  void loginBtn() {
    show();
    Uri uri = Uri(scheme: config.scheme,
        host: config.client_host,
        port: config.client_port,
        path: 'v1/client/login',
        queryParameters: {'return': '_id,personal_info,type_user,active,password_restore,swap,balance,access,admin,alliance_id,email,credit_card_id,costs_centers_ids',
          'populate': 'alliance_id:_id,info.type_payment,legal.name'});

    login['device_id'] = localStorage['device_id'];
    login['password_temp'] = login['password'];

    HttpRequest.request(uri.toString(), method: 'POST', requestHeaders: {'content-type': 'application/json'}, sendData: jsonEncode(login)).then((request) {
      Map data = jsonDecode(request.responseText);
      if (!data.containsKey('user')) {
        //error
      } else {
        User.token = data['token'];
        User.user = data['user'];

        localStorage['token'] = data['token'];
        localStorage['user'] = jsonEncode(data['user']);

        router.navigate(RoutePaths.new_trip.toUrl());
      }
      hide();
    }, onError: (e) {
      HttpRequest request = e.target;
      showErros(jsonDecode(request.responseText));
      hide();
    });
  }

  void showErros(var e) {
    errors = {};
    switch (e['title']) {
      case 'EmailOrPasswordNotValid':
        msg_error = 'Correo o contraseña incorrecta';
        break;
      case 'notFound':
        msg_error = 'Usuario no registrado';
        break;
      default:
        msg_error = 'Correo o contraseña incorrecta';
    }
    errors['login'] = {'title': msg_error, 'errorMessage': ''};
  }

  void passwordRestored() {
    show();
    Uri uri = Uri(scheme: config.scheme,
        host: config.client_host,
        port: config.client_port,
        path: 'v1/client/users/exists',
        queryParameters: {'email': login['email']});

    HttpRequest.request(uri.toString(), method: 'GET', requestHeaders: {'content-type': 'application/json'}).then((request) {
      Map data = jsonDecode(request.responseText);
      if (data['result'][0]['password_restore'] == null || data['result'][0]['password_restore'] == false) {
        viewConfirmModal();
      } else {
        loginBtn();
      }
      hide();
    }, onError: (e) {
      HttpRequest request = e.target;
      showErros(jsonDecode(request.responseText));
      hide();
    });
  }

  void viewConfirmModal() {
    js.context.callMethod(r'$', ['#confirmModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }
}
