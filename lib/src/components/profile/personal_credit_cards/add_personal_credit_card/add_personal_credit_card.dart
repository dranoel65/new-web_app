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
    selector: 'add-personal-credit-card',
    templateUrl: 'add_personal_credit_card.html',
    directives: [coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [GetErrorsPipe, IdPipe, I18NPipe],
    exports: [RoutePaths, Routes])
class AddPersonalCreditCardComponent extends PersonalCreditCardsComponent implements OnActivate {

  List years = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13].map((i) {
    return js.context.callMethod('moment', []).callMethod('add', [i, 'years']).callMethod('format', ['YYYY']).toString();
  }).toList();
  List<Map> months = [
    {'name': 'Enero', 'value': '01'},
    {'name': 'Febrero', 'value': '02'},
    {'name': 'Marzo', 'value': '03'},
    {'name': 'Abril', 'value': '04'},
    {'name': 'Mayo', 'value': '05'},
    {'name': 'Junio', 'value': '06'},
    {'name': 'Julio', 'value': '07'},
    {'name': 'Agosto', 'value': '08'},
    {'name': 'Septiembre', 'value': '09'},
    {'name': 'Octubre', 'value': '10'},
    {'name': 'Noviembre', 'value': '11'},
    {'name': 'Diciembre', 'value': '12'}
  ];
  bool processing = false;

  @override
  void onActivate(_, RouterState current) {
    user_id = current.parameters['id'];
  }

  String goToListPersonalCreditCards(id) => RoutePaths.list_personal_credit_cards.toUrl(parameters: {idParam: '$id'});

  AddPersonalCreditCardComponent(Router router, AdminServices adminServices) : super(router, adminServices);

  void save() {
    processing = true;
    Map<String,dynamic> new_credit_card = Map.from(credit_card);
    if (new_credit_card['number'] != null) {
      new_credit_card['number'] = new_credit_card['number'].replaceAll(RegExp(r'(\s+)'), '');
    }
    adminServices.credits_cards.post(new_credit_card).then((request) {
//      router.navigate(['PersonalCreditsCardsList', {'user_id': user_id}]);
    }, onError: (e) {
      adminServices.evaluateError(e);
      processing = false;
    });
  }

}