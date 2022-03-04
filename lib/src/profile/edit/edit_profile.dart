import 'dart:convert';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../profile.dart';
import '../../route_paths.dart';
import '../../routes.dart';

@Component(
    selector: 'edit-profile',
    styleUrls: ['../style.css'],
    templateUrl: 'edit_profile.html',
    directives: [coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    providers: [AdminServices],
    pipes: [ CurrencyPipe, GetErrorsPipe, IdPipe, I18NPipe],
    exports: [RoutePaths, Routes])
class EditProfileComponent extends ProfileComponent {
  Map<String,dynamic> user_view;
  Map<String,dynamic> err = {};
  // verificación de la contraseña, cuando se quiere cambiar
  String checkPass;

  String goToListTrips(key) => RoutePaths.list_trips.toUrl(parameters: {target: key});

  EditProfileComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    adminServices.users.get('me', {
      'return': 'alliance_id,costs_centers_ids,personal_info,active,email,type_user,balance,alliances',
      'populate': 'alliance_id:legal.name|costs_centers_ids:name,active,alliance_father_id'
    }.cast<String,dynamic>()).then((request) {
      user_view = jsonDecode(request.responseText);
    }, onError: (e) {
      adminServices.evaluateError(e);
    });

  }

  void clearError() {
    err={};
  }

  void save(){

    if (user_view.containsKey('password')&& checkPass!=user_view['password']){
      err = {'param':'check-password','title': 'Error ','errorMessage': 'las contraseñas no coinciden'};

    }else{
      if (user_view.containsKey('password_temp')){
        user_view['password_temp']='';
      }
      adminServices.users.put('me', user_view).then(
              (request) {
            Map data = jsonDecode(request.responseText);
            viewConfirmModal();
          }, onError: (e) {
        adminServices.evaluateError(e);
      });
    }

  }
  void viewConfirmModal() {
    js.context.callMethod(r'$', ['#confirmModal']).callMethod('modal', [
      js.JsObject.jsify({'show': true})
    ]);
  }
}
