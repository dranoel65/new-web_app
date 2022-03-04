import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;


import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:google_maps/google_maps.dart';
import 'package:google_maps/google_maps_geometry.dart';
import 'package:google_maps/google_maps_places.dart';
import 'package:web_app/classes/User.dart';
import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../../../../config.dart';
import '../trips.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(selector: 'new-route',
    styleUrls: ['../new.css'],
    templateUrl: 'new_route.html',
    directives: [coreDirectives, formDirectives, MenuTopComponent],
    pipes: [
      CurrencyPipe,
      GetErrorsPipe,
      MoneyPipe,
      IdPipe,
      NamePipe,
      I18NPipe,
      DateFormatPipe
    ],
    exports: [RoutePaths, Routes])
class NewRouteComponent extends TripsComponent implements OnActivate {
  Config config = Config();
  String q = '';
  bool favorite_address = false;
  Map select_region = null;

  Timer timer;

  List<dynamic> stops = [];
  List<Autocomplete> autocompletes = [];
  String new_id = 'xxxxxxxx';
  String msg_error = '';

  Map trip = {
    'start': {},
    'end': {},
    'type_trip': 'instantly',
    'service_trip': {'pool': false, 'places': 1, 'know_driver': false}
  };

  //gmaps
  GMap map;
  String xcenter = '';
  LatLng center = LatLng(4.6634163, -74.0920055);
  final mapOptions = MapOptions()
    ..styles = Config.mapStyles
    ..zoom = 12
    ..streetViewControl= false;

  Map passenger;
  Map cost_center;
  List<dynamic> favorite;
  Map guest;
  List <dynamic> map_services;
  String type_service_id;
  String type_trip;
  String who = 'me';
  String meridiem = 'AM';
  String user_id = '';

  Map time = {'hour': 1, 'minute': 0};

  List<String> days = [];
  String month = '',
      day = '';
  bool route_trip = false;
  String type_route = 'oneforall';
  String select_route = '';
  List<dynamic> passengers = [];
  List<dynamic> list_services_copy = [];
  List<dynamic> address =[];
  Map passenger_map = {};
  List<Marker> stop_markers = [];
  String passenger_ok = '';
  String text = '';
  List<dynamic> stops_marker_routes = [];
  List<dynamic> geo_data = [];
  List<dynamic> addressGeo = [];
  List<dynamic> availableServices = [];
  List<String> availableTypeTrip = [];
  Timer timer_search;
  Map preloaded_passengers = {};
  Map user_dat = {'credit_card_id': null, 'type_user': 'user'};
  bool know_driver = false;
  String g = '';

  GSymbol icon() {
    GSymbol icon = GSymbol()
      ..path = SymbolPath.CIRCLE
      ..strokeColor = '#00cc99'
      ..strokeWeight = 2
      ..fillColor = '#000000'
      ..fillOpacity = 0
      ..scale = 5;
    return icon;
  }

  @override
  void onActivate(_, RouterState current) {
    preloaded_passengers = current.parameters['preLoad'] == ':preLoad' ? {} : jsonDecode(current.parameters['preLoad']);
    preLoadPassengers();
  }

  NewRouteComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    //valores por defecto
    trip['category']='route';
    var fullHeight = window.screen.available != null ? window.screen.available
        .height : 547;
    js.context.callMethod(r'$', ['#map-container']).callMethod(
        'css', ['max-height', '${fullHeight - 47}px']);
    js.context.callMethod(r'$', ['#map-canvas']).callMethod(
        'css', ['height', '${fullHeight - 47}px']);
    js.context.callMethod(r'$', ['#menu']).callMethod(
        'css', ['max-height', '${fullHeight - 47}px']);

    trip['alliance_id'] = User.user['alliance_id'];
    g = User.user['alliance_id']['_id'];

    adminServices.alliances.get(trip['alliance_id']['_id'], {
      'return': 'legal,alliance_father_id,pool_active,service_trip',
      'populate': 'alliance_father_id:smarkerservice_trip,legal'
    }).then((request) {
      Map child_alliance = jsonDecode(request.responseText);
      if (child_alliance['alliance_father_id'] == null &&
          child_alliance.containsKey('service_trip')) {
        know_driver = child_alliance['service_trip']['know_driver'];
      }
      else {
        if (child_alliance['alliance_father_id'].containsKey('service_trip')) {
          know_driver =
          child_alliance['alliance_father_id']['service_trip']['know_driver'];
        }
      }
    }, onError: (e) {
      adminServices.evaluateError(e);
    });

    passenger = User.user;
    trip['passenger_id'] = User.user['_id'];
    new_route=true;

