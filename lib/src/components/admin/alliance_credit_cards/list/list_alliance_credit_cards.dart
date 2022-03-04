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
    selector: 'list-alliance-credit-cards',
    styleUrls: ['../style.css'],
    templateUrl: 'list_alliance_credit_cards.html',
    directives: [coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [GetErrorsPipe, IdPipe, DateFormatPipe, I18NPipe],
    exports: [RoutePaths, Routes])
class ListAllianceCreditCardsComponent extends AllianceCreditCardsComponent  implements OnInit {
  @override
  @Input('alliance_id')
  String alliance_id;

  bool processing = false;

  @override
  void ngOnInit() {
    getAllianceCreditCards();
  }


  String goToNewAllianceCreditCard(id) => RoutePaths.new_alliance_credit_card.toUrl(parameters: {idParam: id?? ''});
  String goToEditAllianceCreditCard(id) => RoutePaths.edit_alliance_credit_card.toUrl(parameters: {idParam: id});

  ListAllianceCreditCardsComponent(Router router, AdminServices adminServices) : super(router, adminServices);

  void getAllianceCreditCards() {
    adminServices.listAllianceCreditsCards({
      'alliance_id': alliance_id,
      'active': 'true',
      'return': '_id,number,name,type,is_blocked,verification,updatedAt,createdAt'
    }.cast<String,dynamic>());
  }

  void deactivate(credit_card) {
    itemModalError = false;
    itemModal = credit_card;
    js.context.callMethod(r'$', ['#modalDeactivate3']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  void selectModal(credit_card) {
    itemModalError = false;
    itemModal = credit_card;
    js.context.callMethod(r'$', ['#modalSelectCard']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  void verifyModal(credit_card) {
    itemModal = credit_card;
    js.context.callMethod(r'$', ['#modalVerification']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  void showVerification(Map credit_card) {
    itemModal = credit_card;
    js.context.callMethod(r'$', ['#showVerification']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  void remove(credit_card) {
//    List<Map> active_credits_cards = list_alliance_credits_cards.where((credit_card) => !credit_card['is_blocked']).toList();
//    active_credits_cards.remove(credit_card);
//    if (active_credits_cards.length == 0) {
//      itemModalError = true;
//      return;
//    }
    adminServices.alliance_credits_cards.deactivate(credit_card['_id']).then((request) {
      adminServices.list_alliance_credits_cards.remove(credit_card);
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
    js.context.callMethod(r'$', ['#modalDeactivate3']).callMethod(
        'modal', ['hide']);
    itemModalError2 = false;
    itemModalError = false;
  }

  void verify(credit_card) {
    processing = true;
    adminServices.alliance_credits_cards.put('verify/${credit_card['_id']}', {'return': 'is_blocked,verification'}.cast<String,dynamic>()).then((request) {
      Map<String,dynamic> data = jsonDecode(request.responseText);
      credit_card['is_blocked'] = data['is_blocked'];
      credit_card['verification'] = data['verification'];
      js.context.callMethod(r'$', ['#modalVerification']).callMethod(
          'modal', ['hide']);
      processing = false;
    }, onError: (e) {
      adminServices.evaluateError(e);
      js.context.callMethod(r'$', ['#modalVerification']).callMethod(
          'modal', ['hide']);
      processing = false;
    });
  }

  void select(credit_card) {
    if (credit_card['is_blocked']) {
      itemModalError = true;
      return;
    }
    js.context.callMethod(r'$', ['#modalSelectCard']).callMethod(
        'modal', ['hide']);
    itemModalError = false;
  }
  void searchCreditCard() {
    q ??= '';

    adminServices.listAllianceCreditsCards({
      'alliance_id': alliance_id,
      'number__like': q.trim(),
      'name__like': q.trim(),
      'type__like': q.trim().toUpperCase(),
      '_or': 'number,name,type',
      'active': 'true',
      'return': '_id,number,name,type,is_blocked,verification,updatedAt,createdAt'
    }.cast<String,dynamic>());
  }

}
