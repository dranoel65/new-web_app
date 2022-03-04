import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/components/admin/users/list/list_users.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../users.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(selector: 'general-list-users',
    styleUrls: ['../style.css'],
    templateUrl: 'general_list_users.html',
    directives: [
      coreDirectives, formDirectives, routerDirectives, MenuTopComponent, ListUsersComponent],
    pipes: [ GetErrorsPipe, IdPipe, I18NPipe],
    exports: [RoutePaths, Routes])
class GeneralListUsersComponent extends UsersComponent implements OnActivate {

  @override
  void onActivate(_, RouterState current) {
    alliance_id = current.parameters['id'];
  }

  GeneralListUsersComponent(Router router, AdminServices adminServices) : super(router, adminServices);

}
