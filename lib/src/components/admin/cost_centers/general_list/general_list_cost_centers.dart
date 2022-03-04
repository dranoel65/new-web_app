import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/components/admin/cost_centers/list/list_cost_centers.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../costs_centers.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(selector: 'general-list-cost-centers',
    styleUrls: ['../style.css'],
    templateUrl: 'general_list_cost_centers.html',
    directives: [coreDirectives, formDirectives, routerDirectives,
      MenuTopComponent,
      ListCostCentersComponent
    ],
    pipes: [GetErrorsPipe, IdPipe],
    exports: [RoutePaths, Routes])
class GeneralListCostCentersComponent extends CostCentersComponent implements OnActivate {

  @override
  void onActivate(_, RouterState current) {
    alliance_id = current.parameters['id'];
  }

  GeneralListCostCentersComponent(Router router, AdminServices adminServices) : super(router, adminServices);

}
