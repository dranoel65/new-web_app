import 'dart:convert';

import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular/angular.dart';

import 'package:web_app/classes/User.dart';
import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

@Component(selector: 'fares',
    styleUrls: ['style.css'],
    templateUrl: 'fares.html',
    directives: [ coreDirectives, formDirectives, MenuTopComponent],
    pipes: [
      GetErrorsPipe,
      IdPipe,
      NamePipe,
      CarBrandPipe,
      DateFormatPipe,
      MoneyPipe,
      I18NPipe
    ])
class FaresComponent extends DashboardComponent {
  String show_id;
  Map user = User.user;
  double up =1.0;
  String city = 'Bogota';
  bool know_driver = false;
  double update_fare_2020 = 1.06;

  FaresComponent(Router router, AdminServices adminServices) : super(null, adminServices) {
    searchAlliance();
  }

  void searchAlliance() {
    adminServices.alliances.get(user['alliance_id']['_id'], {
      'return':'price,legal,alliance_father_id,service_trip',
      'populate':'alliance_father_id'
    }.cast<String,dynamic>()).then((request) {
      Map alliance = jsonDecode(request.responseText);
      Map price ={'comission_alliance_percentage': 0.0, 'alliance_discounts': 0.0, 'feed_trip': 0.0, 'add_all': 0.0};
//      if(!alliance['price'].containsKey('feed_trip')){
//        price['feed_trip']=0;
//      }
//      if(alliance['price']['add_all']!=0.0){
//        up=(up*(alliance['price']['add_all']/100))+up;
//      }
//      if(alliance['price']['feed_trip']!=0.0){
//        up=up*(alliance['price']['feed_trip']/100)+up;
//      }
//      if(alliance['price']['comission_alliance_percentage']!=0.0){
//        up=up*(alliance['price']['comission_alliance_percentage']/100)+up;
//      }
      if(alliance['price']['alliance_discounts']!=0.0){
        up = up*(-alliance['price']['alliance_discounts']/100)+up;
      }
      up = up * update_fare_2020;
      if(alliance['alliance_father_id']==null && alliance.containsKey('service_trip')){
        know_driver=alliance['service_trip']['know_driver'];
      }
      else{
        if(alliance['alliance_father_id'].containsKey('service_trip')) {
          know_driver = alliance['alliance_father_id']['service_trip']['know_driver'];
        }
      }
    }, onError: (e) {
      adminServices.evaluateError(e);
    });

  }

}
