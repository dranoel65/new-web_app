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
    selector: 'list-payments',
    templateUrl: 'list_payments.html',
    directives: [coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [ CurrencyPipe, GetErrorsPipe, IdPipe, NamePipe, CarBrandPipe, DateFormatPipe, MoneyPipe, I18NPipe],
    exports: [RoutePaths, Routes]
)
class ListPaymentsComponent extends DashboardComponent {

  String fi = '';
  String ff = '';
  String s = '';
  num n = 1;

  String goToListTrips(key) => RoutePaths.list_trips.toUrl(parameters: {target: key});
  String goToViewEditTrip(id) => RoutePaths.view_edit_trip.toUrl(parameters: {idParam: '$id'});

  ListPaymentsComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    searchPayments(1);
  }

  void searchPayments(num nn) {
    n = nn;
    Map<String,dynamic> smap = {'_sort': '-createdAt', '_page': n.toString(), 'populate': 'statuses+credit_card_id:number,type'};

    if (fi != '') {
      smap['createdAt__gte'] = js.context.callMethod('moment', [fi]).callMethod('toISOString');
    }

    if (ff != '') {
      smap['createdAt__lt'] = js.context.callMethod('moment', [ff]).callMethod('toISOString');
    }

    if (s != '') {
      smap['trip_id__likeid'] = s;
    }

    adminServices.listPayments(smap);
  }
}