    timer = Timer(Duration(seconds: 1), () {
      var mc = querySelector("#map-canvas");
      if (mc != null) {
        timer.cancel();
        map = GMap(mc, mapOptions);
        map.center = center;

        createStop('Origen', 'Origen Común');
//        createStop('Destino', 'Destino Común');

        estimate_path = Polyline(PolylineOptions()
          ..geodesic = true
          ..strokeColor = '#0404B4'
          ..strokeOpacity = 1.0
          ..strokeWeight = 2
          ..map = map);

     }
    });

    adminServices.regions.query({'active':'true','return': 'name,center'}).then((request) {
      Map data = jsonDecode(request.responseText);
      adminServices.list_regions = data['result'];
      Map first = adminServices.list_regions.first;
      //center = LatLng(first['center'][0], first['center'][1]);
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
    var news = adminServices.userMe({
      'return': 'type_user,balance,credit_card_id',
      'populate': 'credit_card_id:type,number,name'
    });

    news.then((request) {
      Future(() {
        user_dat = jsonDecode(request.responseText);
      });
    }, onError: (e) {
      router.navigate(RoutePaths.login.toUrl());
    });

    var now = DateTime.now();
    DateTime moonLanding = DateTime.parse(now.toString());

    day =
    moonLanding.day < 10 ? '0${moonLanding.day.toString()}' : moonLanding.day
        .toString();
    month = months[moonLanding.month]['v'];

    for (int a = 1; a <= this.changeM(month); a++) {
      days.add(a < 10 ? '0${a.toString()}' : a.toString());
    }
  }

  void preLoadPassengers() {
    if(preloaded_passengers.isNotEmpty) {
      passengers = preloaded_passengers['passengers'].map((passenger) => {
        '_id': passenger['passenger_id']['_id'],
        'personal_info': passenger['passenger_id']['personal_info'],
        'alliance_id': preloaded_passengers['alliance_id'],
        'route': [{
          'name': passenger['address']['name'],
          'address': passenger['address']['address'],
          'position': passenger['address']['position']
        }],
      });
    }
    passengers = passengers.toList();
  }

  Future stops_routes(stop) async {
    Marker stops_marker_routes = Marker(MarkerOptions()
      ..optimized = false
      ..map = map
      ..position = stop == null ? LatLng(4.6634163, -74.0920055) : LatLng(stop['point'][0], stop['point'][1])
      ..title =  stop == null ? '' : stop['name']
      ..icon = icon()
    );

    if(stop!=null) {
      stops_marker_routes.icon =  icon();
      event.addDomListener(map, 'onKeyDown', (key){ if (key.keyCode == 27) { infowindow.close(); } });
      stops_marker_routes.onClick.listen((e) {
        infowindow.open(map, stops_marker_routes);
        infowindow.content =
        '<div class="row info-monitor pl-3 pt-2 pre-scrollable space">'
            '<div class="col-12 space">${stop['name']}'
            '</div>';
      });
      stop_markers.add(stops_marker_routes);
      return stop_markers;
    }
    else{
      return stop_markers=[];
    }
  }

  Future autoSelectStopMarker(marker_i, Map item) async {
    map.zoom = 16;
    if(marker_i==0){
      stops[0]['location'] = [item['point'][0], item['point'][1]];
      markers[0].position = LatLng(item['point'][0], item['point'][1]);
      markers[0].map = map;
      infowindow.content = item['name'];
      infowindow.open(map, markers[0]);
      document.getElementById('label_address_0').innerHtml = item['name'];
      stops.first['address']=item['name'];

      routesEstimate(trip, stops, month, day, time, meridiem);

      map.center = LatLng(item['point'][0], item['point'][1]);
      hideAutocomplete(0,stops[0]['address']);
    }
    else if(marker_i==1){
      stops[1]['location'] = [item['point'][0], item['point'][1]];
      markers[1].position = LatLng(item['point'][0], item['point'][1]);
      markers[1].map = map;
      infowindow.content = item['name'];
      infowindow.open(map, markers[1]);
      stops[1]['address'] = infowindow.content;
      routesEstimate(trip, stops, month, day, time, meridiem);

      map.center = LatLng(item['point'][0], item['point'][1]);
      hideAutocomplete(1,stops[1]['address']);
    }
  }

  void scanStops(marker_i,lat,lng){
    adminServices.scan_map.scanMap('${lat},${lng}').then((request) {
      adminServices.list_scan_services = jsonDecode(request.responseText)['result'];
      if(adminServices.list_scan_services['stops'].length >0){
        adminServices.list_scan_services['stops'].forEach((stop){
          stops_routes(stop);
        });
        autoSelectStopMarker(marker_i, adminServices.list_scan_services['stops'][0]);
      }
      else{
        stop_markers.forEach((s){
          s.map=null;
        });
      }
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  // activa el efecto
  void accordionEvent() {
    querySelector('.accordionActive i').classes.toggle('rotate');
    querySelector('.accordionMenu').classes.toggle('hide');
    querySelector('#toolbarAccordion').classes.toggle('accordionCollapse');
  }

  //búsqueda del pasajero
  void selectPassengerModal() {
    q = '';
    searchPassengers();
    js.context.callMethod(r'$', ['#selectPassengerModal']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  //selección de dirección
  void selectAddressModal(Map a) {
    passenger_map=a;
    address=a['routes'];
    js.context.callMethod(r'$', ['#selectAddressModal']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
    js.context.callMethod(r'$', ['#selectUsersModal']).callMethod(
        'modal', ['hide']);
  }

  void selectPassenger(Map item) {
    passenger = item;
    trip['passenger_id'] = item['_id'];
    cost_center = null;
    trip['cost_center_id'] = null;
    js.context.callMethod(r'$', ['#selectPassengerModal']).callMethod(
        'modal', ['hide']);
  }

  List passengers_stops = [];
  Future searchPassengers() async {
    passengers_stops = [];
    await adminServices.listUsers({
      'personal_info.firstname__like': q,
      'personal_info.lastname__like': q,
      'email__like': q,
      'active': 'true',
      'routes__isnnull':'',
      'return': 'alliance_id,personal_info.firstname,personal_info.lastname,email,personal_info.image,active,costs_centers_ids,type_user,routes',
      'populate':'alliance_id:legal',
      '_or': 'personal_info.firstname,personal_info.lastname,email'
    });
    await adminServices.list_users.forEach((p){
      if(p['routes'].length>0){
        passengers_stops.add(p);
      }
    });
  }

  void selectUsers(Map item) {
    js.context.callMethod(r'$', ['#selectUsersModal']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
    passenger_map['route']=[item];
    if (passengers.length <= 3 || type_service_id == '5b858c124cd1e9101ef790ff') {
      List<dynamic> data_users = passengers.where((uu) => uu['_id'] == passenger_map['_id'])
          .toList();
      if (data_users.length == 0) {
        passengers.add(passenger_map);
      }
    } else {
      js.context.callMethod(r'$', ['#selectUsersModal']).callMethod(
          'modal', ['hide']);
      q='';
      passenger_ok='';
    }
    address=[];
    passenger_ok = 'Pasajero '+passenger_map['personal_info']['firstname']+' '+passenger_map['personal_info']['lastname']+' agregado a la ruta exitosamente.';
    js.context.callMethod(r'$', ['#selectAddressModal']).callMethod(
        'modal', ['hide']);
  }

  void selectUsersModal() {
    q = '';
    searchPassengers();
    js.context.callMethod(r'$', ['#selectUsersModal']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  String target_trip ='';
  bool wait_temp = false;
  void temporalModal() {
    js.context.callMethod(r'$', ['#temporalModal']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  void updateTargetTrip(){
    wait_temp = true;
    Map target = {'passengers':[]};
    estimate['passengers'].forEach((p){
      target['passengers'].add({'passenger_id':p['passenger_id']['_id'], 'check':'completed', 'pickup_address':p['pickup_address'], 'pickup_location':p['pickup_location'], 'distance':p['distance'], 'duration':p['duration']});
    });
    target['type_route']='oneforall';
    target['category']='route';
//    target['passenger_id']=null;
    target['guest']={
      "name" : null,
      "phone" : null,
      "email" : null,
      "plate" : null,
      "model" : null,
      "color" : null
    };
    target['finished']={'estimate_time':estimate['time']*60, 'estimate_distance':estimate['distance']};
    target['path']=estimate['path'];
    target['tracks']=estimate['tracks'];
    target['charges']={
      'tracks_value':estimate['price']['tracks_value'],
      'base_start':estimate['price']['base_start'],
      'base_end':estimate['price']['base_end'],
      'night':3177,
      'minimum':estimate['price']['minimum'],
      'fixed_rate':estimate['price']['fixed_rate']
    };
    target['price']={
      'stops':estimate['price']['stops'],
      'stop_value':estimate['price']['stop_value'],
      'trip':estimate['price']['total'],
      'driver_total':(estimate['time']*170)+((estimate['distance']/1000)*900)+7000,
      'driver_subtotal':(estimate['time']*170)+((estimate['distance']/1000)*900)+7000,
      'user_total':(estimate['price']['total']+3200) > 25000 ? estimate['price']['total']+3200 : 25000,
      'user_subtotal':(estimate['price']['total']+3200) > 25000 ? estimate['price']['total']+3200 : 25000,
    };
    target['statistics']={'distance':estimate['distance'], 'time':estimate['time']};
    adminServices.trips.put(target_trip, target).then((request) {
      var t = jsonDecode(request.responseText);
      wait_temp = false;
      js.context.callMethod(r'$', ['#temporalModal']).callMethod('modal', ['hide']);
    }, onError: (e) {
      adminServices.evaluateError(e);
      wait_temp = false;
    });

  }

  //búsqueda del centro de costo
  void selectCostCenterModal(String ud) {
    user_id = ud;
    q = '';
    if (!searchCostsCenters(user_id)) {
      return showErros({'title': 'notCostsCenters'});
    }
    js.context.callMethod(r'$', ['#selectCostCenterModal']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  void selectCostCenter(Map item) {
    cost_center = item;
    trip['cost_center_id'] = item['_id'];
    js.context.callMethod(r'$', ['#selectCostCenterModal']).callMethod(
        'modal', ['hide']);
  }

  bool searchCostsCenters(String user_id) {
    adminServices.costs_centers.get('valid-user/${user_id}',
        {
          'active': 'true',
          'name__like': q.trim(),
          'tags__in': q.trim(),
          '_limit': '500',
          'return': 'name,active,alliance_father_id,credit_card_id,tags',
          'populate': 'alliance_father_id:legal.name|credit_card_id:number',
          '_sort': 'name',
          '_or': 'name,tags'
        }).then((request) {
      Map data = jsonDecode(request.responseText);
      adminServices.list_costs_centers = data['result'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
    return true;
  }

  num a;

  //búsqueda de favoritos
  void selectFavoritesModal(num id) {
    a = id;
    q = '';
    searchFavorites();
    js.context.callMethod(r'$', ['#selectFavoritesModal']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  Future selectFavorites(Map item) async {
    favorite_address = true;
    if (a == 0) {
      stops[0]['location'] =
      [item['start']['position'][0], item['start']['position'][1]];
      markers[0].position =
      LatLng(item['start']['position'][0], item['start']['position'][1]);
      markers[0].map = map;
      infowindow.content = item['start']['address'];
      infowindow.open(map, markers[0]);
      document.getElementById('label_address_0').innerHtml =
      item['start']['address'];
      (document.getElementById('stop_0') as InputElement).value = item['start']['address'];
      stops.first['address'] = item['start']['address'];

      map.center =
      LatLng(item['start']['position'][0], item['start']['position'][1]);
      hideAutocomplete(0, stops[0]['address']);
    }
    findTypesServices(item['start']['position'][0], item['start']['position'][1]);

    js.context.callMethod(r'$', ['#selectFavoritesModal']).callMethod(
        'modal', ['hide']);
  }

  void end_position(Map item) {
    stops[1]['location'] =
    [item['end']['position'][0], item['end']['position'][1]];
    markers[1].position =
    LatLng(item['end']['position'][0], item['end']['position'][1]);
    markers[1].map = map;
    infowindow.content = item['end']['address'];
    infowindow.open(map, markers[1]);

    double lats = 0.0;
    double lngs = 0.0;
    int n = 0;

    markers.forEach((Marker item) {
      if (item.position != null) {
        lats += item.position.lat;
        lngs += item.position.lng;
        n++;
      }
    });
    //centra el mapa
    if (n > 0) {
      map.center = LatLng(lats / n, lngs / n);
    }
    hideAutocomplete(1, stops[0]['address']);
  }

  void searchFavorites() {
    Map<String,dynamic> dat = {
      'alliance_id': User.user['alliance_id']['_id'],
      'user_id': User.user['_id'],
      'active': 'true',
      'return': 'name,start.position,start,end,alliance_id',
      '_or': 'alliance_id,user_id'
    };

    if (q != '') {
      dat['name__like'] = q;
    }
    adminServices.favorites.query(dat).then((request) {
      Map data = jsonDecode(request.responseText);
      favorite = data['result'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void resetPassenger() {
    guest = {};
    trip['guest'] = {};
    passenger = null;
    trip['passenger_id'] = null;
  }

  void resetGuest() {
    guest = null;
    trip['guest'] = null;
    passenger = User.user;
    trip['passenger_id'] = User.user['_id'];
  }

  void resetCostCenter() {
    cost_center = null;
    trip['cost_center_id'] = null;
  }

  void findTypesServices(num lat, num lng) {
    availableServices.clear();
    availableTypeTrip.clear();
    type_service_id = null;
    trip['type_service_id'] = null;

    trip['type_trip'] = null;
    type_trip = null;

    adminServices.scan_map.scanMap('${lat},${lng}').then((request) {
      adminServices.list_services = jsonDecode(request.responseText)['result']['services'];
      adminServices.list_services.forEach((service)
      {
        availableServices.add(service['_id']);
      });
      type_service_id = adminServices.list_services.isEmpty ? '' : adminServices.list_services?.first['_id'];
      setTypeService(type_service_id);

    }, onError: (e) {
      adminServices.evaluateError(e);
    });

  }

  void showAutocomplete(i) {
    document.getElementById('label_${i}').hidden = true;
    (document.getElementById('stop_${i}') as InputElement).hidden = false;
    (document.getElementById('btn_${i}') as ButtonElement).hidden = false;
    stops[i]['ready'] = false;
  }

  void hideAutocomplete(i, text){
    if (favorite_address != true) {
      document.getElementById('label_address_${i}').innerHtml = text;
    }
    document.getElementById('label_${i}').hidden = false;
    (document.getElementById('stop_${i}') as InputElement).hidden = true;
    (document.getElementById('btn_${i}') as ButtonElement).hidden = true;
    stops[i]['ready'] = true;
    favorite_address = false;
  }

  void removeStop(i) {
    stops.removeAt(i);
    markers[i].set('map', null);
    markers.removeAt(i);
  }

  void selectTypeRoute() {
    markers[0].icon=(Icon()
      ..url = changeTypeRoute()
      ..scaledSize = Size(32, 32));
  }

  String changeTypeRoute(){
    if(type_route=='oneforall'){
      return 'assets/icons/trip/map/ic_marker_destination_anim.gif';
    }
    if(type_route=='allforone'){
      return 'assets/icons/trip/map/ic_marker_origin_anim.gif';
    }
  }

  void createMarker(i) {
    Marker marker = Marker(MarkerOptions()
      ..optimized = false
      ..draggable = true
      ..icon = (Icon()
        ..url = 'assets/icons/trip/map/ic_marker_origin_anim.gif'
        ..scaledSize = Size(32, 32)));

    marker.onDragend.listen((_) {

      adminServices.geo.get('reverse-geocode', {
        'lat': marker.position.lat.toString(),
        'lng': marker.position.lng.toString()
      }).then((request) {
        Map data = jsonDecode(request.responseText);
        if (data['result'].isEmpty) {
          return window.alert('No hay resultados');
        }
        hideAutocomplete(i, data['result']['address']);
        stops[i]['address'] = data['result']['address'];
        stops[i]['location'] = [marker.position.lat, marker.position.lng];
        (document.getElementById('stop_${i}') as InputElement).value=data['result']['address'];

        infowindow.content = data['result']['address'];
        infowindow.open(map, marker);

        routesEstimate(trip, stops, month, day, time, meridiem);

        if (i == 0) {
          findTypesServices(marker.position.lat, marker.position.lng);
        }
        scanStops(i,marker.position.lat, marker.position.lng);
      }, onError: (e) {
        adminServices.evaluateError(e);
      });


    });

    markers.add(marker);
  }

  void geoSearch(dynamic event, i) {

    if(timer_search!=null){
      timer_search.cancel();
    }

    timer_search = Timer(Duration(seconds: 1), () {
      geo_data=[];
      var mc = querySelector('#stop_${i}');
      if (mc != null) {
        timer_search.cancel();
        String test = '#autocomple_' + i.toString();
        if (event.target.value
            .toString()
            .length > 0 && querySelector(test) != null) {
          if(i==0) {
            querySelector('#autocomple_0').style.display = "block";
          }
          else {
            querySelector('#autocomple_1').style.display = "block";
          }
        }
        else if (querySelector(test) != null) {
          if(i==0) {
            querySelector(test).style.display = "none";
          }
          else {
            querySelector(test).style.display = "none";
          }
        }


        adminServices.geo.get('addresses-places', {
          'keyword': event.target.value,
          'lat': map.bounds.center.lat.toString(),
          'lng': map.bounds.center.lng.toString()
        })
            .then((request) {
          if(jsonDecode(request.responseText)['result'].length>0) {
            addressGeo = jsonDecode(request.responseText)['result'];
            addressGeo.forEach((geo_address) {
              if (geo_address.containsKey('name')) {
                geo_data.add({
                  'formatted_address': geo_address['name'] + ', ' +
                      geo_address['vicinity'],
                  'geometry': geo_address['geometry']
                });
              }
              else {
                geo_data.add({
                  'formatted_address': geo_address['formatted_address'],
                  'geometry': geo_address['geometry']
                });
              }
            });
          }else{
            geo_data = [];
          }

        }, onError: (e) {
          adminServices.evaluateError(e);
        });

      } else {
        timer_search.cancel();
      }
    });

  }

  void loadAddress(address_item,i){
    String test = '#autocomple_' + i.toString();

    if(i==0) {
      querySelector(test).style.display = "none";
    }
    else {
      querySelector(test).style.display = "none";
    }

    //Pone la pos a el marker
    markers[i].position = LatLng(address_item['geometry']['location']['lat'], address_item['geometry']['location']['lng']);
    markers[i].map = map;

    double lats = 0.0;
    double lngs = 0.0;
    int n = 0;

    markers.forEach((Marker item) {
      if (item.position != null) {
        lats += item.position.lat;
        lngs += item.position.lng;
        n++;
      }
    });
    //centra el mapa
    if (n > 0) {
      map.center = LatLng(lats / n, lngs / n);
    }

    hideAutocomplete(i, address_item['formatted_address']);

    stops[i]['address'] = address_item['formatted_address'];
    stops[i]['location'] = LatLng(address_item['geometry']['location']['lat'], address_item['geometry']['location']['lng']);
    stops[i]['location']=[stops[i]['location'].lat.toString()+','+stops[i]['location'].lng.toString()];
    (document.getElementById('stop_${i}') as InputElement).value=address_item['formatted_address'];
    scanStops(i,address_item['geometry']['location']['lat'], address_item['geometry']['location']['lng']);
    if(i==0) {
      findTypesServices(
          address_item['geometry']['location']['lat'], address_item['geometry']['location']['lng']);
    }
    if(passengers.isNotEmpty){
      routesEstimate(trip, stops, month, day, time, meridiem);
    }
  }

  void createStop(String name, String name_route) {
    num i = stops.length;
    stops.add({
      'ready': false,
      'name': name,
      'name_route': name_route,
      'pickup_address': null,
      'pickup_location': null,
      'marker_location': null
    });

    createMarker(i);
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
    if (stop_markers.length !=0) {
      stops_mark.set(
          'icon',
          (Icon()
            ..url = 'assets/icons/trip/map/stops.png'
            ..scaledSize = Size(32, 32)));
      stop_markers.insert(stop_markers.length - 1, stops_mark);
    } else {
      stop_markers.add(stops_mark);
    }

    return stops_mark;

  }

  void addMarkerStops() {
    if(stops_mark!=null) {
      stops_mark.set('map', null);
    }
    if(trip['passengers'].length>0) {
      trip['passengers'].forEach((m){
        stops_marker(m['pickup_location'][0], m['pickup_location'][1],m['pickup_address'],m['personal_info']);
      });
    }
  }


  void setCenter() {
    Future(() {
      List<String> c = xcenter.split(',');
      map.center = LatLng(num.parse(c[0]), num.parse(c[1]));
    });
  }

  void setTypeService(typeServiceId) {
    availableTypeTrip.clear();
    type_service_id = typeServiceId;
    trip['type_trip'] = null;
    Future(() {
      trip['type_service_id'] = type_service_id;
      map_services =
      adminServices.list_services.firstWhere((item) => item['_id'] == trip['type_service_id'],
          orElse: () => {'services': []})['services'];
      map_services.forEach((type) {
        availableTypeTrip.add(type['name']);
      });

      type_trip = typeServiceId.isEmpty ? '' : (map_services?.first)['name'];
      trip['type_trip'] = type_trip;
//      if(map_services.length==1){
//        map_services =
//        [map_services[0], {'name': 'route', 'hours': 3}];
//
//      }else{
//        map_services =
//        [map_services[0], map_services[1], {'name': 'route', 'hours': 3}];
//      }
    });
  }

  void setTypeTrip(type) {
    type_trip = type;
    Future(() {
      trip['type_trip'] = type_trip;
    });
  }

  void selectUsersRoute() {
    resetPassenger();
    resetCostCenter();
    resetGuest();
    resetCostCenter();
    selectPassengerModal();
  }

  void setWho() {
    Future(() {
      switch (who) {
        case 'me':
          resetGuest();
          resetCostCenter();
          break;
        case 'guest':
          resetPassenger();
          resetCostCenter();
          break;
        case 'users':
          resetGuest();
          resetCostCenter();
          selectPassengerModal();
          break;
      }
    });
  }

  void setPay() {
    Future(() {
      //_who = who;
      switch (pay) {
        case 'tc':
          resetCostCenter();
          break;
        case 'alliance':
          selectCostCenterModal(User.user['_id']);
          break;
      }
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
      case 'limitChairsExceeded':
        msg_error =
        'La cantidad de pasajeros excede el cupo del vehículo.';
        break;
      default:
        msg_error = e['title'];
    }
    js.context.callMethod(r'$', ['#tripNewError']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  void goTrip(String trip_id) {
    js.context.callMethod(r'$', ['#tripNewSuccessful']).callMethod(
        'modal', ['hide']);

    router.navigate(RoutePaths.view_edit_trip.toUrl(parameters: {idParam: trip_id}));
  }

  void change() {
    window.console.log(month);
    days.clear();

    Future(() {
      if (month != '00') {
        for (int a = 1; a <= this.changeM(month); a++) {
          days.add(a < 10 ? '0${a.toString()}' : a.toString());
        }
        day = '01';
      }
    });
  }

  void routesEstimate([Map trip, List<dynamic> stops, String month, String day, Map time, String meridiem]) {
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
//    estimate_path.set('map', null);
    estimate_path.visible=false;

//    if (n <= 0 || new_route) {
//      return null;
//    }
    if (trip['alliance_id'] == null || trip['passenger_id'] == null) {
      return null;
    }
    List points = [];
    markers.forEach((Marker marker) {
      var m = marker.position;
      points.add([m.lat, m.lng]);
    });
    Map<String,dynamic> options = {
      'type_service_id': trip['type_service_id'],
      'type_trip': trip['type_trip'],
      'points': points,
      'service_trip': {},
      'passengers':[],
      'populate':'passengers+passenger_id:personal_info,email,alliance_id',
      'start': {'date': ''},
      'price': {'night': 0}
    };
    options['alliance_id']=User.user['alliance_id']['_id'];
    if (options['service_trip']['know_driver']==true){
      options['service_trip']['pool']=false;
      options['service_trip']['places']=null;
    }

    if (options['service_trip']['pool']==true) {
      options['service_trip']['know_driver'] = false;
    }

    if (options['service_trip']['know_driver']==false && options['service_trip']['pool']==false){
      options['service_trip']={};
    }

    if(passengers.isEmpty){
      return showErros({'title': 'passengersError'});
    }
    else{
      passengers.forEach((p) {
        options['passengers'].add({'name':p['name'],'passenger_id':p['_id'], 'pickup_address':p['route'][0]['address'], 'pickup_location':p['route'][0]['position'],'alliance_id':p['alliance_id']['_id']});
      });

//      options['passengers'].add({'passenger_id':p['_id'], 'pickup_address':p['routes'][0]['address'], 'pickup_location':p['routes'][0]['position']});
//      options['passengers']=passengers;
      options['type_route']=type_route;
      options['type_trip']='instantly';
      options['category']='route';
    }
    if(type_trip == 'reservation') {
      if (year != null && month != '00' && day != '' &&
          time['hour'] != null) {
        // poasible solucion al problema de 24 hora (las 24 no existen son las 00)

        String start = js.context.callMethod('moment', [
          '${year}-${month}-${day} ${time['hour']}:${time['minute']} ${meridiem}',
          'YYYY-MM-DD hh:mm A'
        ]).callMethod('toISOString');
        String when = js.context.callMethod('moment', [start]).callMethod(
            'fromNow');

        if (when.contains('ago') || when.contains('hace')) {
          processing = false;
          return showErros({'title': 'dateIsInPass'});
        } else {
          options['start']['date'] = start;
        }
      } else {
        processing = false;
        return showErros({'title': 'completeDate'});
      }
    }
    if(type_trip !='reservation'){
      options['start']['date'] = '';
    }
    options['type_trip']=type_trip;
    options['pay'] = pay;

    adminServices.trips.postGet('estimate', options).then((request) {
      estimate = jsonDecode(request.responseText);
      estimate['passengers'].forEach((pas){
        if(type_trip=='instantly') {
          pas['duration'] = js.context.callMethod('moment', [])
              .callMethod(
              'add', [(pas['duration'] / 60)+10, 'minutes'])
              .callMethod('format', ['MMMM D, YYYY k:mm']);
        }
        else if(type_trip=='reservation' && trip['start']['date'] != ''){
          pas['duration'] = js.context.callMethod('moment', [trip['start']['date']])
              .callMethod(
              'add', [pas['duration'] / 60, 'minutes'])
              .callMethod('format', ['MMMM D, YYYY k:mm']);
        }
      });

      //ruta estimada origen destino
      List path = encoding.decodePath(estimate['path']);
      estimate_path.path = path;
      estimate_path.visible=true;
      if (trip != null) {
        //actualiza inicio y fin del trip
        Map first = stops.first;
        trip['start']['pickup_location'] = [path.first.lat, path.first.lng];
        trip['start']['pickup_address'] = first['address'];
        trip['start']['marker_location'] = [path.first.lat, path.first.lng];
        trip['start']['real_location'] = [path.first.lat, path.first.lng];
        trip['passengers']=[];
//        passengers.forEach((p) {
//          trip['passengers'].add({'passenger_id':p['_id'], 'pickup_address':p['routes'][0]['address'], 'pickup_location':p['routes'][0]['position']});
//        });
        estimate['passengers'].forEach((p) {
          trip['passengers'].add({'passenger_id':p['passenger_id']['_id'], 'pickup_address':p['pickup_address'], 'pickup_location':p['pickup_location'],'alliance_id':trip['alliance_id']});
        });
        passengers=[];
        estimate['passengers'].forEach((p) {
          passengers.add({'_id':p['passenger_id']['_id'], 'alliance_id':{'_id':trip['alliance_id']},'personal_info':p['passenger_id']['personal_info'], 'email':p['passenger_id']['email'], 'route':[{'name':p['name'], 'address':p['pickup_address'], 'position':p['pickup_location']}]});
        });
        addMarkerStops();
//        temporalModal();
      }
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void newTripPost() {
    processing = true;
    trip['passengers']=[];
    trip['category']='route';
    if(type_route=='allforone'){
      trip['type_route']='allforone';
      trip['start']={'date': trip['start']['date']};
      trip['end']={'pickup_location': stops[0]['location'], 'pickup_address': stops[0]['address']};
    }
    if(type_route=='oneforall'){
      trip['type_route']='oneforall';
      trip['start']={'date': trip['start']['date'], 'pickup_location': stops[0]['location'], 'pickup_address': stops[0]['address'], 'marker_location': stops[0]['location'], 'real_location': stops[0]['location']};

    }

    passengers.forEach((p) {
      trip['passengers'].add({'passenger_id':p['_id'], 'pickup_address':p['route'][0]['address'], 'pickup_location':p['route'][0]['position'],'alliance_id':p['alliance_id']['_id']});
    });

    //si no ha seleccionado pasajeros
    if (pay == 'users' && passengers.length<=0) {
      processing = false;
      return selectUsersModal();
    }
    //si paga alianza mira si hay centro de costo
    if (pay == 'alliance' && cost_center == null) {
      processing = false;
      return selectCostCenterModal(User.user['_id']);
    }
    //si paga alianza y no tiene concepto
    if (pay == 'alliance' &&
        (trip['concept'] == '' || trip['concept'] == null)) {
      processing = false;
      return showErros({'title': 'concept'});
    }

    if (trip['type_trip'] == null) {
      processing = false;
      return showErros({'title': 'type_trip'});
    }

    trip['alliance_id'] = User.user['alliance_id']['_id'];
    if (user_dat['type_user'] == 'user' && trip['cost_center_id'] != null) {
      processing = false;
      return showErros({'title': 'user'});
    }
    if (user_dat['credit_card_id'] == null &&
        trip['cost_center_id'] == null) {
      processing = false;
      return showErros({'title': 'notCreditCard'});
    }
    if (user_dat['credit_card_id'] == null &&
        trip['cost_center_id'] == null) {
      processing = false;
      return showErros({'title': 'notCreditCard'});
    }

    if(type_trip == 'reservation') {
      if (year != null && month != '00' && day != '' &&
          time['hour'] != null) {
        // poasible solucion al problema de 24 hora (las 24 no existen son las 00)

        String start = js.context.callMethod('moment', [
          '${year}-${month}-${day} ${time['hour']}:${time['minute']} ${meridiem}',
          'YYYY-MM-DD hh:mm A'
        ]).callMethod('toISOString');
        String when = js.context.callMethod('moment', [start]).callMethod(
            'fromNow');

        if (when.contains('ago') || when.contains('hace')) {
          processing = false;
          return showErros({'title': 'dateIsInPass'});
        } else {
          trip['start']['date'] = start;
        }
      } else {
        processing = false;
        return showErros({'title': 'completeDate'});
      }
    }
    if(type_trip !='reservation'){
      trip['start']['date'] = '';
    }
    trip['type_trip']=type_trip;

//      if (trip['service_trip']['know_driver'] == true) {
//        trip['service_trip']['pool'] = false;
//        trip['service_trip']['places'] = null;
//      }
//
//      if (trip['service_trip']['pool'] == true) {
//        trip['service_trip']['know_driver'] = false;
//      }
//
//      if (trip['service_trip']['know_driver'] == false &&
//          trip['service_trip']['pool'] == false) {
//        trip['service_trip'] = {};
//      }


    adminServices.trips.post(trip).then((request) {
      Map data = jsonDecode(request.responseText);
      new_id = data['result']['insertedIds'][0];
      //reset
      resetPassenger();
      resetCostCenter();
      resetGuest();
      processing = false;
      router.navigate(RoutePaths.list_trips.toUrl(parameters: {target: 'actives'}));

    }, onError: (e) {
      processing = false;
      HttpRequest request = e.target;
      showErros(jsonDecode(request.responseText));
    });
  }
}
