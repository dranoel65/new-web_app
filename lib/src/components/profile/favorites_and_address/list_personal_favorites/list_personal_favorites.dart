import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../favorites.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(
    selector: 'list-personal-favorites',
    styleUrls: ['style.css'],
    templateUrl: 'list_personal_favorites.html',
    directives: [coreDirectives, formDirectives, routerDirectives,
      MenuTopComponent
    ],
    pipes: [GetErrorsPipe, MoneyPipe, IdPipe, NamePipe],
    exports: [RoutePaths, Routes])
class ListPersonalFavoritesComponent extends PersonalFavoriteComponent {
  Map item;

  String goToAddPersonalAddress(id) => RoutePaths.add_personal_address.toUrl(parameters: {idParam: '$id'});

  ListPersonalFavoritesComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    FavoriteUser();
  }

  void deactivateModal(Map itemModal) {
    item = itemModal;
    js.context.callMethod(r'$', ['#modalDeactivate']).callMethod('modal', [
      js.JsObject.jsify({'show': true})
    ]);
  }

  void deactivate(itemfavorite) {
    adminServices.favorites.deactivate(itemfavorite).then((request) {
      FavoriteUser();
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
    js.context
        .callMethod(r'$', ['#modalDeactivate']).callMethod('modal', ['hide']);
  }

  void deleteModal(Map itemModal) {
    item = itemModal;
    js.context.callMethod(r'$', ['#modalDelete']).callMethod('modal', [
      js.JsObject.jsify({'show': true})
    ]);
  }

  void delete(item_delete) {
    adminServices.list_users[0]['routes'].remove(item_delete);
    adminServices.users.put('${user['_id']}/routes', {'route': adminServices.list_users[0]['routes']}).then((request) {
        FavoriteUser();
      }, onError: (e) {
      adminServices.evaluateError(e);
    });
    js.context.callMethod(r'$', ['#modalDelete']).callMethod('modal', ['hide']);
  }
}
