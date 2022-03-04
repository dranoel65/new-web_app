import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:google_maps/google_maps_geometry.dart';

import 'package:web_app/classes/pipes.dart';
import 'package:google_maps/google_maps.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/classes/User.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../../../../config.dart';
import '../massive_routes.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(selector: 'list_routes_user_groups',
    styleUrls: ['../style.css'],
    templateUrl: 'list_routes_user_groups.html',
    directives: [coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [ GetErrorsPipe, IdPipe, NamePipe, CarBrandPipe, DateFormatPipe, MoneyPipe, I18NPipe],
    exports: [RoutePaths, Routes])
class ListRoutesUserGroupsComponent extends MassiveRoutesComponent {
  Map itemModal;
  String alliance_id;
  String show_id;
  String user_id = User.user['_id'];
//  bool tab = true;
//  String visual = '';
  String a = '';
  num n = 1;

  Map costcenter_item = {},
      alliance_item = {},
      passenger_item = {};
  String passenger_q ='', alliance_q='', costcenter_q = '';
  List<dynamic> list_Alliances_child = [];
  Map error;

  bool admin = (User.user['type_user'] == 'admin');
  String nigth_from = 'AM';
  String month_from = '00',
      day_from = '',
      month_to = '00',
      day_to = '';
  String shadow_passenger = '';

  Timer timer;
  Timer timer_ap;

  List<String> daysFrom = [];
  List<String> daysTo = [];
  Map group = {};
  Map preview = {
    'start': {},
    'end': {},
    'type_trip': 'instantly',
    'service_trip': {
      'pool': false,
      'places': 1,
      'know_driver': false
    },
    'passengers':[]
  };
  var map;
  final mapOptions = MapOptions()
    ..styles = Config.mapStyles
    ..zoom = 14
    ..center = LatLng(4.6634163, -74.0920055)
    ..streetViewControl= false;
  Polyline estimate_path;
  LatLng center = LatLng(4.6634163, -74.0920055);
  final geocoder = Geocoder();
  final infowindow = InfoWindow();
  List<dynamic> stops = [];
  List<dynamic> passengers = [];
  List<Marker> markers = [];
  List<Marker> stop_markers = [];
  String msg_error = '';
  String type_trip;
//  Map estimate = {'date_end':"2018-10-18T02:02:01.213Z", 'date_start':"2018-10-18T01:20:10.271Z", 'distance':0, 'passengers':[], 'path':'', 'price':{}, 'time':0};
  Map estimate;
  Marker marker;
  String type_route = '';
  String status = 'grouped,not_grouped';
  bool trip__status = false;
  String archived_id = '';
  String current_trip = '';
  bool block = false;

  List<String> words = [
    'Id de la Ruta',
    'Tipo de Vehículo',
    'Hora Inicio',
    'Estado',
    'Águila',
    'Águila Celular',
    'Placa',
    'Pasajero',
    'Pasajero Celular',
    'Pasajero Email',
    'Pasajero Dirección',
    'Tipo de Viaje'
  ];
  List<dynamic> wordsOptions = [];
  bool download = false;
  bool generate = false;
  Timer timer_ap2;
  Map group_id = {};
  var update;
  String passengers_group = '';

  String goToListTrips(key) => RoutePaths.list_trips.toUrl(parameters: {target: key});
  String goToNewRoute(load) => RoutePaths.list_trips.toUrl(parameters: {preLoad: load});
  String goToViewEditTrip(id) => RoutePaths.view_edit_trip.toUrl(parameters: {idParam: '$id'});

  ListRoutesUserGroupsComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    user_id = User.user['_id'];
    alliances_all=[User.user['alliance_id']['_id']];
    user['routes_report'] = {};
    user['routes_report']['percent'] = 0;
    searchGroups(n);
    words.forEach((w) {
      wordsOptions.add({ 'name': w, 'v': true});
    });
    timer = Timer(Duration(seconds: 1), () {
      var mc = querySelector('#map-canvas');
      if (mc != null) {
        timer.cancel();
        map = GMap(mc, mapOptions);
        map.center = center;

        estimate_path = Polyline(PolylineOptions()
          ..geodesic = true
          ..strokeColor = '#0404B4'
          ..strokeOpacity = 1.0
          ..strokeWeight = 2
          ..map = map);

      }
    });
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

