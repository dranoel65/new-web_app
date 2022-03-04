import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:web_app/services/services.dart';

import '../profile.dart';
import '../../route_paths.dart';
import '../../routes.dart';

@Component(
    selector: 'recovery-profile',
    templateUrl: 'recovery_profile.html',
    directives: [ coreDirectives, formDirectives, routerDirectives ],
    providers: [AdminServices],
    exports: [RoutePaths, Routes])
class RecoveryPasswordProfileComponent extends ProfileComponent implements OnActivate {

  @override
  void onActivate(_, RouterState current) {
    login['email'] = current.parameters['target'] == 'null' ? '' : current.parameters['target'];
  }

  RecoveryPasswordProfileComponent(Router router, AdminServices adminServices) : super(router, adminServices);

  void resetPassword() {

    Uri uri = Uri(
        scheme: config.scheme,
        host: config.client_host,
        port: config.client_port,
        path: 'v1/client/users/reset-password',
        queryParameters: {'email':login['email'],'sms':login['sms'].toString()}.cast<String,dynamic>()
        );

    HttpRequest.request(uri.toString(),
        method: 'GET',
        requestHeaders: {'content-type': 'application/json'}
        ).then((request){
      Map<String,dynamic> data = jsonDecode(request.responseText);
      errors = {};
      viewConfirmModal();
    }, onError: (e) {
      errors = {};

      HttpRequest request = e.target;
      if (request.status == 400) {
        errors['recovery'] = jsonDecode(request.responseText);
      } else if (request.status == 401) {
        errors['recovery'] = jsonDecode(request.responseText);
      } else if (request.status == 404) {
        errors['recovery'] = {
          'title': 'Error ' + request.status.toString(),
          'errorMessage': 'El correo no está asociado a ningún registro'
        };
      }
      else {
        errors['recovery'] = {
          'title': 'Error ' + request.status.toString(),
          'errorMessage': request.responseText
        };
      }

    });
  }

  void viewConfirmModal() {
    js.context.callMethod(r'$', ['#confirmModal']).callMethod('modal', [
      js.JsObject.jsify({'show': true})
    ]);
  }
}
