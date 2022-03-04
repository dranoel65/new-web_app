import 'dart:convert';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../credits_cards.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(
    selector: 'list-personal-credit-cards',
    templateUrl: 'list_personal_credit_cards.html',
    directives: [coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [GetErrorsPipe, IdPipe, DateFormatPipe, I18NPipe],
    exports: [RoutePaths, Routes])
class ListPersonalCreditCardsComponent extends PersonalCreditCardsComponent implements OnActivate {
  bool processing = false;

  @override
  void onActivate(_, RouterState current) {
    user_id = current.parameters['id'];
  }

  String goToAddPersonalCreditCard(id) => RoutePaths.add_personal_credit_card.toUrl(parameters: {idParam: '$id'});

  ListPersonalCreditCardsComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    adminServices.listCreditsCards({
      'active': 'true',
      'return': '_id,number,type,is_blocked,verification,updatedAt,createdAt'
    });
  }

  void deactivate(Map credit_card) {
    itemModalError = false;
    itemModal = credit_card;
    js.context.callMethod(r'$', ['#modalDeactivate']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  void selectModal(Map credit_card) {
    itemModalError = false;
    itemModal = credit_card;
    js.context.callMethod(r'$', ['#modalSelectCard']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  void showVerification(Map credit_card) {
    itemModal = credit_card;
    adminServices.credits_cards.get(credit_card['_id'], {'return': '_id,verification'}).then((request) {
      Map data = jsonDecode(request.responseText);
      itemModal['verification'] = data['verification'];
      js.context.callMethod(r'$', ['#showVerification']).callMethod(
          'modal', [js.JsObject.jsify({'show': true})]);
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void remove(credit_card) {
    List<Map> active_credits_cards = adminServices.list_credits_cards.where((credit_card) => !credit_card['is_blocked']).toList();
    active_credits_cards.remove(credit_card);
    if (active_credits_cards.isEmpty) {
      itemModalError = true;
      return;
    }
    adminServices.credits_cards.deactivate(credit_card['_id']).then((request) {
      adminServices.list_credits_cards.remove(credit_card);
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
    js.context.callMethod(r'$', ['#modalDeactivate']).callMethod(
        'modal', ['hide']);
    itemModalError2 = false;
    itemModalError = false;
  }

  void select(credit_card) {
    processing = true;
    if (credit_card['is_blocked']) {
      itemModalError = true;
      return;
    }
    adminServices.credits_cards.put('select/${credit_card['_id']}', {}).then((request) {
      Map data = jsonDecode(request.responseText);
      if (data['selected']) {
        user['credit_card_id'] = credit_card['_id'];
      } else {
        credit_card['is_blocked'] = true;
      }
      processing = false;
      js.context.callMethod(r'$', ['#modalSelectCard']).callMethod(
          'modal', ['hide']);
      itemModalError = false;
    }, onError: (e) {
      adminServices.evaluateError(e);
      processing = false;
      js.context.callMethod(r'$', ['#modalSelectCard']).callMethod(
          'modal', ['hide']);
      itemModalError = false;
    });
  }

  void searchCreditCard() {
    q ??= '';
    adminServices.listCreditsCards({
      'number__like': q.trim(),
      'type__like': q.trim().toUpperCase(),
      '_or': 'number,type',
      'active': 'true',
      'return': '_id,number,type,is_blocked,verification,updatedAt,createdAt'
    }.cast<String,dynamic>());
  }

}