  Future searchGroups(num nn) async {
    n = nn;
    Map<String,dynamic> smap = {
      '_sort': '-date',
      '_page': n.toString(),
      'populate': 'alliance_id:legal|cost_center_id:name|passengers+passenger_id:personal_info,email|trip_id:status,car_id'
    };

    if (costcenter_item.containsKey('_id')) {
      smap['cost_center_id'] = costcenter_item['_id'];
    }

    if (alliance_item.containsKey('_id')) {
      smap['alliance_id'] = alliance_item['_id'];
    }

    if (passenger_item.containsKey('_id')) {
      smap['passengers.passenger_id'] = passenger_item['_id'];
    }

    if (month_from != '00') {
      String date = '${year}-${month_from}-${day_from}';
      date = js.context.callMethod('moment', [date]).callMethod('toISOString');

      smap['date__gte'] = js.context.callMethod('moment', [date]).callMethod('toISOString');
    }

    if (month_to != '00') {
      String date = '${year}-${month_to}-${day_to}';
      date = js.context.callMethod('moment', [date]).callMethod('toISOString');

      smap['date__lt'] = js.context.callMethod('moment', [date]).callMethod('add', [1, 'day']).callMethod('toISOString');
    }
    if(type_route!='') {
      smap['type_route'] = type_route;
    }
    if(status!='') {
      smap['status__in'] = ['$status'];
    }

    await adminServices.listRecommendeds(smap);
    adminServices.list_recommendeds.forEach((g){
      if(g['trip_id']!=null){
        Map<String,dynamic> trip = {};
        adminServices.trips.get(g['trip_id']['_id'], {'populate':'car_id:info'}).then((request) {
          trip = jsonDecode(request.responseText);
          g['trip__status']=false;
          g['car_info']=trip['car_id']!=null ? trip['car_id']['info'] : null;
        }, onError: (e) {
          adminServices.evaluateError(e);
        });
      }
      else{
        g['trip__status']=true;
      }
    });
//    }
//    tab=true;
  }

