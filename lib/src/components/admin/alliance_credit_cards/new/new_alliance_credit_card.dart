import 'dart:convert';
import 'dart:js' as js;

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:web_app/classes/pipes.dart';

import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../credits_cards.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(
    selector: 'new-alliance-credit-card',
    styleUrls: ['../style.css'],
    templateUrl: 'new_alliance_credit_card.html',
    directives: [coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [GetErrorsPipe, IdPipe, I18NPipe],
    exports: [RoutePaths, Routes])
class NewAllianceCreditCardComponent extends AllianceCreditCardsComponent implements OnActivate {

  List<dynamic> years = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13].map((i) {
    return js.context.callMethod('moment', []).callMethod('add', [i, 'years']).callMethod('format', ['YYYY']).toString();
  }).toList();

  List<dynamic> months = [
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
    alliance_id = current.parameters['id'];
    getAlliance();
  }

  String goToAlliance(id) => RoutePaths.view_alliance.toUrl(parameters: {idParam: id});

  NewAllianceCreditCardComponent(Router router, AdminServices adminServices) : super(router, adminServices);

  void save() {
    processing = true;
    Map<String,dynamic> new_credit_card = Map.from(credit_card);
    if (new_credit_card['number'] != null) {
      new_credit_card['number'] = new_credit_card['number'].replaceAll(RegExp(r'(\s+)'), '');
    }
    new_credit_card['costs_centers'] = new_credit_card['costs_centers'].map((cc) => cc['_id']).toList();
    new_credit_card['alliance_id'] = alliance_id;
    adminServices.alliance_credits_cards.post(new_credit_card).then((request) {
      router.navigate(RoutePaths.view_alliance.toUrl(parameters: {idParam: alliance_view['_id']}));
    }, onError: (e) {
      adminServices.evaluateError(e);
      processing = false;
    });
  }
}