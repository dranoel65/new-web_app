import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:google_maps/google_maps.dart';
import 'package:web_app/classes/User.dart';
import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../../../../config.dart';
import '../trips.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(selector: 'new-trip',
    styleUrls: ['../new.css'],
    templateUrl: 'new_trip.html',
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
class NewTripComponent extends TripsComponent {
  Config config = Config();
  String q = '';
  bool favorite_address = false;
  Map select_region;

  Timer timer;
  Timer timer_search;

  List<dynamic> stops = [];
  String new_id = 'xxxxxxxx';

  Map<String,dynamic> trip = {'start': {}, 'end': {}, 'type_trip': 'instantly', 'service_trip':{'pool':false, 'places':1, 'know_driver':false}};

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
  Map data_response = {};
  List<dynamic> geo_data = [];
  List<dynamic> addressGeo = [];
  List<dynamic> availableServices = [];
  List<String> availableTypeTrip = [];

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

  Future stops_marker(stop) async {
    Marker stops_marker = Marker(MarkerOptions()
      ..optimized = false
      ..map = map
      ..position = stop == null ? LatLng(4.6634163, -74.0920055) : LatLng(stop['point'][0], stop['point'][1])
      ..title =  stop == null ? '' : stop['name']
      ..icon = icon()
    );

    if(stop != null) {
      stops_marker.icon =  icon();
      event.addDomListener(map, 'onKeyDown', (key){ if (key.keyCode == 27) { infowindow.close(); } });
      stops_marker.onClick.listen((e) {
        infowindow.open(map, stops_marker);
        infowindow.content =
        '<div class="row info-monitor pl-3 pt-2 pre-scrollable space">'
            '<div class="col-12 space">${stop['name']}'
            '</div>';
      });
      stop_markers.add(stops_marker);
      return stop_markers;
    }
    else{
      return stop_markers=[];
    }
  }

  Future autoSelectStopMarker(marker_i, Map item) async {
    map.zoom = 16;
    if(marker_i == 0){
      stops[0]['location'] = [item['point'][0], item['point'][1]];
      markers[0].position = LatLng(item['point'][0], item['point'][1]);
      markers[0].map = map;
      infowindow.content = item['name'];
      infowindow.open(map, markers[0]);
      document.getElementById('label_address_0').innerHtml = item['name'];
      stops.first['address']=item['name'];

      getEstimate(trip, stops, month, day, time, meridiem);

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
      getEstimate(trip, stops, month, day, time, meridiem);

      map.center = LatLng(item['point'][0], item['point'][1]);
      hideAutocomplete(1,stops[1]['address']);
    }
  }

