import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular/angular.dart';
import 'package:angular/core.dart';
import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../alliances.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(
    selector: 'list-alliances',
    styleUrls: ['../style.css'],
    templateUrl: 'list_alliances.html',
    directives: [coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [ CurrencyPipe, GetErrorsPipe, IdPipe, I18NPipe],
    exports: [RoutePaths, Routes])
class ListAlliancesComponent extends AlliancesComponent {
  Map<String,dynamic> itemModal;

  String goToViewAlliance(key) => RoutePaths.view_alliance.toUrl(parameters: {idParam: key});

  ListAlliancesComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    listAlliances();
  }

//int trackByFn(int index, domain) => domain.toString();
  void listAlliances([Map queryParameters, String return_fields]) {
    adminServices.listAlliances({'populate': populate, 'return': str_return}.cast<String,dynamic>());
  }

  void searchAlliances() {
    adminServices.listAlliances({
      'legal.name__like': q,
      'legal.nit__like': q,
      'populate': populate,
      'return': str_return,
      '_or': 'legal.name,legal.nit'
    }.cast<String,dynamic>());
  }

  void deactivateModal(item) {
    itemModal = item;
    js.context.callMethod(r'$', ['#modalDeactivate']).callMethod('modal', [
      js.JsObject.jsify({'show': true})
    ]);
  }

  void activateModal(item) {
    itemModal = item;
    js.context.callMethod(r'$', ['#modalActivate']).callMethod('modal', [
      js.JsObject.jsify({'show': true})
    ]);
  }

  void deactivate(alliance_id) {
    adminServices.alliances.deactivate(alliance_id).then((request) {
      listAlliances();
    }, onError: (e) {
      adminServices.evaluateError(e);
    });

    js.context
        .callMethod(r'$', ['#modalDeactivate']).callMethod('modal', ['hide']);
  }

  void activate(alliance_id) {
    adminServices.alliances.activate(alliance_id).then((request) {
      listAlliances();
    }, onError: (e) {
      adminServices.evaluateError(e);
    });

    js.context
        .callMethod(r'$', ['#modalActivate']).callMethod('modal', ['hide']);
  }
}

