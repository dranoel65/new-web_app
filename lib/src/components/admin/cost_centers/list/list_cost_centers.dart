import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../costs_centers.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(
    selector: 'list-cost-centers',
    styleUrls: ['../style.css'],
    templateUrl: 'list_cost_centers.html',
    directives: [coreDirectives, formDirectives, routerDirectives, MenuTopComponent
    ],
    pipes: [ CurrencyPipe, GetErrorsPipe, IdPipe, DateFormatPipe, I18NPipe, DaysPipe],
    exports: [RoutePaths, Routes])
class ListCostCentersComponent extends CostCentersComponent implements OnInit {
  @override
  @Input('alliance_id')
  String alliance_id;

  String list_all;

  String goToViewAlliance(id) => RoutePaths.view_alliance.toUrl(parameters: {idParam: id ?? ''});
  String goToEditCostCenter(id) => RoutePaths.edit_cost_center.toUrl(parameters: {idParam: '$id'});
  String goToNewCostCenter(id) => RoutePaths.new_cost_center.toUrl(parameters: {idParam: '$id'});

  ListCostCentersComponent(Router router, AdminServices adminServices) : super(router, adminServices);

  @override
  void ngOnInit() {
    if (alliance_id != null) {
      list_all = 'alliance';
    }
    else {
      list_all = 'all';
    }

    searchCostsCenters(n);
  }

  void searchCostsCenters(num nn) {
    n = nn;
    Map<String,dynamic> s = {
      '_sort': 'name',
      'populate': 'alliance_father_id:legal.name|credit_card_id:number',
      'return': '_id,name,tags,tags,active,alliance_father_id,budget,credit_card_id,restrictions,restrictions_block',
      '_page': n.toString()
    };
    if (list_all != 'all') {
      if (alliance_id != null) {
        s['alliance_father_id'] = alliance_id;
      }
      else {
        s['alliance_father_id'] = Af;
      }
    }

    if (xactive != '') {
      s['active'] = xactive;
    }

    if (q != '') {
      s['name__like'] = q.trim();
      s['tags__in'] = q.trim();
      s['_or'] = 'name,tags';
    }
    adminServices.listCostsCenters(s);
  }

  void deactivateModal(Map itemModal) {
    item = itemModal;
    js.context.callMethod(r'$', ['#modalDeactivate']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  void activateModal(Map itemModal) {
    item = itemModal;
    js.context.callMethod(r'$', ['#modalActivate']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  Future active(costCenter) async {
    if (costCenter.length == 0) {
      return;
    }
    await adminServices.costs_centers.activate(costCenter['_id']).then((request) {

    }, onError: (e) {
      adminServices.evaluateError(e);
    });
    searchCostsCenters(n);
    js.context.callMethod(r'$', ['#modalActivate']).callMethod(
        'modal', ['hide']);
  }

  Future remove(costCenter) async {
    if (costCenter.length == 0) {
      return;
    }
    await adminServices.costs_centers.deactivate(costCenter['_id']).then((request) {}, onError: (e) {
      adminServices.evaluateError(e);
    });
    searchCostsCenters(n);
    js.context.callMethod(r'$', ['#modalDeactivate']).callMethod(
        'modal', ['hide']);
  }

}
