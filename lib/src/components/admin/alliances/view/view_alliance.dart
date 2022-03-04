import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/components/admin/alliance_credit_cards/list/list_alliance_credit_cards.dart';
import 'package:web_app/src/components/admin/alliance_favorites/list/list_alliance_favorites.dart';
import 'package:web_app/src/components/admin/cost_centers/list/list_cost_centers.dart';
import 'package:web_app/src/components/admin/users/list/list_users.dart';
import 'package:web_app/src/components/trips_services/trips/list_trips_details/list_trips_details.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../alliances.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(
    selector: 'view-alliance',
    styleUrls: ['../style.css'],
    templateUrl: 'view_alliance.html',
    directives: [coreDirectives, formDirectives, routerDirectives,
      MenuTopComponent,
      ListAllianceCreditCardsComponent,
      ListCostCentersComponent,
      ListUsersComponent,
      ListAllianceFavoriteComponent,
      ListTripsComponent],
    pipes: [ CurrencyPipe, GetErrorsPipe, IdPipe],
    exports: [RoutePaths, Routes])
class ViewAllianceComponent extends AlliancesComponent implements OnActivate {

  String alliance_id = '';
  String a='';

  @override
  void onActivate(_, RouterState current) {
    alliance_id = current.parameters['id'];
    getAlliance();
    getFather(alliance_id);
    alliance;
  }

  String goToEditAlliance(id) => RoutePaths.edit_alliance.toUrl(parameters: {idParam: id});
  String goToViewAlliance(id) => RoutePaths.view_alliance.toUrl(parameters: {idParam: id});

  ViewAllianceComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    Future(() {
      ElementList<Element> tabs = querySelectorAll('#avancedTab a');
      tabs.onClick.listen((Event e) {
        e.preventDefault();
        js.context.callMethod(r'$', [e.target]).callMethod('tab', ['show']);
      });
      js.context.callMethod(r'$', ['#active']).callMethod('tab', ['show']);
    });
  }

  void getAlliance() {
    adminServices.alliances.get(alliance_id,
        {'populate': 'country_id:name'}.cast<String,dynamic>()).then((request) {
      alliance = jsonDecode(request.responseText);
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }
}

