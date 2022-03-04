import 'dart:convert';

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../alliances.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(
    selector: 'edit-alliance',
    styleUrls: ['../style.css'],
    templateUrl: 'edit_alliance.html',
    directives: [
      coreDirectives, formDirectives, routerDirectives,
      MenuTopComponent,
    ],
    pipes: [ GetErrorsPipe, IdPipe],
    exports: [RoutePaths, Routes])
class EditAllianceComponent extends AlliancesComponent implements OnActivate {
  String alliance_id = '';

  @override
  void onActivate(_, RouterState current) {
    alliance_id = current.parameters['id'];
    getFather(alliance_id);
    getAlliance();
  }

  String goToViewAlliance(id) => RoutePaths.view_alliance.toUrl(parameters: {idParam: id ?? ''});

  EditAllianceComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    edit = true;
  }

  void getAlliance() {
    adminServices.alliances.get(alliance_id, {
      'return': 'alliance_father_id,country_id,legal,info,domains,budget'
    }).then((request) {
      alliance = jsonDecode(request.responseText);
      if (!alliance.containsKey('info')) {
        alliance.addAll({
          'info': {'image': '', 'type_alliance': '', 'label': ''}
        });
      }
      if (!alliance.containsKey('price')) {
        alliance.addAll({
          'price': {
            'feed_admin': 0,
            'feed_trip': 0,
            'alliance_discounts': 0,
            'comission_alliance_percentage': 0
          }.cast<String,dynamic>()
        }.cast<String,dynamic>());
      }
      if(!alliance.containsKey('budget')){
        alliance['budget'] = {'mount': 0, 'mount_alert': 0, 'block': false};
      }
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void save() {
    adminServices.alliances.put(alliance_id, alliance).then(
            (request) {
          Map data = jsonDecode(request.responseText);
          router.navigate(RoutePaths.view_alliance.toUrl(parameters: {idParam: alliance_id}));
        }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }
}