  void archivedModal(archived) {
    archived_id=archived;
    js.context.callMethod(r'$', ['#archivedModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  void viewTripModal() {
    js.context.callMethod(r'$', ['#viewTripModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

//  void activateModal(Map item) {
//    itemModal = item;
//    js.context.callMethod(r'$', ['#cancelModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
//  }

//  void setCancelTrip() {
//    trips.put('${itemModal['_id']}/cancelled', {}).then((request) {
//      var t = jsonDecode(source)(request.responseText);
//      searchTrips(n);
//    }, onError: (e) {
//      evaluateError(e);
//    });
//    js.context.callMethod(r'$', ['#cancelModal']).callMethod('modal', ['hide']);
//  }

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
      'return': 'email,alliance_id,costs_centers_ids,personal_info,type_user,active,routes',
      '_or': 'personal_info.firstname,personal_info.lastname,personal_info.phone,email'
    }.cast<String,dynamic>());
  }


  void selectPassengersModal() {
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
    q = '';
    searchAlliance();
    js.context.callMethod(r'$', ['#AllianceModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  // centro de costos

  void searchCostCenter() {
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


  void selectCostCenterModal() {
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
    n=1;
    if (a == 'alliance') {
      alliance_item = {};
    } else if (a == 'costcenter') {
      costcenter_item = {};
    } else {
      passenger_item = {};
    }
  }

  void previewModal(gp){
    group=gp;
    shadow_passenger = '';
    routesEstimate(group);
    passengers_group = jsonEncode(group);

    js.context.callMethod(r'$', ['#previewModal']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  void preload(){
    newTripPost(group);
  }

  Marker createMarker(Map address_common) {
    marker = Marker(MarkerOptions()
      ..optimized = false
      ..draggable = false
      ..title = address_common['address']
      ..map = map
      ..position = LatLng(address_common['position'][0],address_common['position'][1])
//      ..position = LatLng(4.575026,-74.134728)
      ..icon = (Icon()
        ..url =  address_common['type_route'] == 'oneforall' ? 'assets/icons/trip/map/ic_marker_origin_anim.gif' : 'assets/icons/trip/map/ic_marker_destination_anim.gif'
        ..scaledSize = Size(32, 32)));
    map.center = LatLng(address_common['position'][0],address_common['position'][1]);
    map.zoom = 14;

    return marker;
  }

  Marker stops_mark;

  Future stops_marker(lat,lng,address,dat) async {
    stops_mark = Marker(MarkerOptions()
      ..optimized = false
      ..map = map
      ..position = LatLng(lat,lng)
      ..title = address
      ..icon = (Icon()
        ..url = 'assets/icons/trip/map/stops.png'
        ..scaledSize = Size(32, 32)));
    if (stop_markers.isNotEmpty) {
      stops_mark.set(
          'icon',
          (Icon()
            ..url = 'assets/icons/trip/map/stops.png'
            ..scaledSize = Size(32, 32)));
      stop_markers.insert(stop_markers.length - 1, stops_mark);
    } else {
      stop_markers.add(stops_mark);
    }

    stops_mark.onClick.listen((e) {
      shadow_passenger = dat['_id'];
    });

    return stops_mark;
  }

  void addMarkerStops() {
    if(stops_mark!=null) {
      stops_mark.set('map', null);
    }
    if(preview['passengers'].length>0) {
      preview['passengers'].forEach((m){
        stops_marker(m['pickup_location'][0], m['pickup_location'][1],m['pickup_address'],m['passenger_id']);
      });
    }
  }

  void archived(){
    adminServices.recommendeds.put(archived_id, {'status':'archived'}).then((request) {
      searchGroups(n);
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void showErros(var e) {
    switch (e['title']) {
      case 'typeServiceIdRequired':
        msg_error = 'Debe seleccionar un Tipo de Servicio';
        break;
      case 'stopsNotReady':
      case 'startPickupLocationRequired':
        msg_error = 'Puntos de partida, destino y paradas no estan confirmadas';
        break;
      case 'valuesInit':
        msg_error = 'Debe seleccionar pasajero y/o un centro de costo';
        break;
      case 'guestNameRequired':
      case 'guest':
        msg_error = 'Debe completar los datos personales del invitado';
        break;
      case 'notCostsCenters':
        msg_error = 'No hay centros de costos';
        break;
      case 'notCreditCard':
        msg_error = 'No tiene una tarjeta de cédito agregada';
        break;
      case 'user':
        msg_error = 'Su perfil de usuario solo permite viajes personales';
        break;
      case 'concept':
        msg_error =
        'Es obligatorio ingresar el concepto para este viaje, ej: visita a cliente';
        break;
      case 'type_trip':
        msg_error = 'Seleccione el tipo de viaje';
        break;
      case 'completeDate':
        msg_error = 'Por favor complete la fecha';
        break;
      case 'dateIsInPass':
        msg_error = 'La fecha que ha seleccionado esta en el pasado';
        break;
      case 'userSuspended':
        msg_error = 'Tarjeta de crédito bloqueada';
        break;
      case 'creditCardSuspended':
        msg_error = 'Tarjeta de crédito bloqueada';
        break;
      case 'addressError':
        msg_error = 'La dirección de destino debe ser diferente a la de origen';
        break;
      case 'passengersError':
        msg_error = 'Para obtener una estimación debe de seleccionar al menos un pasajero.';
        break;
      case 'emailNotValid':
        msg_error =
        'El correo del invitado no es válido, ingrese uno valido o en caso de no tener use el correo "sincorreo@miaguila.com"';
        break;
      case 'notServiceInTheZone':
        msg_error =
        'Intente nuevamente.';
        break;
      default:
        msg_error = e['title'];
    }
    js.context.callMethod(r'$', ['#tripNewError']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  void routesEstimate([Map trip]) {
    int n = 0;
    markers.forEach((Marker item) {
      if (item.position != null) {
        n++;
      }
    });
    List<Marker> temp_m = List.from(stop_markers);
    num a = temp_m.length-1;
    temp_m.forEach((stop){
      stop_markers[a].set('map', null);
      stop_markers.removeAt(a);
      a--;
    });
    if(marker!=null){
      marker.set('map', null);
    }
//    marker.set('map', null);
//    estimate_path.set('map', null);
    estimate_path.visible=false;

    Map<String,dynamic> options = {
      'alliance_id':trip['alliance_id']['_id'],
      'category':'route',
      'type_service_id': trip['type_car_id'],
      'type_trip': trip['type_service'],
      'points': [trip['alliance_address']['position']],
      'type_route':trip['type_route'],
      'service_trip': {},
      'passengers':[],
    };

//    options['alliance_id']=User.user['alliance_id']['_id'];
//    if (options['service_trip']['know_driver']==true){
//      options['service_trip']['pool']=false;
//      options['service_trip']['places']=null;
//    }
//
//    if (options['service_trip']['pool']==true) {
//      options['service_trip']['know_driver'] = false;
//    }
//
//    if (options['service_trip']['know_driver']==false && options['service_trip']['pool']==false){
//      options['service_trip']={};
//    }

    if(trip['passengers'].isEmpty){
      return showErros({'title': 'passengersError'});
    }
    else{
      trip['passengers'].forEach((p) {
        options['passengers'].add({'name':p['passenger_id']['personal_info']['firstname'].toString()+' '+p['passenger_id']['personal_info']['lastname'].toString(),'passenger_id':p['passenger_id']['_id'], 'pickup_address':p['address']['address'], 'pickup_location':p['address']['position']});
      });

    }
    options['pay'] = 'alliance';

    adminServices.trips.postGet('estimate', options).then((request) {
      estimate = jsonDecode(request.responseText);
      trip['total']=estimate['price']['total'];
      trip['distance']=estimate['distance'];
      trip['time']=estimate['time'];
      trip['path']=estimate['path'];
      adminServices.recommendeds.put(trip['_id'], {'total':trip['total'], 'distance':trip['distance'], 'time':trip['time'], 'path':trip['path']}).then((request) {
      }, onError: (e) {
        processing = false;
        HttpRequest request = e.target;
        showErros(jsonDecode(request.responseText));
      });
      //ruta estimada origen destino
      List path = encoding.decodePath(estimate['path']);
      estimate_path.path = path;
      estimate_path.visible=true;
      preview['passengers']=estimate['passengers'];
      if (trip != null) {
        createMarker({'position': trip['alliance_address']['position'], 'address': trip['alliance_address']['address'],'type_route': trip['type_route']});
        addMarkerStops();

      }
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void newTripPost(dat) {
    Map<String,dynamic> route = {};
    processing = true;
    block=true;
    route['passengers']=[];
    route['category']='route';
    route['alliance_id']=dat['alliance_id']['_id'];
    route['concept']='Ruta automática';
    route['cost_center_id']=dat['cost_center_id']['_id'];
    route['end']={};
    route['passenger_id']=user['_id'];

    dat['passengers'].forEach((p) {
      route['passengers'].add({'passenger_id':p['passenger_id']['_id'], 'pickup_address':p['address']['address'], 'pickup_location':p['address']['position']});
    });

    if(dat['type_route']=='allforone'){
      route['type_route']='allforone';
      route['start']={'date': dat['date']};
      route['end']={'pickup_location': dat['alliance_address']['position'], 'pickup_address': dat['alliance_address']['address']};
    }
    if(dat['type_route']=='oneforall'){
      route['type_route']='oneforall';
      route['start']={'date': dat['date'], 'pickup_location': dat['alliance_address']['position'], 'pickup_address': dat['alliance_address']['address'], 'marker_location': dat['alliance_address']['position'], 'real_location': dat['alliance_address']['position']};

    }
    route['type_service_id']=dat['type_car_id'];
    route['type_trip']='reservation';
    route['pay']='alliance';
    route['is_massive_routes']=true;

    adminServices.trips.post(route).then((request) {
      Map data = jsonDecode(request.responseText);
      processing = false;
      current_trip=data['result']['ops'][0]['_id'];
      adminServices.recommendeds.put(dat['_id'], {'status':'requested', 'trip_id':data['result']['ops'][0]['_id']}).then((request) {
        searchGroups(n);
        viewTripModal();
        block=false;
        js.context.callMethod(r'$', ['#previewModal']).callMethod('modal', ['hide']);
      }, onError: (e) {
        processing = false;
        HttpRequest request = e.target;
        showErros(jsonDecode(request.responseText));
      });


    }, onError: (e){
      processing = false;
      HttpRequest request = e.target;
      showErros(jsonDecode(request.responseText));
    });
  }

  // generate excel
  void generateFile() {
    alliances_all.add(user['alliance_id']['_id']);
//    alliances_all.add('5b280c7f258acf3b006c32e8');
    js.context.callMethod(r'$', ['#downloadModal']).callMethod('modal', ['hide']);
    user['routes_report']['percent'] = 0.1;
    user['routes_report']['generated'] = false;
    user['routes_report']['file_url'] = '';
    generate = true;
//    download = false;
    Map<String,dynamic> smap = {'_sort': '-end.date'};
    smap['alliance_id__in'] = alliances_all.join(',');
    smap['cost_center_id__ne'] = 'null';
    smap['status__in'] = 'created,finding,reserving,reserved,starting,onWay,near,arrived,started';

    if (costcenter_item.containsKey('_id')) {
      smap['cost_center_id'] = costcenter_item['_id'];
    }

    if (alliance_item.containsKey('_id')) {
      smap['alliance_id'] = alliance_item['_id'];
    }

    if (passenger_item.containsKey('_id')) {
      smap['passengers.passenger_id'] = passenger_item['_id'];
    }

    if (month_from != '00') {
      String date = '$year-$month_from-$day_from';
      date = js.context.callMethod('moment', [date]).callMethod('toISOString');

      smap['end.date__gte'] = js.context.callMethod('moment', [date]).callMethod('toISOString');
    } else {
      smap['end.date__gte'] = js.context.callMethod('moment', []).callMethod('toISOString');
    }

    if (month_to != '00') {
      String date = '$year-$month_to-$day_to';
      date = js.context.callMethod('moment', [date]).callMethod('toISOString');

      smap['end.date__lt'] = js.context.callMethod('moment', [date]).callMethod('add', [1, 'day']).callMethod('toISOString');
    } else {
      smap['end.date__lt'] = js.context.callMethod('moment', []).callMethod('add', [1, 'day']).callMethod('toISOString');
    }
    if(type_route!='') {
      smap['type_route'] = type_route;
    }

    List<String> data = [];
    wordsOptions.forEach((w) {
      if (w['v']) {
        data.add(w['name']);
      }
    });
    adminServices.downloadActives(smap, data);
    timer_ap2 = Timer(Duration(seconds: 5), () {
      timer_ap2.cancel();
      if (RegExp(r'routes/list_routes_user_groups').hasMatch(Uri.base.toString())) {
        getUser();
      }
    });
  }

  void modalDowmload() {
    js.context.callMethod(r'$', ['#downloadModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  void getUser() {
    user['routes_report']['percent']=0;
    adminServices.users.get(user['_id'], {'return': 'routes_report'}).then((request) {
      Map data = jsonDecode(request.responseText);
      data = data.containsKey('routes_report') ? data : {'routes_report': {}};
      user['routes_report']['percent'] = data['routes_report'].containsKey('percent') ? data['routes_report']['percent'] : 0;
      user['routes_report']['expires'] = data['routes_report'].containsKey('expires') ? data['routes_report']['expires'] : '';
      user['routes_report']['timeout'] = data['routes_report'].containsKey('timeout') ? data['routes_report']['timeout'] : '';
      user['routes_report']['generated'] = data['routes_report'].containsKey('generated') ? data['routes_report']['generated'] : false;
      user['routes_report']['file_url'] = data['routes_report'].containsKey('file_url') ? data['routes_report']['file_url'] : '';
      var timeout = js.context.callMethod('moment', [user['routes_report']['timeout']]).callMethod('diff', [js.context.callMethod('moment', []), 'minutes']);
      if (user['routes_report']['timeout'] != '' && user['routes_report']['percent'] > 0 && user['routes_report']['percent'] < 100 && timeout <= 0) {
        user['routes_report']['percent'] = 0;
        user['routes_report']['expires'] = '';
        user['routes_report']['generated'] = false;
        user['routes_report']['file_url'] = '';
        generate = false;
        download = true;
      } else {
        generate = !(user['routes_report']['percent'] == 0 || user['routes_report']['percent'] == 100);
        var days = js.context.callMethod('moment', [user['routes_report']['expires']]).callMethod('diff', [js.context.callMethod('moment', []), 'days']);
        if (days <= 0) {
          download = true;
        } else {
          download = !user['routes_report']['generated'];
        }
        if (user['routes_report']['percent'] != null && user['routes_report']['percent'] == 100 && timer_ap != null) {
          timer_ap2.cancel();
        }
        if (user['routes_report']['percent'] == 100) {
          download=true;
//          Window dialog = window.open('components/dashboard/services/routes/upload_routes_users.html','') as Window; // forced cast
//          dialog.resizeTo(400,400);
          var windowObjectReference;
          void openRequestedPopup() {
            windowObjectReference = window.open(
                user['routes_report']['file_url'],
                "_blank",
                "resizable,scrollbars,status"
            );
          }
          openRequestedPopup();
        }
        if (user['routes_report']['percent'] > 0 && user['routes_report']['percent'] < 100) {
          timer_ap2 = Timer(Duration(seconds: 5), () {
            timer_ap2.cancel();
            if (RegExp(r'routes/list_routes_user_groups').hasMatch(Uri.base.toString())) {
              getUser();
            }
          });
        }
      }
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void passengersUpdateModal(item) {
    group_id=item;
    searchPassagers();
    js.context.callMethod(r'$', ['#previewModal']).callMethod('modal', ['hide']);
    js.context.callMethod(r'$', ['#passengersUpdateModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  void changeDateModal(item_date) {
    group_id=item_date;
    update = js.context.callMethod('moment', [item_date['date']]).callMethod('format', ['YYYY-MM-DDTHH:mm']);
    js.context.callMethod(r'$', ['#changeDateModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  void updateDateGroup(){
    processing = true;
    adminServices.recommendeds.put(group_id['_id'], {
      'date': js.context.callMethod('moment', [update]).toString(),
      'status': 'grouped'
    }).then((request) {
      searchGroups(n);
      js.context.callMethod(r'$', ['#changeDateModal']).callMethod('modal', ['hide']);
    }, onError: (e) {
      processing = false;
      HttpRequest request = e.target;
      showErros(jsonDecode(request.responseText));
    });
  }

  void removePassenger(rp){
    group_id['passengers'].remove(rp);
  }

  void addPassenger(ap){
    Map<String,dynamic> user_add = {
      'passenger_id': {
        '_id': ap['_id'],
        'email': ap['email'],
        'personal_info': {
          'firstname': ap['personal_info']['firstname'],
          'lastname': ap['personal_info']['lastname'],
          'name': ap['personal_info']['name'],
          'phone': ap['personal_info']['phone'],
          'phone_country': ap['personal_info']['phone_country'],
          'image': ap['personal_info']['image']
        }.cast<String,dynamic>()
      },
      'address': {
        'type': ap['routes'][0]['type'],
        'name': ap['routes'][0]['name'],
        'address': ap['routes'][0]['address'],
        'position': ap['routes'][0]['position']
      }
    };

    group_id['passengers'].add(user_add);
  }

  void updatePassengers() {
    processing = true;
    adminServices.recommendeds.put(group_id['_id'], {'passengers':group_id['passengers']}).then((request) {
      searchGroups(n);
      js.context.callMethod(r'$', ['#passengersUpdateModal']).callMethod('modal', ['hide']);
    }, onError: (e) {
      processing = false;
      HttpRequest request = e.target;
      showErros(jsonDecode(request.responseText));
    });
  }

}
