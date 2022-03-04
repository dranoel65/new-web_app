import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/components/trips_services/trips/list_trips_details/list_trips_details.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../../../../route_paths.dart';
import '../../../../routes.dart';
import '../trips.dart';

@Component(selector: 'list-trips',
    styleUrls: ['../style.css'],
    templateUrl: 'list_trips.html',
    directives: [coreDirectives, formDirectives, MenuTopComponent,ListTripsComponent],
    pipes: [
      GetErrorsPipe,
      IdPipe,
      NamePipe,
      CarBrandPipe,
      DateFormatPipe,
      MoneyPipe,
      I18NPipe
    ],
    exports: [RoutePaths, Routes])
class ListTripsUserComponent extends TripsComponent implements OnActivate {

  String show_id;
  bool personal = true;

  @override
  void onActivate(_, RouterState current) {
    show_id = current.parameters['target'];
  }

  ListTripsUserComponent(Router router, AdminServices adminServices) : super(router, adminServices);
}