  void scanStops(marker_i,lat,lng){
    adminServices.scan_map.scanMap('${lat},${lng}').then((request) {
      adminServices.list_scan_services = jsonDecode(request.responseText)['result'];
      if(adminServices.list_scan_services['stops'].length >0){
        adminServices.list_scan_services['stops'].forEach((stop){
          stops_marker(stop);
        });
        autoSelectStopMarker(marker_i, adminServices.list_scan_services['stops'][0]);
      }
      else{
        stop_markers.forEach((s){
          s.map = null;
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

  void selectPassenger(Map item) {
    passenger = item;
    trip['passenger_id'] = item['_id'];
    cost_center = null;
    trip['cost_center_id'] = null;
    js.context.callMethod(r'$', ['#selectPassengerModal']).callMethod(
        'modal', ['hide']);
  }

  void searchPassengers() {
    adminServices.listUsers({
      'personal_info.firstname__like': q,
      'personal_info.lastname__like': q,
      'email__like': q,
      'active': 'true',
      'return': 'personal_info.firstname,personal_info.lastname,email,personal_info.image,active,costs_centers_ids,type_user',
      '_or': 'personal_info.firstname,personal_info.lastname,email'
    }.cast<String,dynamic>());
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
    a=id;
    q = '';
    searchFavorites();
    js.context.callMethod(r'$', ['#selectFavoritesModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  //Alerta de nuevo viaje
  void tripNewWarningModal() {
    if (data_response['code'] == 1) {
      trip = {'start': {}, 'end': {}, 'type_trip': 'instantly', 'service_trip':{'pool':false, 'places':1, 'know_driver':false}};
      resetPassenger();
      resetCostCenter();
      resetGuest();
      config = Config();
      q = '';
      favorite_address=false;
      select_region = null;
      stops = [];
      new_id = 'xxxxxxxx';
      msg_error = '';
      map;
      xcenter = '';
      center = LatLng(4.6634163, -74.0920055);
      passenger = null;
      cost_center = null;
      favorite = null;
      guest = null;
      map_services = null;
      type_service_id = null;
      type_trip = null;
      who = 'me';
      meridiem = 'AM';
      user_id = '';
      time = {'hour': 1, 'minute': 0};
      days = [];
      month = '';
      day = '';
    }
    js.context.callMethod(r'$', ['#tripNewWarningModal']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  void aceptReservation(){
    type_trip = 'reservation';
    trip['type_trip'] = 'reservation';
  }

  void clickOut(){
//    router.navigate(['Trips', {'show_id': 'actives'}]); ----
    js.context.callMethod(r'$', ['#tripNewWarningModal']).callMethod('modal', ['hide']);
  }

  void setCancelTrip() {
    adminServices.trips.put('${data_response['trip_id']}/cancelled', {}).then((request) {
      var t = jsonDecode(request.responseText);
      processing = false;
      resetPassenger();
      resetCostCenter();
      resetGuest();
//      router.navigate(['Trips', {'show_id': 'actives'}]); ----
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
    js.context.callMethod(r'$', ['#tripNewWarningModal']).callMethod('modal', ['hide']);
  }

  Future selectFavorites(Map item) async {
    favorite_address=true;
    if(a == 0){
      stops[0]['location'] = [item['start']['position'][0], item['start']['position'][1]];
      markers[0].position = LatLng(item['start']['position'][0],item['start']['position'][1]);
      markers[0].map = map;
      infowindow.content = item['start']['address'];
      infowindow.open(map, markers[0]);
      document.getElementById('label_address_0').innerHtml = item['start']['address'];
      (document.getElementById('stop_0') as InputElement).value = item['start']['address'];
      stops.first['address']=item['start']['address'];

      getEstimate(trip, stops, month, day, time, meridiem);

      map.center = LatLng(item['start']['position'][0], item['start']['position'][1]);
      hideAutocomplete(0,stops[0]['address']);
      if(item['end']['position']!=null){
        await end_position(item);
        document.getElementById('label_address_1').innerHtml = item['end']['address'];
      }
      findTypesServices(item['start']['position'][0], item['start']['position'][1]);
    }
    else if(a == 1){
      stops[1]['location'] = [item['start']['position'][0], item['start']['position'][1]];
      markers[1].position = LatLng(item['start']['position'][0],item['start']['position'][1]);
      markers[1].map = map;
      infowindow.content = item['start']['address'];
      infowindow.open(map, markers[1]);
      document.getElementById('label_address_1').innerHtml = item['start']['address'];
      (document.getElementById('stop_1') as InputElement).value = item['start']['address'];
      stops.last['address'] = item['start']['address'];
//      stops[1]['address'] = infowindow.content;
      getEstimate(trip, stops, month, day, time, meridiem);

      map.center = LatLng(item['start']['position'][0], item['start']['position'][1]);
      hideAutocomplete(1,stops[0]['address']);
    }

    js.context.callMethod(r'$', ['#selectFavoritesModal']).callMethod('modal', ['hide']);
  }

  void end_position(Map item){
    stops[1]['location'] = [item['end']['position'][0], item['end']['position'][1]];
    markers[1].position = LatLng(item['end']['position'][0],item['end']['position'][1]);
    markers[1].map = map;
    infowindow.content = item['end']['address'];
    infowindow.open(map, markers[1]);

    getEstimate(trip, stops, month, day, time, meridiem);

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
    hideAutocomplete(1,stops[0]['address']);
  }

  void searchFavorites(){
    Map<String,String> dat = {
      'alliance_id': User.user['alliance_id']['_id'],
      'user_id': User.user['_id'], 'active': 'true',
      'return': 'name,start.position,start,end,alliance_id',
      '_or':'alliance_id,user_id'
    };

    if (q!=''){
      dat['name__like']=q;
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

  Map user_dat = {'credit_card_id': null, 'type_user': 'user'};
  bool know_driver = false;
  String g = '';

  NewTripComponent(Router router, AdminServices adminServices) : super(router, adminServices) {

    if (!User.user.containsKey('personal_info')) {
//      router.navigate(RoutePaths.login.toUrl());
    } else {
      //valores por defecto
      var fullHeight = window.screen.available != null ? window.screen.available
          .height : 547;
      js.context.callMethod(r'$', ['#map-container']).callMethod(
          'css', ['max-height', '${fullHeight - 47}px']);
      js.context.callMethod(r'$', ['#map-canvas']).callMethod(
          'css', ['height', '${fullHeight - 47}px']);
      js.context.callMethod(r'$', ['#menu']).callMethod(
          'css', ['max-height', '${fullHeight - 47}px']);

      trip['alliance_id'] = Map.from(User.user['alliance_id']);
//      g = User.user['alliance_id']['_id'];
      if (User.user['alliance_id'].runtimeType.toString() != 'String') {
        if (User?.user['alliance_id']['routes_active'] != null) {
          routes_active = User.user['alliance_id']['routes_active'];
        }
      } else {
        routes_active = false;
      }

      adminServices.alliances.get(trip['alliance_id']['_id'], {
        'return': 'legal,alliance_father_id,pool_active,service_trip',
        'populate': 'alliance_father_id:service_trip,legal'
      }).then((request) {
        Map child_alliance = jsonDecode(request.responseText);
        if (child_alliance['alliance_father_id'] == null &&
            child_alliance.containsKey('service_trip')) {
          know_driver = child_alliance['service_trip']['know_driver'];
        }
        else {
          if (child_alliance['alliance_father_id'].containsKey(
              'service_trip')) {
            know_driver =
            child_alliance['alliance_father_id']['service_trip']['know_driver'];
          }
        }
      }, onError: (e) {
        adminServices.evaluateError(e);
      });

      passenger = User.user;
      trip['passenger_id'] = User.user['_id'];

      timer = Timer(Duration(seconds: 1), () {
        var mc = querySelector('#map-canvas');
        if (mc != null) {
          timer.cancel();
          map = GMap(mc, mapOptions);
          map.center = center;

          createStop('Origen');
          createStop('Destino');

          estimate_path = Polyline(PolylineOptions()
            ..geodesic = true
            ..strokeColor = '#0404B4'
            ..strokeOpacity = 1.0
            ..strokeWeight = 2
            ..map = map);
//
//        estimate_path = Polyline(PolylineOptions()
//          ..geodesic = true
//          ..strokeColor = '#0404B4'
//          ..strokeOpacity = 1.0
//          ..strokeWeight = 2
//          ..map = map);

        }
      });
      adminServices.regions.query({'active': 'true', 'return': 'name,center'}).then((
          request) {
        Map data = jsonDecode(request.responseText);
        adminServices.list_regions = data['result'];
        Map first = adminServices.list_regions.first;
        //center = LatLng(first['center'][0], first['center'][1]);
      }, onError: (e) {
        adminServices.evaluateError(e);
      });

      adminServices.userMe({
        'return': 'type_user,balance,credit_card_id',
        'populate': 'credit_card_id:type,number,name'
      }.cast<String,dynamic>()).then((request) {
        Future(() {
          user_dat = jsonDecode(request.responseText);
        });
      }, onError: (e) {
//        router.navigate(RoutePaths.login.toUrl());
      });

      var now = DateTime.now();
      DateTime moonLanding = DateTime.parse(now.toString());

      day =
      moonLanding.day < 10 ? '0${moonLanding.day.toString()}' : moonLanding.day
          .toString();
      month = months[moonLanding.month]['v'];

      for (int a = 1; a <= changeM(month); a++) {
        days.add(a < 10 ? '0${a.toString()}' : a.toString());
      }
    }
  }

  void findTypesServices(num lat, num lng) {
    availableServices.clear();
    availableTypeTrip.clear();
    type_service_id = null;
    trip['type_service_id'] = null;

    trip['type_trip'] = null;
    type_trip = null;

    adminServices?.scan_map?.scanMap('${lat},${lng}')?.then((request) {
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

//    services.get('${lat},${lng}').then((request) {
//      list_services = jsonDecode(request.responseText);
//    }, onError: (e) {
//      evaluateError(e);
//    });
  }

  void geoSearch(event, i) {

    if(timer_search!=null){
      timer_search.cancel();
    }

    timer_search = Timer(Duration(seconds: 1), () {
      geo_data=[];
      var mc = querySelector('#stop_${i}');
      if (mc != null) {
        timer_search.cancel();
        String test = '#autocomple_$i'.toString();
        if (event.target.value
            .toString().isNotEmpty && querySelector(test) != null) {
          if(i == 0) {
            querySelector('#autocomple_0').style.display = 'block';
          }
          else {
            querySelector('#autocomple_1').style.display = 'block';
          }
        }
        else if (querySelector(test) != null) {
          if(i == 0) {
            querySelector(test).style.display = 'none';
          }
          else {
            querySelector(test).style.display = 'none';
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
//        createAutoComplete(i);
      }
    });

  }

  void loadAddress(address_item,i) {
    String test = '#autocomple_$i'.toString();

    if(i == 0) {
      querySelector(test).style.display = 'none';
    }
    else {
      querySelector(test).style.display = 'none';
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
    stops[i]['location'] = [stops[i]['location'].lat.toString()+','+stops[i]['location'].lng.toString()];
    (document.getElementById('stop_$i') as InputElement).value=address_item['formatted_address'];
    scanStops(i,address_item['geometry']['location']['lat'], address_item['geometry']['location']['lng']);
    if(i == 0) {
      findTypesServices(
          address_item['geometry']['location']['lat'], address_item['geometry']['location']['lng']);
    }
    getEstimate(trip, stops, month, day, time, meridiem);

  }

  void showAutocomplete(i) {
    document.getElementById('label_${i}').hidden = true;
    (document.getElementById('stop_${i}') as InputElement).hidden = false;
    (document.getElementById('btn_${i}') as ButtonElement).hidden = false;
    stops[i]['ready'] = false;
  }

  void hideAutocomplete(i, text) {
    if(favorite_address!=true) {
      document.getElementById('label_address_${i}').innerHtml = text;
    }
    document.getElementById('label_${i}').hidden = false;
    (document.getElementById('stop_${i}') as InputElement).hidden = true;
    (document.getElementById('btn_${i}') as ButtonElement).hidden = true;
    stops[i]['ready'] = true;
    favorite_address=false;
  }

  void createMarker(i) {
    Marker marker = Marker(MarkerOptions()
      ..optimized = false
      ..draggable = true
      ..icon = (Icon()
        ..url = i == 0
            ? 'assets/icons/trip/map/ic_marker_origin_anim.gif'
            : 'assets/icons/trip/map/ic_marker_destination_anim.gif'
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

        getEstimate(trip, stops, month, day, time, meridiem);

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

  void createStop(String name,) {
    num i = stops.length;
    stops.add({
      'ready': false,
      'name': name,
      'pickup_address': null,
      'pickup_location': null,
      'marker_location': null
    });

    createMarker(i);
  }

  void setCenter() {
    Future(() {
      List<String> c = xcenter.split(',');
      map.center = LatLng(num.parse(c[0]), num.parse(c[1]));
    });
  }

  void setTypeService(String typeServiceId) {
    availableTypeTrip.clear();
    type_service_id = typeServiceId;
    trip['type_trip'] = null;

    Future(() {
      trip['type_service_id'] = typeServiceId;
      map_services =
      adminServices.list_services.firstWhere((item) => item['_id'] == trip['type_service_id'],
          orElse: () => {'services': []})['services'];
      map_services.forEach((type) {
        availableTypeTrip.add(type['name']);
      });
      type_trip = typeServiceId.isEmpty ? '' : (map_services?.first)['name'];
      trip['type_trip'] = type_trip;
    });
  }

  void setTypeTrip(type) {
    type_trip = type;
    Future(() {
      trip['type_trip'] = type_trip;
    });
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

  void goTrip(String trip_id) {
    js.context.callMethod(r'$', ['#tripNewSuccessful']).callMethod(
        'modal', ['hide']);

//    router.navigate(['TripsEdit', {'trip_id': trip_id}]); ----
  }

  void change() {
    window.console.log(month);
    days.clear();

    Future(() {
      if (month != '00') {
        for (int a = 1; a <= changeM(month); a++) {
          days.add(a < 10 ? '0${a.toString()}' : a.toString());
        }
        day = '01';
      }
    });
  }

  void newTripPost() {
    processing = true;
    //si no ha seleccionado pasajeros
    if (pay == 'users' && passenger == null) {
      processing = false;
      return selectPassengerModal();
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
//    if(User.user.containsKey('alliance_id._id')) {
//      trip['alliance_id'] = User.user['alliance_id']['_id'];
//    } else {
//    }

    //
    if (user_dat['type_user'] == 'user' && trip['cost_center_id'] != null) {
      processing = false;
      return showErros({'title': 'user'});
    }
    if (user_dat['credit_card_id'] == null && trip['cost_center_id'] == null) {
      processing = false;
      return showErros({'title': 'notCreditCard'});
    }
    if (user_dat['credit_card_id'] == null && trip['cost_center_id'] == null) {
      processing = false;
      return showErros({'title': 'notCreditCard'});
    }

    //mira si la alianza y demas esten
    if (trip['passenger_id'] == null && guest == null) {
      processing = false;
      return showErros({'title': 'valuesInit'});
    }
    if (guest != null && guest['name'] == '' && guest['phone'] == '' &&
        guest['email'] == '') {
      processing = false;
      return showErros({'title': 'guest'});
    }
    if (trip['passenger_id'] == null) {
      trip['guest'] = guest;
    }
    //mira si todas las paradas estan ok
    for (int i = 0; i < stops.length; i++) {
      if (!stops[i]['ready']) {
        processing = false;
        return showErros({'title': 'stopsNotReady'});
      }
    }

    if (type_trip == 'reservation') {

      if (year != null && month != '00' && day != '' && time['hour'] != null) {
// poasible solucion al problema de 24 hora (las 24 no existen son las 00)

        String start = js.context.callMethod('moment', [
          '${year}-${month}-${day} ${time['hour']}:${time['minute']} ${meridiem}',
          'YYYY-MM-DD hh:mm A'
        ]).callMethod('toISOString');
        String when = js.context.callMethod('moment', [start]).callMethod(
            'fromNow');

        if (when.contains('ago') || when.contains('hace')) {
          processing = false;
          trip['start']['date'] = start;
          return showErros({'title': 'dateIsInPass'});
        } else {
          trip['start']['date'] = start;
        }
      } else {
        processing = false;
        return showErros({'title': 'completeDate'});
      }
    }
    if (trip['start']['pickup_address']==trip['end']['pickup_address']){
      stops[1]['location'] = [stops[1]['location'][0], (stops[1]['location'][1])+0.007];
      markers[1].position = LatLng(stops[1]['location'][0], (stops[1]['location'][1])+0.007);
      markers[1].map = map;
      infowindow.content = 'Valide su destino';
      infowindow.open(map, markers[1]);
      document.getElementById('label_address_1').innerHtml = 'Valide su destino';
      getEstimate(trip, stops, month, day, time, meridiem);

      map.center = LatLng(stops[1]['location'][0], stops[1]['location'][1]+0.007);
      markers[1].position = LatLng(stops[1]['location'][0], stops[1]['location'][1]+0.007);
      processing = false;
      return showErros({'title': 'addressError'});
    }

    if (trip['service_trip']['know_driver']==true){
      trip['service_trip']['pool']=false;
      trip['service_trip']['places']=null;
    }

    if (trip['service_trip']['pool']==true) {
      trip['service_trip']['know_driver'] = false;
    }

    if (trip['service_trip']['know_driver']==false && trip['service_trip']['pool']==false){
      trip['service_trip']={};
    }


    if (type_trip != 'reservation') {
      adminServices.trips_with_driver.post(trip).then((request) {
        Map data = jsonDecode(request.responseText);
        data_response = data;
        if (data['code'] == 2 || data['code'] == 1) {
          tripNewWarningModal();
          processing = false;
        }
        else {
          new_id = data['result']['insertedIds'][0];
          resetPassenger();
          resetCostCenter();
          resetGuest();
          processing = false;
          router.navigate(RoutePaths.list_trips.toUrl(parameters: {target: 'actives'}));
        }
//      new_id = data['result']['insertedIds'][0];

        //js.context.callMethod(r'$', ['#tripNewSuccessful']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
      }, onError: (e) {
        processing = false;
        HttpRequest request = e.target;
        showErros(jsonDecode(request.responseText));
      });
    }
    else{
      adminServices.trips.post(trip).then((request) {
        Map data = jsonDecode(request.responseText);
        new_id = data['result']['insertedIds'][0];
        resetPassenger();
        resetCostCenter();
        resetGuest();
        processing = false;
        router.navigate(RoutePaths.list_trips.toUrl(parameters: {target: 'actives'}));
        //map_services = null;
//      type_service_id = null;
//      type_trip = null;


        //js.context.callMethod(r'$', ['#tripNewSuccessful']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
      }, onError: (e) {
        processing = false;
        HttpRequest request = e.target;
        showErros(jsonDecode(request.responseText));
      });
    }
  }

}
