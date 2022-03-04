import 'dart:convert';

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
    selector: 'edit-alliance-credit-card',
    styleUrls: ['../style.css'],
    templateUrl: 'edit_alliance_credit_card.html',
    directives: [coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [GetErrorsPipe, IdPipe, DateFormatPipe, I18NPipe],
    exports: [RoutePaths, Routes])
class EditAllianceCreditCardComponent extends AllianceCreditCardsComponent implements OnActivate {
  bool processing = false;

  @override
  void onActivate(_, RouterState current) {
    credit_card_id = current.parameters['id'];
    getAlliance();
    getAllianceCreditCard();
  }

  String goToAlliance(id) => RoutePaths.view_alliance.toUrl(parameters: {idParam: id});

  EditAllianceCreditCardComponent(Router router, AdminServices adminServices) : super(router, adminServices);

  void getAllianceCreditCard() {
    adminServices.alliance_credits_cards.get(credit_card_id, {'return': '_id,number,name,alliance_id'}.cast<String,dynamic>()).then((request) {
      credit_card = jsonDecode(request.responseText);
      alliance_id = credit_card['alliance_id'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void save() {
    processing = true;
    Map<String,dynamic> new_credit_card = Map.from(credit_card);
    new_credit_card['costs_centers'] = new_credit_card['costs_centers'].map((cc) => cc['_id']).toList();
//    new_credit_card['alliance_id'] = alliance_id;
    adminServices.alliance_credits_cards.put(credit_card['_id'], new_credit_card).then((request) {
      router.navigate(RoutePaths.view_alliance.toUrl(parameters: {idParam: alliance_view['_id']}));
    }, onError: (e) {
      adminServices.evaluateError(e);
      processing = false;
    });
  }
}
