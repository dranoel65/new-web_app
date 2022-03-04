import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;

import 'package:angular/angular.dart';
import 'package:web_app/classes/User.dart';
import 'package:web_app/src/config.dart';

@Injectable()
class ModelService {
  Config config = Config();
  String model;

  ModelService(this.model);

  void show() {
    js.context.callMethod(r'$', ['.loader']).callMethod('show');
  }

  void hide() {
    js.context.callMethod(r'$', ['.loader']).callMethod('hide');
  }

  Future get(String id, [Map<String, dynamic> queryParameters, String extend = '']) {
    show();
    Uri uri = Uri(scheme: config.scheme,
        host: config.client_host,
        port: config.client_port,
        path: 'v1/client/${model}${extend}/${id}',
        queryParameters: queryParameters);
    var a = HttpRequest.request(uri.toString(), method: 'GET', requestHeaders: {'content-type': 'application/json', 'Authorization': 'bearer ' + User.token});
    a.then((request) {
      hide();
    }, onError: (e) {
      hide();
    });
    return a;
  }

  Future query([Map<String, dynamic> queryParameters]) {
    show();
    Uri uri = Uri(scheme: config.scheme,
        host: config.client_host,
        port: config.client_port,
        path: 'v1/client/$model',
        queryParameters: queryParameters);
    var a = HttpRequest.request(uri.toString(), method: 'GET', requestHeaders: {'content-type': 'application/json', 'Authorization': 'bearer ' + User.token});
    a.then((request) {
      hide();
    }, onError: (e) {
      hide();
    });
    return a;
  }

  Future post(Map form, [Map queryParameters]) {
    show();
    Uri uri = Uri(scheme: config.scheme,
        host: config.client_host,
        port: config.client_port,
        path: 'v1/client/$model',
        queryParameters: queryParameters);
    var a = HttpRequest.request(uri.toString(), method: 'POST', requestHeaders: {'content-type': 'application/json', 'Authorization': 'bearer ' + User.token}, sendData: jsonEncode(form));
    a.then((request) {
      hide();
    }, onError: (e) {
      hide();
    });
    return a;
  }

  Future postGet(String id, Map form, [Map queryParameters]) {
    show();
    Uri uri = Uri(scheme: config.scheme,
        host: config.client_host,
        port: config.client_port,
        path: 'v1/client/$model/$id',
        queryParameters: queryParameters);
    var a = HttpRequest.request(uri.toString(), method: 'POST', requestHeaders: {'content-type': 'application/json', 'Authorization': 'bearer ' + User.token}, sendData: jsonEncode(form));
    a.then((request) {
      hide();
    }, onError: (e) {
      hide();
    });
    return a;
  }

  Future put(String id, Map form, [Map queryParameters]) {
    show();
    Uri uri = Uri(scheme: config.scheme,
        host: config.client_host,
        port: config.client_port,
        path: 'v1/client/$model/$id',
        queryParameters: queryParameters);
    var a = HttpRequest.request(uri.toString(), method: 'PUT', requestHeaders: {'content-type': 'application/json', 'Authorization': 'bearer ' + User.token}, sendData: jsonEncode(form));
    a.then((request) {
      hide();
    }, onError: (e) {
      hide();
    });
    return a;
  }

  Future deactivate(String id) {
    show();
    Uri uri = Uri(scheme: config.scheme,
        host: config.client_host,
        port: config.client_port,
        path: 'v1/client/$model/$id');
    var a = HttpRequest.request(uri.toString(), method: 'DELETE', requestHeaders: {'content-type': 'application/json', 'Authorization': 'bearer ' + User.token});
    a.then((request) {
      hide();
    }, onError: (e) {
      hide();
    });
    return a;
  }

  Future activate(String id) {
    show();
    Uri uri = Uri(scheme: config.scheme,
        host: config.client_host,
        port: config.client_port,
        path: 'v1/client/activate/$model/$id');
    var a = HttpRequest.request(uri.toString(), method: 'PUT', requestHeaders: {'content-type': 'application/json', 'Authorization': 'bearer ' + User.token});
    a.then((request) {
      hide();
    }, onError: (e) {
      hide();
    });
    return a;
  }

  Future getSub([Map queryParameters, String extend = '']) {
    show();
    Uri uri = Uri(scheme: config.scheme,
        host: config.client_host,
        port: config.client_port,
        path: 'v1/client/$model$extend/',
        queryParameters: queryParameters);
    var a = HttpRequest.request(uri.toString(), method: 'GET', requestHeaders: {'content-type': 'application/json', 'Authorization': 'bearer ' + User.token});
    a.then((request) {
      hide();
    });
    return a;
  }

  Future excel([Map queryParameters, List<String> form]) {
    show();
    Uri uri = Uri(scheme: config.scheme,
        host: config.client_host,
        port: config.client_port,
        path: 'v1/client/trips/generate',
        queryParameters: queryParameters);
    var a = HttpRequest.request(uri.toString(), method: 'POST', requestHeaders: {'content-type': 'application/json', 'Authorization': 'bearer ' + User.token}, sendData: jsonEncode(form));
    a.then((request) {
      hide();
    }, onError: (e) {
      hide();
    });
    return a;
  }

  Future bulkUpdate(String field, Map form, [Map queryParameters]) {
    Uri uri = Uri(
        scheme: config.scheme,
        host: config.client_host,
        port: config.client_port,
        path: 'v1/client/$model/bulk-update/$field',
        queryParameters: queryParameters);

    return HttpRequest.request(uri.toString(),
        method: 'PUT',
        requestHeaders: {
          'content-type': 'application/json',
          'Authorization': 'bearer ' + User.token
        },
        sendData: jsonEncode(form));
  }

  Future uploadUsers(FormData form, [Map<String,dynamic> queryParameters]) {
    var path =  'v1/client/route/$model';

    Uri uri = Uri(
        scheme: config.scheme,
        host: config.client_host,
        port: config.client_port,
        path: path,
        queryParameters: queryParameters);
    return HttpRequest.request(uri.toString(),
        method: 'POST',
        requestHeaders: {
          'Authorization': 'bearer ' + User.token
        },
        sendData:form);
  }

  Future listActives([Map queryParameters, List<String> form]) {
    show();
    Uri uri = Uri(scheme: config.scheme,
        host: config.client_host,
        port: config.client_port,
        path: 'v1/client/trips/routes-generate',
        queryParameters: queryParameters);
    var a = HttpRequest.request(uri.toString(), method: 'POST', requestHeaders: {'content-type': 'application/json', 'Authorization': 'bearer ' + User.token}, sendData: jsonEncode(form));
    a.then((request) {
      hide();
    }, onError: (e) {
      hide();
    });
    return a;
  }

  Future scanMap(String field, [Map queryParameters, String extend = '']) {
    show();
    Uri uri = Uri(scheme: config.scheme,
        host: config.client_host,
        port: config.client_port,
        path: 'v2/client/services/$field',
        queryParameters: queryParameters);
    var a = HttpRequest.request(uri.toString(), method: 'GET', requestHeaders: {'content-type': 'application/json', 'Authorization': 'bearer ' + User.token});
    a.then((request) {
      hide();
    }, onError: (e) {
      hide();
    });
    return a;
  }

}
