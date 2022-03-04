import 'dart:async';
import 'dart:convert';
import 'dart:html' hide Point, Events;
import 'dart:js' as js;

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:web_app/classes/User.dart';
import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/components/trips_services/trips/list_trips_details/trips_details.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(selector: 'list-trips-details',
    styleUrls: ['../style.css'],
    templateUrl: 'list_trips_details.html',
    directives: [coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [ GetErrorsPipe, IdPipe, NamePipe, CarBrandPipe, DateFormatPipe, MoneyPipe, I18NPipe, CurrencyPipe],
    exports: [RoutePaths, Routes])
class ListTripsComponent extends TripsDetailsComponent implements OnInit {
  @Input('alliance_id')
  String alliance_id;

  @Input('show_id')
  String show_id;

  @Input('personal')
  bool personal = false;

  Map itemModal;
  String user_id = User.user['_id'];
  bool tab = true;
  String visual = '';
  String a = '';
  num n = 1;
  bool generate = false;
  bool download = false;

  Timer timer_ap2;
  Map costcenter_item = {},
      alliance_item = {},
      passenger_item = {};
  String passenger_q='', alliance_q='', costcenter_q = '';
  List<dynamic> list_Alliances_child = [];
  Map error;

  List<String> words = [
    'Id del Vuelo',
    'Tipo de Viaje',
    'Tipo de Vehículo',
    'Región',
    'Dirección Origen',
    'Dirección Destino',
    'Hora Creación',
    'Hora Inicio',
    'Hora fin',
    'Estado',
    'Pasajero',
    'Solicitante',
    'Alianza',
    'Alianza Padre',
    'Cliente',
    'Centro de Costo',
    'Distancia (km)',
    'Tiempo (min)',
    'Descuento (%)',
    'Valor Descuento',
    'Precio Final',
    'Medio de Pago',
    'Comentarios',
    'Concepto',
    'Tipo de Documento del Pasajero',
    'Documento del Pasajero'
  ];
  List<Map> wordsOptions = [];

  bool admin = (User.user['type_user'] == 'admin');
  String nigth_from = 'AM';
  String month_from = '00',
      day_from = '',
      month_to = '00',
      day_to = '';

  Timer timer;
  Timer timer_ap;

  List<String> daysFrom = [];
  List<String> daysTo = [];

  @override
  Future ngOnInit() async {
    user_id = User.user['_id'];
    if (alliance_id != null) {
      visual = 'alliance';
    } else if (show_id == 'actives') {
      visual = 'actives';
    } else {
      visual = 'all';
      personal = true;
    }
    alliances_all = [User.user['alliance_id']['_id']];

    await searchTrips(n);
  }

  String goToViewEditTrip(id) => RoutePaths.view_edit_trip.toUrl(parameters: {idParam: '$id'});

  ListTripsComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    timer = Timer(Duration(seconds: 1), () {
      timer.cancel();
      timerProcess();
    });
    user['trips_report'] = {};
    user['trips_report']['percent'] = 0;
//    getUser();
    words.forEach((w) {
      wordsOptions.add({ 'name': w, 'v': true});
    });
    alliances_all=[(User.user['alliance_id']['_id'])];

  }

  void actives() {
    tab = false;
    adminServices.listTrips({
      'status__in': 'created,finding,reserving,reserved,starting,onWay,near,arrived,started',
      'alliance_id__in': alliances_all.join(','),
      'cost_center_id__ne': null
    }.cast<String,dynamic>());
  }

  void timerProcess() {
    if (RegExp(r'actives').hasMatch(Uri.base.toString())) {
      searchTrips(n);
      timer_ap = Timer(Duration(seconds: 10), () {
        timer_ap.cancel();
        timerProcess();
      });
    }
  }

  void changeTo() {
    window.console.log(month_to);
    daysTo.clear();

    Future(() {
      if (month_to != '00') {
        for (int a = 1; a <= changeM(month_to); a++) {
          daysTo.add(a < 10 ? '0${a.toString()}' : a.toString());
        }
        day_to = '01';
      }
    });
  }

  void changeFrom() {
    daysFrom.clear();

    Future(() {
      if (month_from != '00') {
        for (int a = 1; a <= changeM(month_from); a++) {
          daysFrom.add(a < 10 ? '0${a.toString()}' : a.toString());
        }
        day_from = '01';
      }
    });
  }

  Future searchTrips(num nn) async {
    n = nn;
    Map<String,dynamic> smap = {'_sort': '-end.date', '_page': n.toString()};
    if(tab!=false) {
      if(User.user['alliance_id'].containsKey('alliance_father_id')){
        if(User.user['alliance_id']['alliance_father_id']!=null){
          Af=User.user['alliance_id']['alliance_father_id'];
          await adminServices.alliances.query({'alliance_father_id':Af, 'return':'legal'}.cast<String,dynamic>()).then((request) {
            Map child_alliance = jsonDecode(request.responseText);
            alliances_all.add(Af);
            child_alliance['result'].forEach((a) {
              alliances_all.add(a['_id']);
            });
          }, onError: (e) {
            adminServices.evaluateError(e);
          });

        }else{
          Af=User.user['alliance_id']['_id'];
          await adminServices.alliances.query({'alliance_father_id':Af, 'return':'legal'}.cast<String,dynamic>()).then((request) {
            Map child_alliance = jsonDecode(request.responseText);
            alliances_all.add(Af);
            child_alliance['result'].forEach((a) {
              alliances_all.add(a['_id']);
            });
          }, onError: (e) {
            adminServices.evaluateError(e);
          });

        }
      }

      if (alliance_id != null) {
        smap['alliance_id__in'] = alliances_all.join(',');
        smap['cost_center_id__ne'] = 'null';
        if (tab == true) {
          smap['status__in'] = 'cancelled,finished,normalized,created,finding,reserving,reserved,starting,onWay,near,arrived,started';
        } else {}
      } else if (show_id == 'actives') {
        smap['status__in'] = 'created,finding,reserving,reserved,starting,onWay,near,arrived,started';
        smap['requester_id'] = user_id;
        smap['passenger_id'] = user_id;
        smap['passengers.passenger_id'] = user_id;
        smap['_or'] = 'requester_id,passengers.passenger_id,passenger_id';
      } else if (show_id == 'all') {
        smap['requester_id'] = User.user['_id'];
        smap['passengers.passenger_id'] = user_id;
        if(passenger_q=='' || passenger_q==null){
          smap['passenger_id'] = user_id;
        }else{
          smap['passenger_id'] = passenger_q;
        }
        smap['_or'] = 'requester_id,passengers.passenger_id,passenger_id';
      } else {}

      if (s != '') {
        smap['_id__likeid'] = s;
      } else {
        if (q != '') {
          smap['status__in'] = q;
        }
        if (costcenter_item.containsKey('_id')) {
          smap['cost_center_id'] = costcenter_item['_id'];
          smap.remove('cost_center_id__ne');
        }

        if (alliance_item.containsKey('_id')) {
          smap['alliance_id'] = alliance_item['_id'];
          smap.remove('alliance_father_id');
          smap['alliance_father_id']= smap['alliance_id'];
        }

        if (passenger_item.containsKey('_id')) {
          smap['passenger_id'] = passenger_item['_id'];
          smap['passengers.passenger_id'] = passenger_item['_id'];
          smap['_or'] = 'passenger_id,passengers.passenger_id';
        }

        if (month_from != '00') {
          String date = '$year-$month_from-$day_from';
          window.console.log(date);
          date = js.context.callMethod('moment', [date]).callMethod('toISOString');

          smap['end.date__gte'] = js.context.callMethod('moment', [date]).callMethod('toISOString');
        }

        if (month_to != '00') {
          String date = '$year-$month_to-$day_to';
          window.console.log(date);
          date = js.context.callMethod('moment', [date]).callMethod('toISOString');

          smap['end.date__lt'] = js.context.callMethod('moment', [date]).callMethod('add', [1, 'day']).callMethod('toISOString');
        }

        if (r != '') {
          smap['type_trip'] = r;
        }
        if (c != '') {
          smap['category'] = c;
        }
      }
      await adminServices.listTrips(smap);
    }
    tab=true;
  }


  void activateModal(Map item) {
    itemModal = item;
    js.context.callMethod(r'$', ['#cancelModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  void setCancelTrip() {
    adminServices.trips.put('${itemModal['_id']}/cancelled', {}).then((request) {
      var t = jsonDecode(request.responseText);
      searchTrips(n);
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
    js.context.callMethod(r'$', ['#cancelModal']).callMethod('modal', ['hide']);
  }

  // generate excel
  void generateFile() {
    js.context.callMethod(r'$', ['#modal']).callMethod('modal', ['hide']);
    user['trips_report']['percent'] = 0.1;
    user['trips_report']['generated'] = false;
    user['trips_report']['file_url'] = '';
    generate = true;
    download = false;
    Map<String,dynamic> smap = {'_sort': '-end.finished_date'};

    if (alliance_id != null) {
     // smap['alliance_id__in'] = alliances_all.join(',');
      smap['cost_center_id__ne'] = 'null';
      if (tab == true) {
        smap['status__in'] = 'cancelled,finished,normalized';
      } else {}
    } else if (show_id == 'actives') {
     // smap['alliance_id__in'] = alliances_all.join(',');
      smap['status__in'] = 'created,finding,reserving,reserved,starting,onWay,near,arrived,started';
      smap['requester_id'] = user_id;
      smap['passenger_id'] = user_id;
      smap['_or'] = 'requester_id,passenger_id';
    } else if (show_id == 'all') {
     // smap['alliance_id__in'] = alliances_all.join(',');
      smap['requester_id'] = User.user['_id'];
      smap['passenger_id'] = user_id;
      smap['_or'] = 'requester_id,passenger_id';
      smap['personal'] = '1';
    } else {}

    if (s != '') {
      smap['_id__likeid'] = s;
    } else {
      if (q != '') {
        smap['status__in'] = q;
      }
      if (costcenter_item.containsKey('_id')) {
        smap['cost_center_id'] = costcenter_item['_id'];
      }

      if (alliance_item.containsKey('_id')) {
        smap['alliance_id'] = alliance_item['_id'];
      }

      if (passenger_item.containsKey('_id')) {
        smap['passenger_id'] = passenger_item['_id'];
        smap['passengers.passenger_id'] = passenger_item['_id'];
        smap['_or'] = 'passenger_id,passengers.passenger_id';
      }

      if (month_from != '00') {
        String date = '$year-$month_from-$day_from';
        window.console.log(date);
        date = js.context.callMethod('moment', [date]).callMethod('toISOString');

        smap['end.finished_date__gte'] = js.context.callMethod('moment', [date]).callMethod('toISOString');
      }

      if (month_to != '00') {
        String date = '$year-$month_to-$day_to';
        window.console.log(date);
        date = js.context.callMethod('moment', [date]).callMethod('toISOString');

        smap['end.finished_date__lt'] = js.context.callMethod('moment', [date]).callMethod('add', [1, 'day']).callMethod('toISOString');
      }

      if (r != '') {
        smap['type_trip'] = r;
      }
    }

    List<String> data = [];
    wordsOptions.forEach((w) {
      if (w['v']) {
        data.add(w['name']);
      }
    });
    adminServices.downloadTrips(smap, data);
    timer_ap2 = Timer(Duration(seconds: 5), () {
      timer_ap2.cancel();
      if (RegExp(r'trips/list/all|alliances/view/').hasMatch(Uri.base.toString())) {
        getUser();
      }
    });
  }

  void modalAtentionTrip() {
    js.context.callMethod(r'$', ['#modal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  // pasajero
  void searchPassagers() {
    adminServices.listUsers({
      'alliance_id__in': alliances_all.join(','),
      'personal_info.firstname__like': passenger_q,
      'personal_info.lastname__like': passenger_q,
      'personal_info.phone__like': passenger_q,
      'email__like': passenger_q,
      'return': 'email,alliance_id,costs_centers_ids,personal_info,type_user,active',
      '_or': 'personal_info.firstname,personal_info.lastname,personal_info.phone,email'
    }.cast<String,dynamic>());
  }

  void selectPassengersModal() {
    passenger_q='';
    alliance_q='';
    costcenter_q = '';
    q = '';
    searchPassagers();
    js.context.callMethod(r'$', ['#PassengersModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  // allianzas

  void searchAlliance() {
    adminServices.alliances.getSub({
      'legal.name__like': alliance_q,
      'legal.email__like': passenger_q,
      'legal.phone__like': passenger_q,
      '_or': 'legal.name, legal.email, legal.phone'
    }.cast<String,dynamic>()).then((request) {
      list_Alliances_child = jsonDecode(request.responseText)['result'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void selectAllianceModal() {
    passenger_q='';
    alliance_q='';
    costcenter_q = '';
    q = '';
    searchAlliance();
    js.context.callMethod(r'$', ['#AllianceModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  // centro de costos
  void searchCostCenter() {
    if(visual !='alliance') {
      adminServices.listCostsCenters({
        '_id__in': User.user['costs_centers_ids'].join(','),
        'name__like': costcenter_q.trim(),
        'tags__in': costcenter_q.trim(),
        'return': 'name,active,alliance_father_id,credit_card_id,tags',
        'populate': 'alliance_father_id:legal.name|credit_card_id:number',
        '_or': 'name,tags',
        '_limit': '500',
        '_sort': 'name',
      }.cast<String,dynamic>());
    } else {
      adminServices.listCostsCenters({
        'name__like': costcenter_q.trim(),
        'tags__in': costcenter_q.trim(),
        'return': 'name,active,alliance_father_id,credit_card_id,tags',
        'populate': 'alliance_father_id:legal.name|credit_card_id:number',
        '_or': 'name,tags',
        '_limit': '500',
        '_sort': 'name',
      }.cast<String,dynamic>());
    }
  }

  void selectCostCenterModal() {
    passenger_q='';
    alliance_q='';
    costcenter_q = '';
    q = '';
    searchCostCenter();
    js.context.callMethod(r'$', ['#CostCenter2Modal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  void selectItem([Map item, String a = '']) {
    if (a == 'alliance') {
      alliance_item = item;
      js.context.callMethod(r'$', ['#AllianceModal']).callMethod('modal', ['hide']);
    } else if (a == 'costcenter') {
      costcenter_item = item;
      js.context.callMethod(r'$', ['#CostCenter2Modal']).callMethod('modal', ['hide']);
    } else {
      passenger_item = item;
      js.context.callMethod(r'$', ['#PassengersModal']).callMethod('modal', ['hide']);
    }
  }

  void deleteThis(String a) {
    passenger_q='';
    alliance_q='';
    costcenter_q = '';
    n=1;
    if (a == 'alliance') {
      alliance_item = {};
    } else if (a == 'costcenter') {
      costcenter_item = {};
    } else {
      passenger_item = {};
    }
  }

  void getUser() {
    user['trips_report']['percent']=0;
    adminServices.users.get(user['_id'], {'return': 'trips_report'}).then((request) {
      Map data = jsonDecode(request.responseText);
      data = data.containsKey('trips_report') ? data : {'trips_report': {}};
      user['trips_report']['percent'] = data['trips_report'].containsKey('percent') ? data['trips_report']['percent'] : 0;
      user['trips_report']['expires'] = data['trips_report'].containsKey('expires') ? data['trips_report']['expires'] : '';
      user['trips_report']['timeout'] = data['trips_report'].containsKey('timeout') ? data['trips_report']['timeout'] : '';
      user['trips_report']['generated'] = data['trips_report'].containsKey('generated') ? data['trips_report']['generated'] : false;
      user['trips_report']['file_url'] = data['trips_report'].containsKey('file_url') ? data['trips_report']['file_url'] : '';
      var timeout = js.context.callMethod('moment', [user['trips_report']['timeout']]).callMethod('diff', [js.context.callMethod('moment', []), 'minutes']);
      if (user['trips_report']['timeout'] != '' && user['trips_report']['percent'] > 0 && user['trips_report']['percent'] < 100 && timeout <= 0) {
        user['trips_report']['percent'] = 0;
        user['trips_report']['expires'] = '';
        user['trips_report']['generated'] = false;
        user['trips_report']['file_url'] = '';
        generate = false;
        download = true;
      } else {
        generate = !(user['trips_report']['percent'] == 0 || user['trips_report']['percent'] == 100);
        var days = js.context.callMethod('moment', [user['trips_report']['expires']]).callMethod('diff', [js.context.callMethod('moment', []), 'days']);
        if (days <= 0) {
          download = true;
        } else {
          download = !user['trips_report']['generated'];
        }
        if (user['trips_report']['percent'] != null && user['trips_report']['percent'] == 100 && timer_ap != null) {
          timer_ap2.cancel();
        }
        if (user['trips_report']['percent'] == 100) {
          download=true;
          var windowObjectReference;
          void openRequestedPopup() {
            windowObjectReference = window.open(
                user['trips_report']['file_url'],
                '_blank',
                'resizable,scrollbars,status'
            );
          }
          openRequestedPopup();
        }
        if (user['trips_report']['percent'] > 0 && user['trips_report']['percent'] < 100) {
          timer_ap2 = Timer(Duration(seconds: 5), () {
            timer_ap2.cancel();
            if (RegExp(r'trips/all|alliances/view').hasMatch(Uri.base.toString())) {
              getUser();
            }
          });
        }
      }
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }
}
