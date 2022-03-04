import 'dart:convert';

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../costs_centers.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(selector: 'new-cost-center',
    styleUrls: ['../style.css'],
    templateUrl: 'edit_cost_center.html',
    directives: [
      coreDirectives, formDirectives, routerDirectives, MenuTopComponent
    ],
    pipes: [GetErrorsPipe, IdPipe],
    exports: [RoutePaths, Routes])
class NewCostCenterComponent extends CostCentersComponent implements OnActivate {

  @override
  void onActivate(_, RouterState current) {
    alliance_id = current.parameters['id'];
    cost_center['alliance_father_id'] = alliance_id;
    getAlliance();
  }

  String goToViewAlliance(id) => RoutePaths.view_alliance.toUrl(parameters: {idParam: id ?? ''});

  NewCostCenterComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    edit = false;
  }

  void getAlliance() {
    adminServices.alliances.get(alliance_id, {'return': 'legal'}).then((request) {
      Map data = jsonDecode(request.responseText);
      alliance_view = data;
    });
  }

  void save() {
    adminServices.costs_centers.post(cost_center).then((request) {
      router.navigate(RoutePaths.view_alliance.toUrl(parameters: {idParam: alliance_id}));
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }
}
