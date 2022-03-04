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

@Component(selector: 'edit-cost-center',
    styleUrls: ['../style.css'],
    templateUrl: 'edit_cost_center.html',
    directives: [
      coreDirectives, formDirectives, routerDirectives, MenuTopComponent
    ],
    pipes: [GetErrorsPipe, IdPipe],
    exports: [RoutePaths, Routes])
class EditCostCenterComponent extends CostCentersComponent implements OnActivate {
//  List <Map> restrictions = [];

  @override
  void onActivate(_, RouterState current) {
    cost_center_id = current.parameters['id'];
    getCostCenter();
  }

  String goToViewAlliance(id) => RoutePaths.view_alliance.toUrl(parameters: {idParam: id ?? ''});

  EditCostCenterComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    edit = true;
    hours2 = List<dynamic>.from(hours);
  }

  void getCostCenter() {
    adminServices.costs_centers.get(cost_center_id,
        {
          'return': 'name,tags,alliance_father_id,active,budget,restrictions,restrictions_block',
          'populate': 'alliance_father_id:legal'
        }.cast<String,dynamic>()).then((request) {
      Map data = jsonDecode(request.responseText);
      alliance_view = data['alliance_father_id'];
      data['tags'] = data['tags'].join(',');
      if(!data.containsKey('budget')){
        data['budget'] = {'mount': 0, 'mount_alert': 0, 'block': false};
      }

      cost_center = data;

    }, onError: (e) {
      adminServices.evaluateError(e);
    });

  }

  void save() {
    adminServices.costs_centers.put(cost_center_id, cost_center).then((request) {
      router.navigate(RoutePaths.view_alliance.toUrl(parameters: {idParam: alliance_view['_id']}));
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }
}
