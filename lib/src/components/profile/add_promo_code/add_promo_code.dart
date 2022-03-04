import 'dart:convert';
import 'dart:html' hide Point, Events;
import 'dart:js' as js;
import 'dart:async';

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';
import 'package:web_app/src/menu_top/menu_top.dart';


@Component(selector: 'add-promo-code',
    styleUrls: ['style.css'],
    templateUrl: 'add_promo_code.html',
    directives: [ coreDirectives, formDirectives, MenuTopComponent],
    pipes: [
      GetErrorsPipe,
      IdPipe,
      NamePipe,
      CarBrandPipe,
      DateFormatPipe,
      MoneyPipe,
      I18NPipe
    ])
class AddPromoCodeComponent extends DashboardComponent {
  String code = '';
  String description = '';
  String expiration = '';
  bool err = false;

  AddPromoCodeComponent(Router router, AdminServices adminServices) : super(null, adminServices) {
    if(user['promo_code_id']!=null) {
      if(user['promo_code_id']['active']) {
        code = user['promo_code_id']['code'];
        description = user['promo_code_id']['description'];
        expiration = js.context.callMethod(
            'moment', [user['promo_code_id']['expiration']]).callMethod(
            'format', ['LLL']);
      }
    }
  }

  Future addPromoCode() async{
    if(code!='') {
      await adminServices.promos.put(code, {}).then((request) {
        Map promo = jsonDecode(request.responseText);
        update();
      }, onError: (e) {
        err=true;
        adminServices.evaluateError(e);
      });
    }

  }

  void change() {
    err = false;
  }

  Future update() async {
    await adminServices.listUsers({'_id':user['_id'],
      'return': 'personal_info,alliance_id,type_user,email,balance,credit_card_id,costs_centers_ids,promo_code_id',
      'populate': 'alliance_id:_id,info.type_payment,legal.name|promo_code_id:active,description,expiration,activation,code'
     }.cast<String,dynamic>()).then((request) {
       if(adminServices.list_users.isNotEmpty) {
         activateModal();
         code = adminServices.list_users[0]['promo_code_id']['code'];
         description = adminServices.list_users[0]['promo_code_id']['description'];
         expiration = js.context.callMethod('moment', [adminServices.list_users[0]['promo_code_id']['expiration']]).callMethod('format', ['LLL']);
       }
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void activateModal() {
    js.context.callMethod(r'$', ['#confirmModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

}
