import 'dart:convert';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular/angular.dart';

import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../../../route_paths.dart';
import '../../../routes.dart';

@Component(
    selector: 'list-histories',
    templateUrl: 'list_histories.html',
    directives: [coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [ CurrencyPipe, GetErrorsPipe, IdPipe, NamePipe, CarBrandPipe, DateFormatPipe, MoneyPipe, I18NPipe],
    exports: [RoutePaths, Routes]
)
class ListHistoriesComponent extends DashboardComponent {

  Map<String,dynamic> statistic = {'personal-trips': null,'credit-cards': null};

  String fi = '';
  String ff = '';
  String s = '';
  num n = 1;

  String goToListTrips(key) => RoutePaths.list_trips.toUrl(parameters: {target: key});
  String goToViewEditTrip(id) => RoutePaths.view_edit_trip.toUrl(parameters: {idParam: '$id'});

  ListHistoriesComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    searchHistories(1);
  }

  void searchHistories(num nn) {
    n = nn;
    Map<String,dynamic> smap = {'_sort': '-createdAt', '_page': n.toString()};

    if (fi != '') {
      smap['createdAt__gte'] = js.context.callMethod('moment', [fi]).callMethod('toISOString');
    }

    if (ff != '') {
      smap['createdAt__lt'] = js.context.callMethod('moment', [ff]).callMethod('toISOString');
    }

    if (s != '') {
      smap['trip_id__likeid'] = s;
    }

    adminServices.listHistories(smap);
    sumPersonalTrips();
    sumPersonalCreditCards();
  }

   Future sumPersonalTrips() async {
    return await adminServices.statistics.get('sum-personal-trips').then((request) {
      Map data = jsonDecode(request.responseText);
      statistic['personal-trips'] = data['result'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  Future sumPersonalCreditCards() async {
    return await adminServices.statistics.get('sum-personal-credit-cards').then((request) {
      Map data = jsonDecode(request.responseText);
      statistic['credit-cards'] = data['result'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }
}