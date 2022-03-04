import 'dart:convert';
import 'dart:js' as js;

import 'package:angular_router/angular_router.dart';

import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';

class AllianceCreditCardsComponent extends DashboardComponent {
  String q;
  Map<String,dynamic> itemModal;
  String alliance_id = '';
  String credit_card_id;
  bool itemModalError = false;
  bool itemModalError2 = false;
  Map<String,dynamic> alliance_view = {'legal': {'name': ''}};
  Map<String,dynamic> credit_card = { 'owner': {}, 'costs_centers': [], 'year': js.context.callMethod('moment', []).callMethod('format', ['YYYY']).toString(), 'month': '01' };

  AllianceCreditCardsComponent(Router router, AdminServices adminServices) : super(router, adminServices);

  void getAlliance() {
    adminServices.alliances.query({'_id__likeid': alliance_id,'return': 'legal'}.cast<String,dynamic>()).then((request) {
      alliance_view = jsonDecode(request.responseText)['result'][0];
    });
  }

  void addCostCenterModal() {
    itemModalError = false;
    q = '';
    adminServices.listCostsCenters({
      'alliance_father_id': alliance_id,
      'active': 'true',
      'return': '_id,name,tags'
    }.cast<String,dynamic>());
    js.context.callMethod(r'$', ['#addCostCenterodal']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  void removeCostCenterModal(cost_center) {
    itemModalError = false;
    itemModal = cost_center;
    js.context.callMethod(r'$', ['#modalDeactivate']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  void removeCostCenter(cost_center) {
    credit_card['costs_centers'].remove(cost_center);
    js.context.callMethod(r'$', ['#modalDeactivate']).callMethod(
        'modal', ['hide']);
  }

  void searchCostsCenters() {
    itemModalError = false;
    adminServices.listCostsCenters({
      'name__like': q.trim(),
      'tags__in': q.trim(),
      '_or': 'name,tags',
      'alliance_father_id': alliance_id,
      'active': 'true',
      'return': '_id,name,tags'
    }.cast<String,dynamic>());
  }

  void selectCostCenter(cost_center) {
    itemModalError = false;
    List<dynamic> filtered = credit_card['costs_centers'].where((cc) => cc['_id'] == cost_center['_id']).toList();
    if (filtered.isNotEmpty) {
      itemModalError = true;
      return;
    }
    credit_card['costs_centers'].add(cost_center);
  }
}
