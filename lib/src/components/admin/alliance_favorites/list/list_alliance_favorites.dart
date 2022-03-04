import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular/angular.dart';

import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(selector: 'list-alliance-favorites',
    styleUrls: ['style.css'],
    templateUrl: 'list_alliance_favorites.html',
    directives: [coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [GetErrorsPipe, MoneyPipe, IdPipe, NamePipe])
class ListAllianceFavoriteComponent extends DashboardComponent  implements OnInit{
  Map item;
  String q = '';
  Map<String,dynamic> favorite = {'alliance_id': '', 'name': '', 'start': {'address': '', 'position': []}, 'end': {'address': null, 'position': null}};

  @Input('alliance_id')
  String alliance_id = '';

  @override
  void ngOnInit() {
    searchFavorites();
  }

  String goToAddPersonalAddAllianceFavorite(id) => RoutePaths.add_personal_and_alliance_favorite.toUrl(parameters: {idParam: id?? ''});

  ListAllianceFavoriteComponent(Router router, AdminServices adminServices) : super(router, adminServices);

  void searchFavorites() {
    Map<String,dynamic> dataQuery = {
      'alliance_id': alliance_id,
      'active': 'true', 'return': 'name,start.position,start,end,alliance_id'
    };

    if(q != '') {
      dataQuery['name__like'] = q;
    }

    adminServices.alliances.get('favorites',dataQuery).then((request) {
      Map<String,dynamic> data = jsonDecode(request.responseText);
      adminServices.list_favorites = data['result'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void deactivateModal(itemModal) {
    item = itemModal;
    js.context.callMethod(r'$', ['#modalDelete']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  Future deactivate(itemfavorite) async {
    await adminServices.favorites.deactivate(itemfavorite).then((request) {
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
    await adminServices.alliances.get('favorites',{'alliance_id': alliance_id, 'active': 'true', 'return': 'name,start.position,start,end,alliance_id'}.cast<String,dynamic>()).then((request) {
      Map<String,dynamic> data = jsonDecode(request.responseText);
      adminServices.list_favorites = data['result'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
    js.context.callMethod(r'$', ['#modalDelete']).callMethod('modal', ['hide']);
  }

}
